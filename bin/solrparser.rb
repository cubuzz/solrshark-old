require 'rubygems'
require 'bundler/setup'

require 'nokogiri'

##
# SolrParser
# A custom SAX parser that is optimized for indexing PDML files.
# 
class SolrParser < Nokogiri::XML::SAX::Document
    # We need to push to Solr during the indexing because
    # yes, this process does consume RAM. And a lot of RAM.
    # Why do you think we're building a SAX parser in the first place?
    def initialize(cfg = {})
        super
        @cfg = cfg
    end

    # PDML contains all data within the element attributes.
    def start_element name, attrs = []
        puts "#{name}: #{attrs.inspect}"
    end
  
    def end_element name
        puts "-#{name}"
    end
end