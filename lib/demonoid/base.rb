module Demonoid
  class Search
    attr_accessor :search_string, :category_id, :page, :caching, :results

    def initialize(search_string, category=0)
      self.search_string = URI.encode(search_string)
      self.page = -1

      @results = Demonoid::ResultSet.new(self)
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
      File.join("searches", "#{search_string}_#{category_id}_#{page}.html")
    end

    def fetch_search_results
      Demonoid
      searchurl = "http://www.demonoid.me/files/?category=1&subcategory=All&language=0&quality=All&seeded=0&external=2&query=#{search_string}&uid=0&sort=S"

      Hpricot(URI.parse(searchurl).read)

    end

    private

    def next_page(doc)
      if @results.total_results = 1.0/0
#        TODO: Figure out the total results
      end

      demonoid_row = []
      demonoid_table = doc.search('.ctable_content_no_pad table tr')
      demonoid_table = demonoid_table.select { |row| !(row.search('iframe').count == 1 || row.inner_html =~ /Sponsored links/)}
      demonoid_table.each_with_index do |row, index|
        next if (0..3).include? index # skip the first few rows. It's mostly junk.
        break if index == 154 # end of table
        
        demonoid_row << row
        if index % 3 == 0 # this is the majority of the info
          result = Demonoid::Result.new(demonoid_row)
          demonoid_row = []
          @results << result
        elsif index % 3 == 1 # this contains the date of birth
        elsif index % 3 == 2 #this contains the title and the cateogyr
        end
      end

      @results
    end

  end


end