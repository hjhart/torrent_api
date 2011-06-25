The Torrent API
===============



### What it does

The Torrent API brings torrent downloading to the ruby language. It allows for searching numerous torrent websites using an easy-to-use ruby DSL.

### How it does it

Using Nokogiri or Hpricot, it takes a search term (and sometimes a category) and grabs the page and parses through the HTML to scrape the results, leaving you with just the most important information.

### Usage

#### Query all torrent websites

    torrents = TorrentApi.new(:all, 'the royal tanenbaums')

#### Search the default service (the pirate bay)

    t = TorrentApi.new
    t.search_term = 'james and the giant peach'
    results = t.search

#### Select a service to use and search

    t = TorrentApi.new
    t.service = :demonoid
    t.search_term = 'james and the giant peach'
    results = t.search

#### Shorthand

    TorrentApi.new(:all, "james and the giant peach")`




### Available services

* TorrentReactor
* The Piratey Bay
* Demonoid (still buggy)

### How to help

Add more torrent sites!

### To do:
* Need to fix demonoid. Still buggy with newer movies.
* Refactor all three search engines to use a shared torrent model
* More search engines!
* Need to add/remove dependencies - awesome_print and nokogiri
* Improve the ability to select a category (I think it defaults to a movie category right now)
