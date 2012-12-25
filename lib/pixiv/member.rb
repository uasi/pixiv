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
    # return [Integer]
    lazy_attr_reader(:pixiv_id) { at!('.profile_area img')['src'].match(%r{/profile/([a-z_-]+)/}).to_a[1] }

    alias id member_id

    # @return [String]
    def url; self.class.url(member_id) end
  end
end
