require 'mechanize'
require 'pixiv/error'
require 'pixiv/client'
require 'pixiv/page'
require 'pixiv/illust'
require 'pixiv/member'
require 'pixiv/page_collection'
require 'pixiv/bookmark_list'
require 'pixiv/illust_list'

module Pixiv
  ROOT_URL = 'http://www.pixiv.net'

  # @deprecated Use {.client} instead. Will be removed in 0.1.0.
  # Delegates to {Pixiv::Client#initialize}
  def self.new(*args, &block)
    Pixiv::Client.new(*args, &block)
  end

  # See {Pixiv::Client#initialize}
  # @return [Pixiv::Client]
  def self.client(*args, &block)
    Pixiv::Client.new(*args, &block)
  end
end
