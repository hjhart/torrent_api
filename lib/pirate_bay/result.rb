module PirateBay
  class Result
    attr_accessor :name, :seeds, :leeches, :category, :link, :magnet_link, :status, :size

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

      self.name = row.css(".detName").first.content
      self.seeds = row.css("td")[2].content.to_i
      self.leeches = row.css("td")[3].content.to_i
      self.category = row.css("td")[0].css("a").map(&:content).join(" > ")
      self.link = row.css("td")[1].css("a[title='Download this torrent']").first[:href]
      self.magnet_link = magnet_link
      self.status = status
      self.size = row.css(".detDesc").first.content.match(/Size (.*[G|M|K]iB)/i)[1]

    end

    def to_s
      "<PirateBay::Result @name => #{name}, @seeds => #{seeds}, @category => #{category}>"
    end
  end
end