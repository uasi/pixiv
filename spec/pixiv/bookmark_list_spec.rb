require 'spec_helper'

describe Pixiv::BookmarkList do
  describe '.new' do
    before do
      agent = Mechanize.new
      @doc = agent.get(File.join('file://', fixture_path, 'member_6_bookmark_list.html'))
    end
    subject { Pixiv::BookmarkList.new(@doc) }
    its(:total_count) { should == 1234 }
    its(:page_hashes) {
      should == [
        { :url             => 'http://www.pixiv.net/member_illust.php?mode=medium&illust_id=123',
          :illust_id       => 123,
          :title           => 'Illust #123',
          :member_id       => 456,
          :member_name     => 'Hanako',
          :small_image_url => 'http://i1.pixiv.net/img1/img/hanako/123_s.jpg' }
      ]
    }
  end
end
