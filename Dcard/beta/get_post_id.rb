def get_post_id(board, content_cut)
  table = CSV.parse(File.read("forums.csv"), headers: false)

  current_table = table["#{board}".to_i.."#{board}".to_i]

  all_post_id = []
  current_table.each do |line|
    puts "=============#{board + 1}.#{line[0]}============" # print board name
    url = line[2]
    uri = URI(url)
    data = Net::HTTP.get(uri)
    items = JSON.parse(data)

    forum_post_id = []
    count = 0
    last_id = 0
    total_cnt = 0
    e = 0

    items.each do |item|
      # break if item
      begin
        sleep(0.1)
        forum_post_id << [item["id"], item["title"], item["forumName"], item["forumAlias"]]
        count += 1
        total_cnt += 1
        puts total_cnt, "----------#{item["title"]}" # print how much board and board name
        if count == 30
          last_id = item["id"]
          count = 0
        end
      rescue => e
        puts "==========================================="
        puts "error type=#{e.class}, message=#{e.message}"
        puts "==========================================="
      end
      break if total_cnt == content_cut #break when reach setting
      break if e.class == TypeError
    end
    while true
      break if total_cnt == content_cut #break when reach setting
      break if e.class == TypeError
      url = "#{line[2]}&before=#{last_id}"
      uri = URI(url)
      data = Net::HTTP.get(uri)
      items = JSON.parse(data)

      if items.size < 30
        items.each do |item|
          begin
            total_cnt += 1
            sleep(0.1)
            puts total_cnt, "-----------#{item["title"]}"
            forum_post_id << [item["id"], item["title"], item["forumName"], item["forumAlias"]]
          rescue => e
            puts "==========================================="
            puts "error type=#{e.class}, message=#{e.message}"
            puts "==========================================="
          end
        end
        break
      else
        break if e.class == TypeError
        break if total_cnt == content_cut #break when reach setting
        count = 0
        items.each do |item|
          begin
            sleep(0.1)
            forum_post_id << [item["id"], item["title"], item["forumName"], item["forumAlias"]]
            count += 1
            total_cnt += 1
            puts total_cnt, "-----------#{item["title"]}"
            if count == 30
              last_id = item["id"]
              count = 0
            end
          rescue => e
            puts "==========================================="
            puts "error type=#{e.class}, message=#{e.message}"
            puts "==========================================="
          end
          break if e.class == TypeError
          break if total_cnt == content_cut
        end
      end
    end
    all_post_id += forum_post_id
  end

  File.write("post_id.csv", all_post_id.map(&:to_csv).join)
end
