require 'rubygems'
require 'bundler/setup'

require 'nokogiri'
require 'solr'

##
# SolrParser
# A custom SAX parser that is optimized for indexing PDML files.
#
class SolrParser < Nokogiri::XML::SAX::Document
    attr_accessor :cfg
    attr_reader :nodes

    # We need to push to Solr during the indexing because
    # yes, this process does consume RAM. And a lot of RAM.
    # Why do you think we're building a SAX parser in the first place?
    def initialize(cfg = { solr: {} })
        super()
        @cfg = cfg
        @solr = RSolr.connect(
            @cfg[:solr]
        )
        @nodes = []
        @node = nil
        @path = []
    end

    # PDML contains all data within the element attributes.
    def start_element(node_name, attrs = [])
        # Cast attributes to key
        attributes = {}
        attrs.each do |kvset|
            attributes[(kvset[0]).to_s] = kvset[1]
        end

        case @path.length
        when 0
            # Opened PDML
        when 1
            # New packet!
            @node = {}
        else
            # What's in the box?

            # TODO: Deduplication checks
            @node[attributes.delete('name')] = attributes
        end

        @path << node_name
    end

    def end_element(_node_name)
        @path.pop
        case @path.length
        when 1
            # Packet closed.
            @nodes << @node
            @node = nil
            propose_push_to_solr
        when 0
            # PDML closed.
            # Finalize process.
            push_to_solr unless @nodes.length.zero?
        end
    end

    def push_to_solr
        # Upload all indexed nodes to solr.
        # Then clear @nodes.
        @solr.add @nodes
        @nodes = []
    end

    def propose_push_to_solr
        # Check config and figure out if we want to push to solr.
        return unless (@nodes.length % @cfg[:push_every]).zero?
        push_to_solr
    end
end
