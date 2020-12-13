def get_post_content
  table = CSV.parse(File.read("post_id.csv"), headers: false)
  post_content = []
  total = 0
  table.each do |line|
    begin
      sleep(0.1)
      total += 1
      puts "-------No.#{total}--------"
      puts "#{line[0]}"
      puts ""
      url = "https://www.dcard.tw/_api/posts/#{line[0]}"
      uri = URI(url)
      data = Net::HTTP.get(uri)
      items = JSON.parse(data)
      post_content << [items["id"], items["content"], items["title"], items["createdAt"], items["updatedAt"], items["commentCount"], items["likeCount"], items["gender"]]
    rescue => e
      puts "==========================================="
      puts "error type=#{e.class}, message=#{e.message}"
      puts "==========================================="
    end
  end

  File.write("post_content.csv", post_content.map(&:to_csv).join)
end