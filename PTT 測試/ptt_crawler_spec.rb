require "./ptt_crawler"

RSpec.describe PttCrawler do
  let(:crawler){PttCrawler.new}

  describe "get 熱門看板的 url" do
    it "receive 200 response when http request is sent" do 
      expect(crawler.http_status("https://www.ptt.cc/bbs/hotboards.html")).to eq "200"
    end 

    it "get board urls and save to csv(csv file should not be empty)" do 
      crawler.get_board_url
      expect(crawler.check_csv("board_url.csv")).to eq false
    end 
  end
 
  describe "get 熱門看板的 post" do
    it "be able to enter boards that require user to be over 18" do 
      expect(crawler.over_18("https://www.ptt.cc//bbs/Gossiping/index.html")).to eq true
    end 

    it "loop through board urls and save post url to csv(csv file should not be empty)" do 
      crawler.get_post_url("board_url.csv", ["1/14"])
      expect(crawler.check_csv("post_url.csv")).to eq false
    end

    it "date condition successfully implemented(all post date should be in date range)" do 
      expect(crawler.post_date("post_url", ["1/14"])).to eq true
    end 
  end

  describe "get 熱門看板的 post content 和 post comment" do 

    it "get post - alias, url, title, author, created_at, content, comment_count" do 
      expect(crawler.get_post_content("post_url.csv")).to eq true
    end 

    it "csv that stores post content should not be empty" do 

    end 
  end 

  describe "get 熱門看板的 post comment" do 

    it "get comment alias, pid, cid, url, title, author, created_at, content" do 

    end 

    it "csv that stores post content should not be empty" do 

    end 
  end 
end