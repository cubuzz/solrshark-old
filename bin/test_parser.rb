require './solrparser'

parser = Nokogiri::XML::SAX::Parser.new(SolrParser.new)
stream = File.open('test.pdml', 'r')

parser.parse stream

require 'yaml'
File.open('test.yml', 'w') do |dump|
    dump.puts YAML.dump parser.document.nodes
end