module Pixiv
  class BookmarkList < IllustList
    # Returns the URL for given +member_id+ and +page+
    # @param [Integer] member_id
    # @param [Integer] page
    # @return [String]
    def self.url(member_id, page = 1)
      "#{ROOT_URL}/bookmark.php?id=#{member_id}&rest=show&p=#{page}"
    end

    # @return [Integer]
    lazy_attr_reader(:page) {
      at!('li.pages-current').inner_text.to_i
    }
    # @return [Integer]
    lazy_attr_reader(:count) {
      node = at!('a[href="/bookmark.php?type=illust_all"]')
      node.inner_text.match(/\d+/).to_s.to_i
    }
    # @return [Boolean]
    lazy_attr_reader(:last?) {
      at!('li.pages-current').next_element.inner_text.to_i == 0
    }
    # @return [Array<Hash{Symbol=>Object}, nil>]
    lazy_attr_reader(:page_hashes) {
      search!('li[id^="li_"]').map {|n| hash_from_list_item(n) }
    }
    # @return [Integer]
    lazy_attr_reader(:member_id) {
      doc.body.match(/pixiv\.context\.userId = '(\d+)'/).to_a[1].to_i
    }

    # @deprecated Use {#count} instead.
    alias bookmarks_count count

    # @return [String]
    def url
      self.class.url(member_id, page)
    end

    # @return [Boolean]
    def first?
      page == 1
    end

    # @return [String]
    def next_url
      last? ? nil : self.class.url(member_id, page + 1)
    end

    # @return [String]
    def prev_url
      first? ? nil : self.class.url(member_id, page - 1)
    end

    private

    # @param [Nokogiri::XML::Node] node
    # @return [Hash{Symbol=>Object}] illust_hash
    def hash_from_list_item(node)
      return nil if node.at('img[src*="limit_unknown_s.png"]')
      member_node = node.at('a[href^="member_illust.php?id="]')
      illust_node = node.at('a')
      illust_id = illust_node['href'].match(/illust_id=(\d+)/).to_a[1].to_i
      {
        url: Illust.url(illust_id),
        illust_id: illust_id,
        title: illust_node.inner_text,
        member_id: member_node['href'].match(/\?id=(\d+)/).to_a[1].to_i,
        member_name: member_node.inner_text,
        small_image_url: illust_node.at('img')['src'],
      }
    end
  end

  class PrivateBookmarkList < BookmarkList
    # (see super.url)
    def self.url(member_id, page = 1)
      "#{ROOT_URL}/bookmark.php?id=#{member_id}&rest=hide&p=#{page}"
    end
  end

  class BookmarkList::WithClient
    include Page::WithClient

    # @return [Pixiv::Member]
    def member
      client.member(member_id)
    end

    # @return [Pixiv::PageCollection::Enumerator]
    def bookmarks
      client.bookmarks(self)
    end
  end

  class PrivateBookmarkList::WithClient < BookmarkList::WithClient; end
end
