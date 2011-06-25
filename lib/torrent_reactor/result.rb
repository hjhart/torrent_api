module TorrentReactor
  class Result
    attr_accessor :name, :seeds, :leeches, :category, :link, :magnet_link, :status, :size, :date

    def initialize(row = nil)
      link = ''
      date = row.search("/td[1]").inner_text
      title = row.search("/td[2]").inner_text.strip
      raw_filesize = row.search("/td[3]").inner_html
      seeders = row.search("/td[4]").inner_text.to_i
      row.search("/td[2] a").each { |b| link = b.get_attribute('href') if b.get_attribute('href') =~ /download\.php/ }
      leeches = row.search("/td[5]").inner_text.to_i

      size = TorrentReactor::Result.filesize_in_bytes(raw_filesize)

      self.date = date
      self.name = title
      self.link = link
      self.size = size
      self.seeds = seeders
      self.leeches = leeches

    end

    def to_s
      "<TorrentReactor::Result @name => #{name}, @seeds => #{seeds}, @size => #{size}...>"
    end

    def self.filesize_in_bytes(filesize)
      match = filesize.match(/([\d.]+)(.*)/)

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