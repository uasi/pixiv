module Pixiv
  class Member < Page
    # @!parse
    # include ::Pixiv::Member::WithClient

    # Returns the URL for given +member_id+
    # @param [Integer] member_id
    # @return [String]
    def self.url(member_id)
      "#{ROOT_URL}/member.php?id=#{member_id}"
    end

    # @return [String]
    lazy_attr_reader(:name) { at!('.profile-unit h1').inner_text }
    # @return [Integer]
    lazy_attr_reader(:member_id) { at!('link[hreflang=en]')['href'][%r{/users/(\d+)}, 1].to_i }
    # @return [String]
    lazy_attr_reader(:pixiv_id) { profile_image_url[%r{/profile/([a-z_-]+)/}, 1] }
    # @return [String]
    lazy_attr_reader(:profile_image_url) { at!('.profile-unit .user-image')['src'] }


    alias id member_id

    # @return [String]
    def url; self.class.url(member_id) end
  end

  module Member::WithClient
    include ::Pixiv::Page::WithClient

    def work_list(page = 1)
      client.work_list(self, page)
    end

    def bookmark_list(page = 1)
      client.bookmark_list(self, page)
    end

    def private_bookmark_list(page = 1)
      client.private_bookmark_list(self, page)
    end

    def works(page = 1, &block)
      client.works(self, page, &block)
    end

    def bookmarks(page = 1, &block)
      client.bookmarks(self, page, &block)
    end

    def private_bookmarks(page = 1, &block)
      client.private_bookmarks(page, &block)
    end
  end
end
