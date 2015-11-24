# -*- encoding: utf-8 -*-

module Pixiv
  class Illust < Page
    # @!parse
    # include ::Pixiv::Illust::WithClient

    # Returns the URL for given +illust_id+
    # @param [Integer] illust_id
    # @return [String]
    def self.url(illust_id)
      "#{ROOT_URL}/member_illust.php?mode=medium&illust_id=#{illust_id}"
    end

    # @return [String]
    lazy_attr_reader(:small_image_url) { at!('meta[property="og:image"]')['content'] }
    # @return [String]
    lazy_attr_reader(:medium_image_url) { at!('.works_display img')['src'] }
    # @return [String]
    lazy_attr_reader(:original_image_url) { illust? ? image_url_components.join('') : nil }
    # @return [Array<String>]
    lazy_attr_reader(:original_image_urls) {
      illust? ? [original_image_url]
              : (0...num_pages).map {|n| image_url_components.join("_p#{n}") }
    }
    # @return [String]
    lazy_attr_reader(:original_image_referer) { ROOT_URL + '/' + at!('//div[@class="works_display"]/a')['href'] }
    # @return [Integer]
    lazy_attr_reader(:illust_id) { at!('#rpc_i_id')['title'].to_i }
    # @return [Integer]
    lazy_attr_reader(:member_id) { at!('.user-link').attributes['href'].text.match('id=([0-9]*)')[1].to_i }
    # @return [String]
    lazy_attr_reader(:member_name) {
      # Note: generally member_name can easily be found at +at('.profile_area a')['title']+
      # but this is not the case on your own illust page; so this hack.
      at!('title').inner_text[%r!^「#{Regexp.escape(title)}」/「(.+)」の(?:イラスト|漫画) \[pixiv\]$!, 1]
    }
    # @return [String]
    lazy_attr_reader(:title) { at!('.work-info h1.title').inner_text }
    # @return [Integer, nil]
    lazy_attr_reader(:num_pages) {
      node = doc.at('//ul[@class="meta"]/li[2]')
      n = node ? node.inner_text[/(\d+)P$/, 1] : nil
      n && n.to_i
    }
    # @return [Array<String>]
    lazy_attr_reader(:tag_names) { search!('ul.tags a.text').map {|n| n.inner_text } }
    # @return [String]
    lazy_attr_reader(:caption) { at!('.work-info .caption').inner_text }
    # @api experimental
    # @return [Array<Nokogiri::XML::NodeSet, nil>]
    lazy_attr_reader(:anchors_in_caption) { doc.search('.work-info .caption a') }
    # @return [Integer]
    lazy_attr_reader(:views_count) { at!('.view-count').inner_text.to_i }
    # @return [Integer]
    lazy_attr_reader(:rated_count) { at!('.rated-count').inner_text.to_i }
    # @return [Integer]
    lazy_attr_reader(:score) { at!('.score-count').inner_text.to_i }

    # @return [Boolean]
    lazy_attr_reader(:mypixiv_only?) { doc.at('[@class="_no-item closed"]').nil?.! }

    alias id illust_id
    alias author_id member_id
    alias author_name member_name
    alias original_image_referrer original_image_referer # referrer vs. referer

    # @return [String]
    def url; self.class.url(illust_id) end
    # @return [Boolean]
    def illust?; !manga? end
    # @return [Boolean]
    def manga?; !!num_pages end

    private

    def image_url_components
      @image_url_components ||= medium_image_url.match(%r{^(.+)_m(\.\w+(?:\?\d+)?)$}).to_a[1, 3]
    end
  end

  module Illust::WithClient
    include ::Pixiv::Page::WithClient

    # @return [Pixiv::Member]
    def member
      attrs = {member_id: member_id, member_name: member_name}
      Member.lazy_new(attrs) { client.agent.get(Member.url(member_id)) }
    end

    alias author member

    # Download illust
    #
    # See {Pixiv::Client#download_illust} for the detail.
    def download_illust(io_or_filename, size = :original)
      client.download_illust(self, io_or_filename, size)
    end

    # Download manga
    #
    # See {Pixiv::Client#download_manga} for the detail.
    def download_manga(pattern, &block)
      client.download_manga(self, pattern, &block)
    end
  end
end
