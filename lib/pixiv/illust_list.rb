module Pixiv
  # FIXME: IllustList should be parent of BookmarkList
  class IllustList < BookmarkList
    include PageCollection

    def self.url(member_id, page_num = 1)
      "#{ROOT_URL}/member_illust.php?id=#{member_id}&p=#{page_num}"
    end

    # @return [Integer]
    lazy_attr_reader(:count) {
      at!('.layout-cell .count-badge').inner_text.match(/^\d+/).to_s.to_i
    }

    private

    # FIXME: rename to ..._list_item
    def illust_hash_from_bookmark_item(node)
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