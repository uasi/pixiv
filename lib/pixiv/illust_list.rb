module Pixiv
  # @abstract
  class IllustList < Page
    include PageCollection

    attr_reader :page
    attr_reader :total_count

    def page_class
      Page
    end

    alias illust_hashes page_hashes
    alias illust_urls page_urls
  end

  module IllustList::WithClient
    include Page::WithClient
    include Enumerable

    def each
      illust_hashes.each do |attrs|
        url = attrs.delete(:url)
        yield Illust.lazy_new(attrs) { client.agent.get(url) }
      end
    end
  end
end