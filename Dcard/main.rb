require "net/http"
require "json"
require 'csv'
#
require("./get_forums.rb")
require("./get_post_id.rb")
require("./get_post_content.rb")
require("./get_post_comment.rb")


get_forums()
get_post_id()
get_post_content()
get_post_comment()
