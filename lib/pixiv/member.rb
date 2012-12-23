module Pixiv
  class Member < Page
    def self.url(member_id)
      "#{ROOT_URL}/member.php?id=#{member_id}"
    end

    lazy_attr_reader(:name) { at!('.profile_area h2').inner_text }
    lazy_attr_reader(:member_id) { at!('input[name="user_id"]').attr('value').to_i }
    lazy_attr_reader(:pixiv_id) { at!('.profile_area img').attr('src').match(%r{/profile/([a-z_-]+)/}).to_a[1] }
    alias id member_id

    def url; self.class.url(member_id) end
  end
end
