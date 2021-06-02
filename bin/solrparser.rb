require 'rubygems'
require 'bundler/setup'

require 'nokogiri'
require 'rsolr'

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
    def initialize(cfg)
        raise 'You did not pass a valid configuration :(' if cfg.nil? ||
                                                             cfg.empty? ||
                                                             cfg[:solr].nil? ||
                                                             cfg[:solr].empty?

        super()
        @cfg = cfg
        @solr = RSolr.connect(
            @cfg[:solr]
        ) unless @cfg[:dry_run]
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

            # TODO: Regenerator stuff
            # If wireshark is supposed to hide this field.
            # In our case, we always want to store it anyway.
            attributes.delete('hide')
            # What value is wireshark supposed to show?
            # Doesn't matter, we can figure it out anyway.
            attributes.delete('show')

            # TODO: Uncomment when fully implemented.
            # This field only stores a full-text, human readable
            # version of the data. Not required when we store everything.
            # attributes.delete('showname')

            # Push to node
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
        return if @cfg[:dry_run]
        @solr.add @nodes
        @nodes = []
    end

    def propose_push_to_solr
        # Check config and figure out if we want to push to solr.
        return if @cfg[:dry_run]
        return unless (@nodes.length % @cfg[:push_every]).zero?

        push_to_solr
    end
end
