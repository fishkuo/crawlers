def mv_files
  table = CSV.parse(File.read("forums.csv"), headers: false)
  f = table[0.1]
  Dir.mkdir("#{f[0]}")
  FileUtils.mv('post_id.csv', "#{f[0]}/")
  FileUtils.mv('post_content.csv', "#{f[0]}/")
  FileUtils.mv('post_comment_new.csv', "#{f[0]}/")
  end


