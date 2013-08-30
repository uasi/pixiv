require 'spec_helper'

describe Pixiv::WorkList do
  describe '.new' do
    before do
      agent = Mechanize.new
      @doc = agent.get(File.join('file://', fixture_path, 'member_6_work_list.html'))
    end
    subject { Pixiv::WorkList.new(@doc) }
    its(:total_count) { should == 123 }
    its(:member_name) { should == "Sayoko" }
    its(:page_hashes) {
      should == [
        { :url             => 'http://www.pixiv.net/member_illust.php?mode=medium&illust_id=345',
          :illust_id       => 345,
          :title           => 'Illust #345',
          :member_id       => 6,
          :member_name     => 'Sayoko',
          :small_image_url => 'http://i1.pixiv.net/img1/img/sayoko/345_s.jpg' }
      ]
    }
  end
end
