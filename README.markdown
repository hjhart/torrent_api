The Torrent API
===============



### What it does

The Torrent API brings torrent downloading to the ruby language. It allows for searching numerous torrent websites using an easy-to-use ruby DSL.

### How it does it

Using Nokogiri or Hpricot, it takes a search term (and sometimes a category) and grabs the page and parses through the HTML to scrape the results, leaving you with just the most important information.

### Usage

#### Search the default service (the pirate bay)

    t = TorrentApi.new
    t.search_term = 'james and the giant peach'
    results = t.search

#### Query all torrent websites and work with those torrents

    torrents = TorrentApi.new(:all, 'the royal tenenbaums')
    torrent = torrents.first
    torrent.name
    => "The.Royal.Tenenbaums.XviD.DVD-Rip"
    torrent.seeds
    => 128
    torrent.size # size is returned in bytes
    => 702840000.0

#### Torrent methods

    :name, :seeds, :leeches, :category, :link, :magnet_link, :status, :size

#### Select a service to use and search

    t = TorrentApi.new
    t.service = :demonoid
    t.search_term = 'james and the giant peach'
    results = t.search

#### Shorthand query all

    TorrentApi.new(:all, "james and the giant peach")`

### Available services

* TorrentReactor
* The Piratey Bay
* Demonoid

### How to help

Add more torrent sites!

### To do
* Refactor all three search engines to use a shared torrent model
* More search engines!
* Need to add/remove dependencies - awesome_print and nokogiri
* Improve the ability to select a category (I think it defaults to a movie category right now)
