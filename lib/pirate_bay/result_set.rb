module PirateBay
  class ResultSet < Array
    attr_accessor :total_results, :search

    def initialize(initializer)
      self.search = initializer
      self.total_results = 1.0/0 #Infinity
    end

    def retrieved_results
      self.size
    end

    def more
      search.next_page
    end
  end
end