require 'torrent_api'

describe PirateBay::Details do
  describe "#scores" do
    it "should parse the page for scores and return an array of them" do
      html = File.open(File.join('spec', 'fixtures' , 'torrent_details_with_ratings.html'), 'r').read
      tp = PirateBay::Details.new html, :init
      expect(tp.scores).to match_array [
        {:a => 10.0, :v => 10.0}, 
        {:a => 8.0, :v => 9.0}, 
        {:a => 10.0, :v => 10.0}, 
        {:a => 10.0, :v => 10.0}, 
        { :v => 8.0 }, 
        {:a => 10.0, :v => 10.0}, 
        {:a => 10.0, :v => 10.0}, 
        {:a => 10.0, :v => 10.0}
     ]
    end

    it "should parse the page for scores and return an array of them" do
      html = File.open(File.join('spec', 'fixtures' , 'torrent_details_with_ratings_2.html'), 'r').read
      tp = PirateBay::Details.new html, :init
      expect(tp.scores).to match_array [{ a: 8, v: 6 }, { a: 10, v:10 }, { v: 7, a: 9 }, { a: 10, v: 9 }, { a: 5, v: 5 }, { a: 9, v: 9 }, { a: 9, v: 6 }]
    end
  end
  
  describe ".search_for_ratings" do
    it "should detect a rating if it exists and return a hash" do
      ratings = PirateBay::Details.search_for_ratings("Thanks man. <br>\nA: 10<br>\nV: 10<br>\nMovie: 100")
      expect(ratings).to eq({ a: 10.0, v: 10.0 })
    end
    
    it "should detect a string that states 'audio' and/or 'video' instead of A/V" do
      comment = "not in good quality\nAudio: 5\nVideo: 6"
      ratings = PirateBay::Details.search_for_ratings comment
      expect(ratings).to eq({ a: 5.0, v: 6.0 })
    end
    
    it "should not accept an entry that isn't between 0 and 10" do
      comment = "such good quality\nAudio: 56\nVideo: 6"
      ratings = PirateBay::Details.search_for_ratings comment
      expect(ratings).to eq({ v: 6.0 })
    end
    
    it "should be able to detect tenth's of a point" do
      comment = "such good quality\nAudio: 5.6\nVideo: 6"
      ratings = PirateBay::Details.search_for_ratings comment
      expect(ratings).to eq({ v: 6.0, a: 5.6 })
    end
    
  end
  
  describe "video_quality_average" do
    it "should take all of the ratings and average them together." do
      tp = PirateBay::Details.new "fake html"
      averages = expect(tp).to receive(:scores).exactly(4).times.and_return [{:a => 10, :v => 10}, {:a => 8, :v => 9}, { :a => 4 }, { :a => 3 }, { :v => 5 }]
      expect(tp.video_quality_average).to eq 8
      expect(tp.audio_quality_average).to eq 6.25
    end

    it "it should never return NaN" do
      tp = PirateBay::Details.new "fake html"
      averages = expect(tp).to receive(:scores).exactly(4).times.and_return []
      expect(tp.video_quality_average).to eq 0
      expect(tp.audio_quality_average).to eq 0
    end
  end  
  
  describe "extract xhr parameters" do
    it "should extract parameters from a string" do
      string = "comPage(2,3,'9871b996d3b1cf408dc66c70816fc51c', '6742330'); return false;"
      expected_params = { page: 2, pages: 3, crc: '9871b996d3b1cf408dc66c70816fc51c', id: '6742330' }
      expect(PirateBay::Details.extract_xhr_params(string)).to eq expected_params
    end
  end
      
  describe "comment_xhr_params" do
    it "should parse the file for links and return an array of post options" do
      html = File.open(File.join('spec', 'fixtures' , 'torrent_details_with_ratings.html'), 'r').read
      tp = PirateBay::Details.new html
      links = tp.comment_xhr_params
      expect(links).to match_array [{ page: 1, pages: 3, crc: "9871b996d3b1cf408dc66c70816fc51c", id: "6742330" },{ page: 2, pages: 3, crc: "9871b996d3b1cf408dc66c70816fc51c", id: "6742330" }, { page: 3, pages: 3, crc: "9871b996d3b1cf408dc66c70816fc51c", id: "6742330" }]
    end
  end  
  
  describe "fetch comments" do
    it "should make a request to the ajax comments url with the provided params" do
      tp = PirateBay::Details.new "fake html"
      expect(tp.instance_variable_get(:@comment_pages_html)).to eq []
      params = { page: 1, pages: 3, crc: "9871b996d3b1cf408dc66c70816fc51c", id: "6742330" }
      html = tp.fetch_comments params
      expect(tp.instance_variable_get(:@comment_pages_html)).to eq [html]      
    end
  end
end
