module Pixiv
  # FIXME: IllustList should be parent of BookmarkList
  class IllustList < BookmarkList
    include PageCollection

    def self.url(member_id, page_num = 1)
      "#{ROOT_URL}/member_illust.php?id=#{member_id}&p=#{page_num}"
    end

    # @return [Integer]
    lazy_attr_reader(:count) {
      at!('.layout-cell .count-badge').inner_text.match(/\d+/).to_s.to_i
    }
    # @return [Array<Integer>]
    lazy_attr_reader(:illust_ids) {
      search!('.display_works li a').map {|n| n['href'].match(/illust_id=(\d+)$/).to_a[1].to_i }
    }
    # @return [Array<Hash{Symbol=>Object}, nil>]
    lazy_attr_reader(:illust_hashes) {
      search!('.display_works li').map {|node| illust_hash_from_list_item(node) }
    }

    private

    def illust_hash_from_list_item(node)
      return nil if node.at('img[src*="limit_unknown_s.png"]')
      illust_node = node.at('a')
      illust_id = illust_node['href'].match(/illust_id=(\d+)/).to_a[1].to_i
      {
          url: Illust.url(illust_id),
          illust_id: illust_id,
          title: illust_node.inner_text,
          member_id: member_id,
          small_image_url: illust_node.at('img')['src'],
      }
    end
  end

  # FIXME: This should be parent of that
  class IllustList::WithClient < BookmarkList::WithClient
  end
end