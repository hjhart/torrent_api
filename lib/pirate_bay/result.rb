module PirateBay
  class Result
    attr_accessor :id, :name, :seeds, :leeches, :category, :link, :magnet_link, :status, :size

    def initialize(row = nil)
      if row.css("td")[1].css("img[alt='Trusted']").size > 0
        status = "Trusted"
      elsif row.css("td")[1].css("img[alt='VIP']").size > 0
        status = "VIP"
      else
        status = nil
      end

      magnet_links = row.css("td")[1].css("a[title='Download this torrent using magnet']")
      if magnet_links.size > 0
        magnet_link = magnet_links.first[:href]
      else
        magnet_link = nil
      end

      self.id = row.inner_html.match(/torrent\/([\d]+)\//)[1]
      self.name = row.css(".detName").first.content.strip
      self.seeds = row.css("td")[2].content.to_i
      self.leeches = row.css("td")[3].content.to_i
      self.category = row.css("td")[0].css("a").map(&:content).join(" > ")
      self.link = "https://torrents.#{PirateBay::Search::TPB_HOST}/#{id}/#{name}.torrent" 
      self.magnet_link = magnet_link
      self.status = status

      raw_filesize = row.css(".detDesc").first.content.match(/Size (.*[G|M|K]iB)/i)[1]
      self.size = filesize_in_bytes(raw_filesize)

    end

    def to_s
      "<PirateBay::Result @name => #{name}, @seeds => #{seeds}, @size => #{size}>"
    end
    
    def filesize_in_bytes(filesize)
      match = filesize.match(/([\d.]+)(.*)/)

      if match
        raw_size = match[1].to_f

        case match[2].strip
          when /gib/i then
            raw_size * 1000000000
          when /mib/i then
            raw_size * 1000000
          when /kib/i then
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
