module Pixiv
  class WorkList < OwnedIllustList
    # (see super.url)
    def self.url(member_id, page = 1)
      "#{ROOT_URL}/member_illust.php?id=#{member_id}&p=#{page}"
    end

    # @return [Integer]
    lazy_attr_reader(:total_count) {
      node = at!('.layout-cell .count-badge')
      node.inner_text.match(/\d+/).to_s.to_i
    }
    # @return [Array<Hash{Symbol=>Object}, nil>]
    lazy_attr_reader(:page_hashes) {
      search!('.display_works li').map {|n| hash_from_list_item(n) }
    }

    private

    # @param [Nokogiri::XML::Node] node
    # @return [Hash{Symbol=>Object}] illust_hash
    def hash_from_list_item(node)
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
end