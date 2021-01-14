require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'csv'
# require 'vcr'

class PttCrawler
  def http_status(url)
    uri = URI(url)
    res = Net::HTTP.get_response(uri)
    puts res.code
    return res.code 
  end 

  def get_board_url
    url = 'https://www.ptt.cc/bbs/hotboards.html'
    doc = Nokogiri::HTML(open( url ))

    boards = doc.xpath( '//*[@id="main-container"]/div[2]/div[1]/a').xpath("//@href")

    url = []
    # 第十個url開始才是版的url
    boards[10..boards.length].each do |x|
      url << ["https://www.ptt.cc/#{x.value}"]
    end

    File.write("board_url.csv", url.map(&:to_csv).join)
  end 

  def check_csv(file)
    result = File.zero?(file)
    return result
  end 

  def over_18(url)
    doc = Nokogiri::HTML(open(url,'Cookie' => 'over18=1'))
    return !doc.search(".over18-notice").nil?
  end 

  def get_post_url(board_csv, date_array)
    table = CSV.parse(File.read(board_csv), headers: false)
    pre_url = "https://www.ptt.cc"
    post_url_all = []
  
    table.each do |t|
      sleep(rand(0.5..1.2))
      next_url = t[0]
      p next_url
      post_url = []

      # 每個版的index頁面因為有置底文所以另外判斷
      doc = Nokogiri::HTML(open(next_url,'Cookie' => 'over18=1'))
      num = doc.search("#main-container .r-list-container .r-ent").size 
      (num-1).downto(0).each { |i|
      next unless date_array.include?(doc.css("#main-container .r-list-container .r-ent .meta .date")[i].text.strip)
      next if doc.css("#main-container .r-list-container .r-ent .title a")[i]["href"].nil?
      post_url << [doc.css("#main-container .r-list-container .r-ent .meta .date")[i].text.strip, doc.css("#main-container .r-list-container .r-ent .meta .author")[i].text,pre_url + doc.css("#main-container .r-list-container .r-ent .title a")[i]["href"]]
      }

      next_url = pre_url + doc.css("#main-container .btn-group .wide:nth-child(2)")[0]["href"]
      p next_url
      while true 
        doc = Nokogiri::HTML(open(next_url,'Cookie' => 'over18=1'))
        num = doc.search("#main-container .r-list-container .r-ent").size 
        break unless date_array.include?(doc.css("#main-container .r-list-container .r-ent .meta .date")[num-1].text.strip)
  
        (num-1).downto(0).each { |i| 
          next if doc.css("#main-container .r-list-container .r-ent .title a")[i].nil?
          next if doc.css("#main-container .r-list-container .r-ent .meta .author")[i].text == "-"
          next unless date_array.include?(doc.css("#main-container .r-list-container .r-ent .meta .date")[i].text.strip)
          post_url << [doc.css("#main-container .r-list-container .r-ent .meta .date")[i].text.strip, doc.css("#main-container .r-list-container .r-ent .meta .author")[i].text,pre_url + doc.css("#main-container .r-list-container .r-ent .title a")[i]["href"]]
          p doc.css("#main-container .r-list-container .r-ent .meta .author")[i].text
        }
        next_url = pre_url + doc.css("#main-container .btn-group .wide:nth-child(2)")[0]["href"]
        p "next page   #{next_url}"
      end 
      post_url_all << post_url
    end 
  
    File.write("post_url.csv", post_url_all.flatten(1).map(&:to_csv).join)
  end

  def get_post_content(post_csv)
    table = CSV.parse(File.read(post_csv), headers: false)
  
    all_post = []
    all_comment = []
    
    table.each do |x|
      sleep(rand(0.5..1.2))
      url = x[2]

      # p url
      begin 
        doc = Nokogiri::HTML(open(url,'Cookie' => 'over18=1'))
        # board 
        board = doc.xpath('//*[@id="topbar"]/a[2]').text

        # post_url
        post_url = url

        # post author 
        post_author = doc.xpath('//*[@id="main-content"]/div[1]/span[2]').text

        # post title 
        post_title = doc.xpath('//*[@id="main-content"]/div[3]/span[2]').text

        # post time
        created_at = doc.xpath('//*[@id="main-content"]/div[4]/span[2]').text

        # post content
        post_content = doc.xpath('//*[@id="main-content"]/text()').text

        # comment count 
        comment_count = 0
        comment_count = doc.css("#main-container .bbs-content .push").count if not doc.css("#main-container .bbs-content .push").nil?
  
        all_post <<  [board, post_url,post_author, post_title, created_at, comment_count, post_content]
        
  
        if doc.css("#main-container .bbs-content .push").nil?
          comment_count = 0
        else
          comment_count = doc.css("#main-container .bbs-content .push").count
          # all post comment
          doc.css("#main-container .bbs-content .push").each do |comment|
            sleep(rand(0.1..0.5))
            # board
            board = doc.xpath('//*[@id="topbar"]/a[2]').text
            # post_url
            post_url = url
            # post comment author 
            comment_author = comment.css(".push-userid").text
            # post comment time
            comment_created_at = comment.css(".push-ipdatetime").text
            # comment content 
            comment_content = comment.css(".push-content").text
      
            all_comment << [board, post_url, comment_author, comment_created_at, comment_content]
          end 
        end
      rescue 
        next
      end
    end 
    
    File.write("post_content.csv", all_post)
    File.write("comment_content.csv", all_comment)
  end 

  # def post_date(post_csv,date_array)
  #   table = CSV.parse(File.read(post_csv), headers: false)
  #   table.each do |t|
  #     p t
  #   end 
  #   return true 
  # end 


end