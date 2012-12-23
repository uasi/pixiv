module Pixiv
  class Illust < Page
    def self.url(illust_id)
      "#{ROOT_URL}/member_illust.php?mode=medium&illust_id=#{illust_id}"
    end

    lazy_attr_reader(:small_image_url) { at!('meta[property="og:image"]').attr('content') }
    lazy_attr_reader(:medium_image_url) { image_url_components.join('_m') }
    lazy_attr_reader(:original_image_url) { illust? && image_url_components.join('') }
    lazy_attr_reader(:original_image_urls) {
      illust? ? [original_image_url]
              : (0...num_pages).map {|n| image_url_components.join("_p#{n}") }
    }
    lazy_attr_reader(:original_image_referer) { ROOT_URL + '/' + at!('//div[@class="works_display"]/a').attr('href') }
    lazy_attr_reader(:illust_id) { at!('#rpc_i_id').attr('title').to_i }
    lazy_attr_reader(:member_id) { at!('#rpc_u_id').attr('title').to_i }
    lazy_attr_reader(:member_name) { raise NotImplementError.new('XXX') }
    lazy_attr_reader(:title) { raise NotImplementError.new('XXX') }
    lazy_attr_reader(:num_pages) {
      n = at!('//ul[@class="meta"]/li[2]').inner_text.match(/(\d+)P$/).to_a[1]
      n && n.to_i
    }

    alias id illust_id
    alias original_image_referrer original_image_referer # referrer vs. referer

    def url; self.class.url(illust_id) end
    def illust?; !manga? end
    def manga?; !!num_pages end
    def medium_image_url; image_url_components.join('_m') end
    def original_image_url; image_url_components.join('') end

    private

    def image_url_components
      @image_url_components ||= small_image_url.match(%r{^(.+)_s(\.\w+(?:\?\d+)?)$}).to_a[1, 3]
    end
  end
end
