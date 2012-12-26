require 'mechanize'

module Pixiv
  autoload :PrivateBookmarkList, 'pixiv/bookmark_list'
  autoload :BookmarkList,        'pixiv/bookmark_list'
  autoload :Client,              'pixiv/client'
  autoload :Error,               'pixiv/error'
  autoload :Illust,              'pixiv/illust'
  autoload :IllustList,          'pixiv/work_list'
  autoload :Member,              'pixiv/member'
  autoload :Page,                'pixiv/page'
  autoload :PageCollection,      'pixiv/page_collection'

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
