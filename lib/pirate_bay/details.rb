require 'rubygems'
require 'nokogiri'
module PirateBay
  class Details
    def to_s
      "#<PirateBay::Details: @id=#{@id}>"
    end
  
    def initialize(html, type = :full)
      @details_page_html = html
      id_matches = html.match Regexp.new '<input type="hidden" name="id" value="(.*)"/>' rescue nil
      @id = id_matches[1].to_i unless id_matches.nil?
      @comment_pages_html = []
      @scores = []
      @type = type
    end
  
    def fetch_comments(params)
      index = params[:page] - 1
      if @comment_pages_html[index].nil?
        uri = URI.parse('http://thepiratebay.se/ajax_details_comments.php')
        res = Net::HTTP.post_form(uri, params)
        response = res.body
        @comment_pages_html[index] = response
      end
      @comment_pages_html[index]
    end
  
    def fetch_all_comments
      comment_xhr_params.each do |params|
        fetch_comments params
      end
    end
        
    def scores
      if @type == :full
        fetch_all_comments if @comment_pages_html.empty?
        full_html = @comment_pages_html.inject("") { |html, memo| memo += html }
        document = Nokogiri::HTML(full_html)
      else
        document = Nokogiri::HTML(@details_page_html)
      end
    
      scores = document.css('div.comment').map { |comment|
        PirateBay::Details.search_for_ratings(comment.inner_html)
      }
      @scores = scores.reject { |r| r.empty? }
    end
  
    def comment_xhr_params
      document = Nokogiri::HTML(@details_page_html)
      comment_link = document.css('div.browse-coms a').first
      if comment_link.nil?
        [{ :page => 1, :pages => 1, :crc => "9b235c98e242f2617ae61dc416ec0de7", :id => @id }]
      else
        params = PirateBay::Details.extract_xhr_params comment_link.attr('onclick')
        results = Array.new(params[:pages]) { |i| i+1 }
        results.map do |i|
          { :page => i, :pages => params[:pages], :crc => params[:crc], :id => params[:id] }
        end
      end
      
    end
  
    def self.extract_xhr_params(string)
      page, pages, crc, id = /comPage\((\d+),(\d+),'(.+)', '(.+)'\);/.match(string).captures
      page = page.to_i
      pages = pages.to_i
      { :page => page, :pages => pages, :crc => crc, :id => id }
    end
  
  
    def self.search_for_ratings string
      video_score_matches = string.match(/(v|video) ?[:\=-]? ?([0-9]\.[0-9]|[0-9]{1,2})/i)
      audio_score_matches = string.match(/(a|audio) ?[:\=-]? ?([0-9]\.[0-9]|[0-9]{1,2})/i)
      ratings = {}
      ratings[:v] = video_score_matches[2].to_f unless video_score_matches.nil?
      ratings[:a] = audio_score_matches[2].to_f unless audio_score_matches.nil?
      ratings.delete(:v) if ratings[:v] && ratings[:v] > 10
      ratings.delete(:a) if ratings[:a] && ratings[:a] > 10
      # puts "Incoming string of #{string} detected ratings of #{ratings}"
      ratings
    end

    def video_scores
      scores.map { |score| score[:v] }.compact
    end
    
    def video_quality_score_sum
      video_scores.inject(0) { |score, memo| memo += score }
    end
    
    def video_quality_average
      total_votes = [video_scores.size.to_f, 1].max
      video_quality_score_sum / total_votes
    end
    
    def audio_scores
      scores.map { |score| score[:a] }.compact
    end

    def audio_quality_score_sum
      audio_scores.inject(0) { |score, memo| memo += score }
    end
    
    def audio_quality_average
      total_votes = [audio_scores.size.to_f, 1].max.to_f
      audio_quality_score_sum / total_votes
    end
  end
end
