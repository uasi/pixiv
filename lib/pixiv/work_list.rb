module Pixiv
  class WorkList < IllustList
    def self.url(member_id, page = 1)
      "#{ROOT_URL}/member_illust.php?id=#{member_id}&p=#{page}"
    end

    # @return [Integer]
    lazy_attr_reader(:page) {
      at!('li.pages-current').inner_text.to_i
    }
    # @return [Integer]
    lazy_attr_reader(:count) {
      node = at!('.layout-cell .count-badge')
      node.inner_text.match(/\d+/).to_s.to_i
    }
    # @return [Boolean]
    lazy_attr_reader(:last?) {
      at!('li.pages-current').next_element.inner_text.to_i == 0
    }
    # @return [Array<Hash{Symbol=>Object}, nil>]
    lazy_attr_reader(:page_hashes) {
      search!('.display_works li').map {|n| hash_from_list_item(n) }
    }
    # @return [Integer]
    lazy_attr_reader(:member_id) {
      doc.body.match(/pixiv\.context\.userId = '(\d+)'/).to_a[1].to_i
    }

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
  class WorkList::WithClient < BookmarkList::WithClient
  end
end