module Pixiv
  class BookmarkList < Page
    include PageCollection

    # Returns the URL for given +member_id+ and +page_num+
    # @param [Integer] member_id
    # @param [Integer] page_num
    # @return [String]
    def self.url(member_id, page_num = 1)
      "#{ROOT_URL}/bookmark.php?id=#{member_id}&rest=show&p=#{page_num}"
    end

    # @return [Integer]
    lazy_attr_reader(:count) { at!('a[href="/bookmark.php?type=illust_all"]').inner_text.match(/(\d+)/).to_a[1].to_i }
    # @return [Integer]
    lazy_attr_reader(:page_num) { at!('li.pages-current').inner_text.to_i }
    # @return [Boolean]
    lazy_attr_reader(:last?) { at!('li.pages-current').next_element.inner_text.to_i == 0 }
    # @return [Integer]
    lazy_attr_reader(:member_id) { doc.body.match(/pixiv\.context\.userId = '(\d+)'/).to_a[1].to_i }
    # @return [Array<Integer>]
    lazy_attr_reader(:illust_ids) { search!('li[id^="li_"] a[href^="member_illust.php?mode=medium"]').map {|n| n['href'].match(/illust_id=(\d+)$/).to_a[1].to_i } }
    # @return [Array<Hash{Symbol=>Object}, nil>]
    lazy_attr_reader(:illust_hashes) {
      search!('li[id^="li_"]').map {|node| illust_hash_from_bookmark_item(node) }
    }

    # @deprecated Use {#count} instead.
    alias bookmarks_count count
    alias page_hashes illust_hashes

    # @return [String]
    def url; self.class.url(member_id, page_num) end
    # @return [Boolean]
    def first?; page_num == 1 end
    # @return [String]
    def next_url; last? ? nil : self.class.url(member_id, page_num + 1) end
    # @return [String]
    def prev_url; first? ? nil : self.class.url(member_id, page_num - 1) end
    # @return [Class<Pixiv::Page>]
    def page_class; Illust end
    # @return [Array<String>]
    def page_urls; illust_ids.map {|illust_id| Illust.url(illust_id) } end

    private

    # @param [Nokogiri::HTML::Node] node
    # @return [Hash{Symbol=>Object}] illust_hash
    def illust_hash_from_bookmark_item(node)
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
    def self.url(member_id, page_num = 1)
      "#{ROOT_URL}/bookmark.php?id=#{member_id}&rest=hide&p=#{page_num}"
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
