module Pixiv
  class Member < Page
    # Returns the URL for given +member_id+
    # @param [Integer] member_id
    # @return [String]
    def self.url(member_id)
      "#{ROOT_URL}/member.php?id=#{member_id}"
    end

    # @return [String]
    lazy_attr_reader(:name) { at!('.profile_area h2').inner_text }
    # @return [Integer]
    lazy_attr_reader(:member_id) { at!('input[name="user_id"]')['value'].to_i }
    # @return [Integer]
    lazy_attr_reader(:pixiv_id) { profile_image_url[%r{/profile/([a-z_-]+)/}, 1] }
    # @return [String]
    lazy_attr_reader(:profile_image_url) { at!('.profile_area img')['src'] }


    alias id member_id

    # @return [String]
    def url; self.class.url(member_id) end
  end

  module Member::WithClient
    include Page::WithClient

    # (see Pixiv::Client#bookmark_list)
    def bookmark_list(page_num = 1)
      client.bookmark_list(self, page_num)
    end

    # (see Pixiv::Client#bookmarks)
    def bookmarks(page_num = 1, &block)
      client.bookmarks(self, page_num, &block)
    end
  end
end
