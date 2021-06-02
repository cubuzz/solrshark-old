require './solrparser'

parser = Nokogiri::XML::SAX::Parser.new(SolrParser.new({
    solr: {
        url: 'http://localhost:8983/solr/solrshark'
    },
    push_every: 10,
    dry_run: false
    })
)
stream = File.open('test.pdml', 'r')

parser.parse stream

require 'yaml'
File.open('test.yml', 'w') do |dump|
    dump.puts YAML.dump parser.document.nodes
end
