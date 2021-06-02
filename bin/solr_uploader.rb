##
# Solr Uploader
#
# For usage instructions, consult the README in this folder.
require 'rubygems'
require 'bundler/setup'

# YAML library
require 'yaml'
unless File.exist?('config.yml')
    if ARGV[0] == '--genconfig'
        cfg = {
            solrcore: 'http://localhost:8983/solr/solrshark/',
            delete_captures: false,
            wshark_in_path: true,
            wshark_location: '/path/to/wireshark'
        }
        File.open('config.yml', 'w') do |f|
            f.puts YAML.dump cfg
        end
        abort 'A new config file has been created.'
    else
        abort 'No config file found.'
    end
end

cfg = YAML.load File.read('config.yml')

abort 'Please provide a path for files to index!' if ARGV[0].nil?

files = []
if Dir.exist?(ARGV[0])
    # Is a directory and exists.
    # Iterate over directory:
    Dir.foreach(ARGV[0]) do |file|
        next if ['.', '..'].any? { |f| f == file }

        files << if file.end_with?('/')
                     "#{ARGV[0]}#{file}"
                 else
                     "#{ARGV[0]}/#{file}"
                 end
    end
elsif File.exist?(ARGV[0])
    # Is not a directory. Is it a file?
    files << ARGV[0]
else
    abort "Expected file or directory, got #{ARGV[0]} instead."
end

abort 'Empty directory passed' if files.length.zero?

print "Warning: You're about to index #{files.length} files. This process will take a while and consume a lot of hard " \
    'drive space, as files will be converted from the wireshark format into search engine compatible index files. '\
    'Expect an increase of up to 10x times original size. Proceed? (y/N) '
abort 'Process cancelled.' unless STDIN.gets.chomp.downcase == 'y'

file = 'solrcap.pcapng'
if files.length > 1
    # Invoke mergecap
    if File.exist?('solrcap.pcapng')
        abort 'File solrcap.pcapng already exists! Please rename or delete before proceeding.'
    end
    mergecap_command = "\"#{cfg[:wshark_in_path] ? 'mergecap' : "#{cfg[:wshark_location]}/mergecap"}\" -w solrcap.pcapng"
    files.each do |f|
        mergecap_command << " #{f}"
    end
    puts "Running #{mergecap_command}..."
    puts `#{mergecap_command}`

    if cfg[:delete_captures]
        print "[ RUN ] Deleting non-merged captures... 0/#{files.length}"
        files.each_with_index do |f, index|
            File.delete f
            print "\r[ RUN ] Deleting non-merged captures... #{index}/#{files.length}"
        end
        puts "\r[ OK ] #{files.length} unmerged capture files have been deleted."
    end
elsif files.length == 1
    # Overwrite file
    file = files[0]
else
    raise 'We hit an edge-case we were not supposed to hit... How?!'
end
# puts cfg.inspect
# Open stream to tshark
stream = IO.popen("\"#{cfg[:wshark_in_path] ? 'tshark' : "#{cfg[:wshark_location]}/tshark"}\" -r #{file} -T pdml")

# Stream data to Solr.
require 'nokogiri'
require './solrparser'
parser = Nokogiri::XML::SAX::Parser.new(SolrParser.new({ solr: { url: cfg[:solrcore] } }))

# Debugger
require 'pry'
binding.pry
