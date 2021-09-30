# solrshark

### Why solrshark?
Wireshark is a great tool for working with packet captures. It allows you to quickly dig through data, look for specific packets, and inspect packages. 
Unfortunately, Wireshark becomes increasingly less performant with larger datasets. That's why we're building solrshark.


### What exactly is solrshark?
solrshark is a application for working with huge packet captures. It works like this:

* You capture your packets using a software of your choosing. Wireshark is the engine that is used for developing.
    *solrshark was built with wireshark compatibilty in mind. Using a different capturing engine might yield non-working results.*
* Export your captures and upload them into the solr backend. You can do that yourself manually, or use the `/bin/solr_uploader.rb` script.
* You can now explore your captures in the Web UI.

Since solrshark is a free project that depends on other components, you will have to install your capturing engine and Solr on your own.


# Update (Sept. 2021)
I have decided that the way I approached this project was wrong and will therefore rework the entire code base. Please visit [the new repo](https://github.com/cubuzz/solrshark) if you're interested. Changes made will include a native flutter desktop client, a better storage format and more. Thank you for your patience, I'm certain it'll be worth the wait!
