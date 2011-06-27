module Demonoid
  class Result
    attr_accessor :name, :seeds, :leeches, :category, :link, :magnet_link, :status, :size, :date_created, :detail_link

    def initialize(row = [])
       self.name = row[0].search('td')[1].search('a').inner_html
       self.detail_link = row[0].search('td')[1].search('a').first.get_attribute('href')
       base_url = "http://www.demonoid.me"
       self.link = base_url + row[1].search('td')[2].search('a').first.get_attribute('href')
       self.magnet_link = base_url + row[1].search('td')[2].search('a')[1].get_attribute('href')
       self.seeds = row[1].search('td')[6].search('font').inner_html.to_i
       self.leeches = row[1].search('td')[7].search('font').inner_html.to_i

       raw_filesize =  row[1].search('td')[3].inner_html
       self.size = Demonoid::Result.filesize_in_bytes(raw_filesize)
    end

    def to_s
      "<Demonoid::Result @name => #{name}, @seeds => #{seeds}, @size => #{size}>"
    end
    
    def self.filesize_in_bytes(filesize)
      match = filesize.match(/([\d\.]+) (.*)/)

      if match
        raw_size = match[1].to_f

        case match[2].strip
          when /gb/i then
            raw_size * 1000000000
          when /mb/i then
            raw_size * 1000000
          when /kb/i then
            raw_size * 1000
          else
            nil
        end
      else
        nil
      end

    end

  end
end