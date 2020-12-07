# 二、每個forum的post_id_url一次只能顯示30筆post_id，所以要抓三十筆裡面最後一個id再往url加上before繼續往下抓，抓到沒有下一頁才停

def get_post_id
  table = CSV.parse(File.read("forums.csv"), headers: false)

  # 先試1個版而已～
  table = table[0...1]

  all_post_id = []
  table.each do |line|
    p "=============#{line[0]}============" # print board name 
    url = line[2]
    uri = URI(url)
    data = Net::HTTP.get(uri)
    items = JSON.parse(data)

    forum_post_id = []
    count = 0
    last_id = 0

    items.each do |item|
      sleep(0.5)
      forum_post_id << [item["id"],item["title"],item["forumName"], item["forumAlias"]]
      count += 1
      p count, "第一頁"
      if count == 30 
        last_id = item["id"]
        count = 0
      end
    end

    while true
      url = "#{line[2]}&before=#{last_id}" 
      uri = URI(url)
      data = Net::HTTP.get(uri)
      items = JSON.parse(data)

      if items.size < 30 
        items.each do |item|
          sleep(0.5)
          p "最後一頁"
          forum_post_id << [item["id"],item["title"],item["forumName"], item["forumAlias"]]
        end 
        break
      else 
        count = 0
        items.each do |item|
          sleep(0.4)
          forum_post_id << [item["id"],item["title"],item["forumName"], item["forumAlias"]]
          count += 1
          p count, "後面還有"
          if count == 30 
            last_id = item["id"]
            count = 0
          end
        end
      end 
    end
    all_post_id += forum_post_id 
  end

  File.write("post_id.csv", all_post_id.map(&:to_csv).join)
end 