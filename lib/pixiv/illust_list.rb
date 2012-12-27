module Pixiv
  # @abstract
  class IllustList < Page
    # @!parse
    # include ::Pixiv::IllustList::WithClient

    include ::Pixiv::PageCollection

    def doc
      unless @doc
        super
        check_bounds!
      end
      @doc
    end

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

    protected

    def check_bounds!
      max_page = total_count / max_size + 1
      raise Error::OutOfBounds unless (1..max_page).include?(page)
    end
  end

  module IllustList::WithClient
    include ::Pixiv::Page::WithClient
    include ::Enumerable

    # @yieldparam [Illust] illust
    def each
      illust_hashes.each do |attrs|
        url = attrs.delete(:url)
        yield Illust.lazy_new(attrs) { client.agent.get(url) }
      end
    end

    # @return [Illust, nil]
    def next
      return if last?
      self.class.lazy_new(next_attrs) { client.agent.get(next_url) }
    end

    def prev
      return if first?
      self.class.lazy_new(next_attrs) { client.agent.get(prev_url) }
    end
  end
end
