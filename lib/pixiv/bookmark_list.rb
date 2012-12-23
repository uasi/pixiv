module Pixiv
  class BookmarkList < Page
    include PageCollection

    def self.url(member_id, page_num = 1)
      "#{ROOT_URL}/bookmark.php?id=#{member_id}&rest=show&p=#{page_num}"
    end

    lazy_attr_reader(:page_num) { at!('li.pages-current').inner_text.to_i }
    lazy_attr_reader(:last?) { at!('li.pages-current').next_element.inner_text.to_i == 0 }
    lazy_attr_reader(:member_id) { doc.body.match(/pixiv\.context\.userId = '(\d+)'/).to_a[1].to_i }
    lazy_attr_reader(:illust_ids) { search!('li[id^="li_"] a[href^="member_illust.php?mode=medium"]').map {|n| n.attr('href').match(/illust_id=(\d+)$/).to_a[1].to_i } }
    lazy_attr_reader(:illust_hash) {
      search!('li[id^="li_"]').map {|node| illust_hash_from_bookmark_item(node) }.compact
    }

    alias page_hashes illust_hash

    def url; self.class.url(member_id, page_num) end
    def first?; page_num == 1 end
    def next_url; last? ? nil : self.class.url(member_id, page_num + 1) end
    def prev_url; first? ? nil : self.class.url(member_id, page_num - 1) end
    def page_class; Illust end
    def page_urls; illust_ids.map {|illust_id| Illust.url(illust_id) } end

    private

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
        small_image_url: illust_node.at('img').attr('src'),
      }
    end
  end
end
