module Pixiv
  class Client
    def self.new_agent
      agent = Mechanize.new
      agent.pluggable_parser['image/gif'] = Mechanize::Download
      agent.pluggable_parser['image/jpeg'] = Mechanize::Download
      agent.pluggable_parser['image/png'] = Mechanize::Download
      agent
    end

    attr_reader :agent
    attr_reader :member_id

    def initialize(*args)
      if args.size < 2
        @agent = args.first || self.class.new_agent
        yield @agent if block_given?
        ensure_logged_in
      else
        pixiv_id, password = *args
        @agent = self.class.new_agent
        yield @agent if block_given?
        login(pixiv_id, password)
      end
    end

    def login(pixiv_id, password)
      form = agent.get("#{ROOT_URL}/index.php").forms_with(:class => 'login-form').first
      raise Error::LoginFailed, 'login form is not available' unless form
      form.pixiv_id = pixiv_id
      form.pass = password
      doc = agent.submit(form)
      raise Error::LoginFailed unless doc.body =~ /logout/
      @member_id = member_id_from_mypage(doc)
    end

    def illust(illust_id)
      attrs = {illust_id: illust_id}
      Illust.lazy_new(attrs) { agent.get(Illust.url(illust_id)) }
    end

    def member(member_id = member_id)
      attrs = {member_id: member_id}
      Member.lazy_new(attrs) { agent.get(Member.url(member_id)) }
    end

    def bookmark_list(member_or_member_id = member_id, page_num = 1)
      x = member_or_member_id
      member_id = x.is_a?(Member) ? x.member_id : x
      attrs = {member_id: member_id, page_num: page_num}
      BookmarkList.lazy_new(attrs) { agent.get(BookmarkList.url(member_id, page_num)) }
    end

    def bookmarks(member_or_member_id = member_id, page_num = 1)
      list = bookmark_list(member_or_member_id, page_num)
      PageCollection::Enumerator.new(self, list)
    end

    def download_illust(illust, io_or_filename, size = :original)
      size = {:s => :small, :m => :medium, :o => :original}[size] || size
      url = illust.__send__("#{size}_image_url")
      referer = case size
                when :small then nil
                when :medium then illust.url
                when :original then illust.original_image_referer
                else raise ArgumentError, "unknown size `#{size}`"
                end
      save_to = io_or_filename
      if save_to.is_a?(Array)
        save_to = filename_from_pattern(save_to, illust, url)
      end
      FileUtils.mkdir_p(File.dirname(save_to)) unless save_to.respond_to?(:write)
      @agent.download(url, save_to, [], referer)
    end

    def download_manga(illust, pattern)
      illust.original_image_urls.each do |url|
        filename = filename_from_pattern(pattern, illust, url)
        FileUtils.mkdir_p(File.dirname(filename))
        @agent.download(url, filename, [], illust.original_image_referer)
      end
    end

    protected

    def ensure_logged_in
      doc = agent.get("#{ROOT_URL}/mypage.php")
      raise Error::LoginFailed unless doc.body =~ /logout/
      @member_id = member_id_from_mypage(doc)
    end

    def member_id_from_mypage(doc)
      doc.at('.profile_area a').attr('href').match(/(\d+)$/).to_a[1].to_i
    end

    def filename_from_pattern(pattern, illust, url)
      pattern.map {|i|
        if i == :image_name
          name = File.basename(url)
          if name =~ /\.(\w+)\?\d+$/
            name += '.' + $1
          end
          name
        elsif i.is_a?(Symbol) then illust.__send__(i)
        elsif i.respond_to?(:call) then i.call(illust)
        else i
        end
      }.join('')
    end
  end
end
