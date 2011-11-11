require 'torrent_api'

describe TorrentDetails do
  describe "#scores" do
    it "should parse the page for scores and return an array of them" do
      html = File.open(File.join('spec', 'fixtures' , 'torrent_details_with_ratings.html'), 'r').read
      tp = TorrentDetails.new html
      tp.scores.should =~ [{:a => 10, :v => 10}, {:a => 8, :v => 9}, {:a => 10, :v => 10}, {:a => 10, :v => 10}, { :v => 8 }, {:a => 10, :v => 10}, {:a => 10, :v => 10}, {:a => 10, :v => 10} ]
    end

    it "should parse the page for scores and return an array of them" do
      html = File.open(File.join('spec', 'fixtures' , 'torrent_details_with_ratings_2.html'), 'r').read
      tp = TorrentDetails.new html
      tp.scores.should =~ [{ a: 8, v: 6 }, { a: 10, v:10 }, { v: 7, a: 9 }, { a: 10, v: 9 }, { a: 5, v: 5 }, { a: 9, v: 9 }, { a: 9, v: 6 }]
    end
  end
  
  describe ".search_for_ratings" do
    it "should detect a rating if it exists and return a hash" do
      ratings = TorrentDetails.search_for_ratings("Thanks man. <br>\nA: 10<br>\nV: 10<br>\nMovie: 100")
      ratings.should == { a: 10, v: 10 }
    end
    
    it "should detect a string that states 'audio' and/or 'video' instead of A/V" do
      comment = "not in good quality\nAudio: 5\nVideo: 6"
      ratings = TorrentDetails.search_for_ratings comment
      ratings.should == { a: 5, v: 6 }
    end
  end
  
  describe "video_quality_average" do
    it "should take all of the ratings and average them together." do
      tp = TorrentDetails.new "fake html"
      averages = tp.should_receive(:scores).twice.and_return [{:a => 10, :v => 10}, {:a => 8, :v => 9}, { :a => 4 }, { :a => 3 }, { :v => 5 }]
      tp.video_quality_average.should == 8
      tp.audio_quality_average.should == 6.25
    end
  end  
end