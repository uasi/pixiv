module Pixiv
  # @abstract
  class IllustList < Page
    include PageCollection

    # @return [Integer]
    attr_reader :page
    # @return [Integer]
    attr_reader :total_count

    def page_class
      Illust
    end

    # Don't just do `alias illust_hashes page_hashes`;
    # the illust_hashes intends to call the page_hashes
    # overridden in a subclass.

    # An array of illust attrs extracted from doc
    # @return [Array<{Symbol=>Object}, nil>]
    def illust_hashes
      page_hashes
    end

  module IllustList::WithClient
    include Page::WithClient
    include Enumerable

    # @yieldparam [Illust] illust
    def each
      illust_hashes.each do |attrs|
        url = attrs.delete(:url)
        yield Illust.lazy_new(attrs) { client.agent.get(url) }
      end
    end
  end
end