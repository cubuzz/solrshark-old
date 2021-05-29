# Solr Uploader
This script allows you to batch-parse pcap files
and upload them into your solrcore.
Of course, you could also do this manually...

# Installation:
Verify that `ruby` and the gem `bundler` are installed. (`gem install bundler`)
Then run `bundle install`.

# Before using:
Verify that the commands `tshark` and `mergecap` are in your path. Otherwise, this script will
fail spectacularily and will likely break stuff. You've been warned!

If you don't want to add the wireshark executables to your path, you can also set the path to
Wireshark's /bin manually in the config. Note that you'll have to change `:wshark_in_path: true`
to false for it to load your custom wireshark path.

# Usage:
Copy `config.yml.example` and edit `config.yml` to suit your needs. 
Then, run `ruby solr_uploader.rb <path/to/your/pcaps>`.
Note that the script first merges all pcaps using mergecap, then processes them 
using tshark and uploads them to your solr instance.