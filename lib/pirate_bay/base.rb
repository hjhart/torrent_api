module PirateBay
  class Search
    attr_accessor :search_string, :category_id, :page, :caching, :results

    def initialize(search_string, category='movies')
      self.search_string = URI.encode(search_string)
      self.category_id = PirateBay::Categories::IDS[category.upcase.strip.gsub(/S$/, "").to_sym] unless category == 0
      self.page = -1

      @results = PirateBay::ResultSet.new(self)
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
        doc = Nokogiri::HTML(get_search_results)
      end

      next_page(doc)

    end
    
    def sanitize_filename(filename)
      filename = filename.gsub(/[^0-9A-Za-z.\-]/, 'x')
      filename = filename.gsub(/^.*(\\|\/)/, '')
      filename.strip
    end

    def cached_filename
      File.join("tmp", "searches", "#{sanitize_filename(search_string)}_#{category_id}_#{page}.html")
    end
    
    def get_quality
      execute
      results = @results.map do |result|
        url = "http://www.thepiratebay.se/torrent/#{result.id}/"
        html = open(url).read
        p = PirateBay::Details.new html, :init
        puts "Fetching results"
        result = { 
          :seeds => result.seeds, 
          :size => result.size, 
          :name => result.name, 
          :video => p.video_quality_average, 
          :audio => p.audio_quality_average, 
          :url => url,
          :video_votes => p.video_scores.size,
          :audio_votes => p.audio_scores.size,
          :video_votes_sum => p.video_quality_score_sum,
          :audio_votes_sum => p.audio_quality_score_sum
        } 
        puts "Results: #{result}"
        result
      end
      
      results.reject { |a| a[:video].nan? }.sort_by { |a| a[:video] }
    end
    

    def fetch_search_results
      url = "http://thepiratebay.se/search/#{search_string}/#{page}/7/#{category_id}" # highest seeded first

      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port)
      response = http.request(Net::HTTP::Get.new(uri.request_uri))

      response.body
    end

    private

    def next_page(doc)
      if @results.total_results.nil?
        matching_results = doc.css("h2").first.content.match(/Displaying hits from (.*) to (.*) \(approx (.*) found\)/i)

        if (matching_results.nil?)
          @results.total_results = 0
        else
          @results.total_results = matching_results[3].to_i
        end
      end

      doc.css("#searchResult tr").each_with_index do |row, index|
        next if index == 0
        result = PirateBay::Result.new(row)
        @results << result
      end
      @results
    end

  end


end