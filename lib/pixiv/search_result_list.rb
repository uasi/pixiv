module Pixiv
  class SearchResultList < IllustList
    ILLUSTS_PER_PAGE = 20

=begin Coming Real Soon Now
    # @param [String, Array<query>, Set<query>] query
    #
    # @option opts [query, nil] :tag (nil) same as +url(query, mode: :tag)+
    # @option opts [query, nil] :word (nil) same as +url(query, mode: :word)+
    # @option opts [:tag, :word] :mode (:tag)
    # @option opts [Boolean] :exact (false) perform exact match (for tag mode only)
    #
    # @option opts [:illust, :manga, :both, nil] :type (nil)
    #   * +:illust+: search only for non-manga illust
    #    *+:manga+: search only for manga
    #   * +:both+ or +nil+: search for the both type
    #
    # @option opts [:tall, :wide, :square, nil] :ratio (nil)
    # @option opts [String, nil] :tool tool name
    # @option opts [Boolean] :r18 (false) X-rated only
    # @option opts [Date, nil] :since (nil)
    # @option opts [Integer, nil] :page (nil)
    #
    # @option opts [Array<(Integer, Integer)>, nil] :max_size (nil)
    #   maximum size as +[width, height]+ (either +width+ or +height+ can be +nil+)
    # @option opts [Array<(Integer, Integer)>, nil] :min_size (nil)
    #   minimum size as +[width, height]+ (either +width+ or +height+ can be +nil+)
    # @option opts [:small, :medium, :large, nil] :size (nil)
    #   * +:small+ for +:max_size => [1000, 1000]+
    #   * +:medium+ for +:max_size => [3000, 3000], :min_size => [1001, 1001]+
    #   * +:large+ for +:min_size => +[3001, 3001]+
    #
    # @example
    #   s = SearchResultList
    #   # Query
    #   s.url('tag1')
    #   s.url(%w[tag1 tag2]) # tag1 AND tag2
    #   s.url([Set.new('tag1', 'tag2'), 'tag3']) # (tag1 OR tag2) AND tag3
    #   # Mode
    #   s.url(%w[tag1 tag2]) # implicitly searches by tags
    #   s.url(%w[tag1 tag2], mode: :tag) # or explicitly
    #   s.url(tag: %w[tag1 tag2]) # same as above
    #   s.url('word', mode: :word) # searches by words
    #   s.url(word: 'word') # same as above
    #   # Options
    #   # s.url(%w[tag1 tag2], exact: true, type: :illust, r18: false, size: :large)
    #
=end

    #
    def self.url(query, opts = {})
      word = URI::encode_www_form({word: query})
      "#{ROOT_URL}/search.php?s_mode=s_tag&#{word}&p=#{opts[:page] || 1}" # FIXME
    end

    def initialize(doc_or_doc_creator, attrs = {})
      raise ArgumentError, "`attrs[:query]' must be present" unless attrs[:query]
      raise ArgumentError, "`attrs[:search_opts]' must be present" unless attrs[:search_opts]
      super
    end

    attr_reader :query
    attr_reader :search_opts

    lazy_attr_reader(:page) {
      at!('.pager li.current').inner_text.to_i
    }
    lazy_attr_reader(:last?) {
      doc.at('//nav[@class="pager"]//a[@rel="next"]').nil?
    }
    lazy_attr_reader(:total_count) {
      at!('.info > .count').inner_text.to_i
    }
    lazy_attr_reader(:page_hashes) {
      search!('#search-result li.image').map {|n| hash_from_list_item(n) }
    }

    def url
      self.class.url(query, search_opts)
    end

    def first?
      page == 1
    end

    def next_url
      return if last?
      opts = search_opts.dup
      opts[:page] = page + 1
      self.class.url(query, opts)
    end

    def prev_url
      return if first?
      opts = query_opts.dup
      opts[:page] = page - 1
      self.class.url(query, opts)
    end

    def next_attrs
      {query: query, search_opts: search_opts, page: page + 1}
    end

    def prev_attrs
      {query: query, search_opts: search_opts, page: page - 1}
    end

    def max_size
      ILLUSTS_PER_PAGE
    end

    private

    def hash_from_list_item(node)
      member_node = node.at('p.user a')
      illust_node = node.at('a')
      illust_id = illust_node['href'][/illust_id=(\d+)/, 1].to_i
      {
        url: Illust.url(illust_id),
        illust_id: illust_id,
        title: illust_node.at('h2').inner_text,
        member_id: member_node['href'][/\?id=(\d+)/, 1].to_i,
        member_name: member_node.inner_text,
        small_image_url: illust_node.at('img')['src'],
      }
    end
  end
end