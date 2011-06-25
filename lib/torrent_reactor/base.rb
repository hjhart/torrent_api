module TorrentReactor
  class Search
    attr_accessor :search_string, :category_id, :page, :caching, :results

    def initialize(search_string)
      self.search_string = URI.encode(search_string)
#      self.category_id = TorrentReactor::Categories::IDS[category.upcase.strip.gsub(/S$/, "").to_sym] unless category == 0
      self.page = -1

      @results = TorrentReactor::ResultSet.new(self)
    end

    def get_search_results
      if caching && File.exists?(cached_filename)
        content = File.read(cached_filename)
      else
        content = fetch_search_results

        FileUtils.mkdir_p("tmp/searches")
        File.open(cached_filename, "w") do |f|
          f.write(content)
        end
      end
      content
    end

    def execute
      return nil if search_string.nil?
      self.page += 1

      if (@results.size < @results.total_results)
        doc = get_search_results
      end

      next_page(doc)

    end

    def cached_filename
      File.join("tmp", "searches", "#{search_string}_#{category_id}_#{page}.html")
    end


    def fetch_search_results

      base_search_url = 'http://www.torrentreactor.net/search.php?search=&words='
      sortstring = "&sid=&type=1&exclude=&orderby=a.seeds&cid=5&asc=0&x=47&y=6"
      searchurl = base_search_url << search_string.split.join("+") << sortstring

      Hpricot(URI.parse(searchurl).read)
    end

    private

    def next_page(doc)
      if @results.total_results == 1.0/0 # Infinity
        results = doc.search('p[@align=center]')
        links = results.search('a')
        if links.count > 0
          match = links.last.inner_html.match(/(\d+)-(\d+)/)
        else
          match = results.inner_html.match(/(\d+)-(\d+)/)
        end
        if (match.nil?)
          @results.total_results = 0
        else
          puts match[2].to_i
          @results.total_results = match[2].to_i
        end
      end

      tables = doc.search(".styled") # there are two, the first of which is advertisements ( as of 6/22/2011 )
      torrent_table = tables[1]
      torrent_table.search('.torrent_odd, .torrent_even').each do |row|
        result = TorrentReactor::Result.new(row)
        @results << result
      end

      @results
    end

  end


end