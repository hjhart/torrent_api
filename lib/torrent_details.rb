require 'rubygems'
require 'nokogiri'

class TorrentDetails
  def initialize(html)
    @html = html
  end
  
  def scores
    document = Nokogiri::HTML(@html)
    ratings = document.css('div.comment').map { |comment|
      TorrentDetails.search_for_ratings(comment.inner_html)
    }
    ratings.reject { |r| r.empty? }
  end
  
  def self.search_for_ratings string
    video_score_matches = string.match(/(v|video) ?[:\=-]? ?([0-9]{1,2})/i)
    audio_score_matches = string.match(/(a|audio) ?[:\=-]? ?([0-9]{1,2})/i)
    ratings = {}
    ratings[:v] = video_score_matches[2].to_i unless video_score_matches.nil?
    ratings[:a] = audio_score_matches[2].to_i unless audio_score_matches.nil?
    # puts "Incoming string of #{string} detected ratings of #{ratings}"
    ratings
  end
  
  def video_quality_average
    video_scores = scores.map { |score| score[:v] }.compact
    sum_of_video_scores = video_scores.inject(0) { |score, memo| memo += score }
    # puts "Sum #{sum_of_video_scores} / #{video_scores.size}  #{sum_of_video_scores / video_scores.size}"
    sum_of_video_scores / video_scores.size.to_f
  end
  
  def audio_quality_average
    audio_scores = scores.map { |score| score[:a] }.compact
    sum_of_audio_scores = audio_scores.inject(0) { |score, memo| memo += score }
    sum_of_audio_scores / audio_scores.size.to_f
  end
  
  
end