module Pixiv
  class WorkList < OwnedIllustList
    # (see super.url)
    def self.url(member_id, page = 1)
      "#{ROOT_URL}/member_illust.php?id=#{member_id}&p=#{page}"
    end

    # @return [Integer]
    lazy_attr_reader(:total_count) {
      node = at!('.layout-cell .count-badge')
      node.inner_text[/\d+/].to_i
    }
    # @return [String, nil] member_name
    #   member_name == nil if this work list is your own
    lazy_attr_reader(:member_name) {
      node = doc.at('.profile_area a')
      node && node['title']
    }
    # @return [Array<Hash{Symbol=>Object}, nil>]
    lazy_attr_reader(:page_hashes) {
      node = search!('.display_works li') \
        .xpath('self::node()[not(starts-with(a[1]/@href, "/bookmark"))]')
      node.map {|n| hash_from_list_item(n) }
    }

    private

    # @param [Nokogiri::XML::Node] node
    # @return [Hash{Symbol=>Object}] illust_hash
    def hash_from_list_item(node)
      return nil if node.at('img[src*="limit_unknown_s.png"]')
      illust_node = node.at('a')
      illust_id = illust_node['href'][/illust_id=(\d+)/, 1].to_i
      hash = {
          url: Illust.url(illust_id),
          illust_id: illust_id,
          title: illust_node.inner_text,
          member_id: member_id,
          small_image_url: illust_node.at('img')['src'],
      }
      hash[:member_name] = member_name if member_name
      hash
    end
  end
end
