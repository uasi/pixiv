module Pixiv
  class BookmarkList < OwnedIllustList
    # (see super.url)
    def self.url(member_id, page = 1)
      "#{ROOT_URL}/bookmark.php?id=#{member_id}&rest=show&p=#{page}"
    end

    # @return [Integer]
    lazy_attr_reader(:total_count) {
      node = at!('a[href="/bookmark.php?type=illust_all"]')
      node.inner_text[/\d+/].to_i
    }
    # @return [Array<Hash{Symbol=>Object}, nil>]
    lazy_attr_reader(:page_hashes) {
      search!('li[id^="li_"]').map {|n| hash_from_list_item(n) }
    }

    # @deprecated Use {#total_count} instead.
    alias bookmarks_count total_count

    private

    # @param [Nokogiri::XML::Node] node
    # @return [Hash{Symbol=>Object}] illust_hash
    def hash_from_list_item(node)
      return nil if node.at('img[src*="limit_unknown_s.png"]')
      member_node = node.at('a[href^="member_illust.php?id="]')
      illust_node = node.at('a')
      illust_id = illust_node['href'][/illust_id=(\d+)/, 1].to_i
      {
        url: Illust.url(illust_id),
        illust_id: illust_id,
        title: illust_node.inner_text,
        member_id: member_node['href'][/\?id=(\d+)/, 1].to_i,
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
end
