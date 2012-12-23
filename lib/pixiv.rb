require 'mechanize'
require 'pixiv/error'
require 'pixiv/client'
require 'pixiv/page'
require 'pixiv/illust'
require 'pixiv/member'
require 'pixiv/page_collection'
require 'pixiv/bookmark_list'

module Pixiv
  ROOT_URL = 'http://www.pixiv.net'

  def self.new(*args, &block)
    Pixiv::Client.new(*args, &block)
  end
end
