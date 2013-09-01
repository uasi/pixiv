require 'spec_helper'

describe Pixiv::SearchResultList do
  describe '.new' do
    before do
      @doc = fixture_as_doc('search_hoge.html')
      @attrs = {
        query: 'hoge',
        search_opts: {}
      }
    end
    subject { Pixiv::SearchResultList.new(@doc, @attrs) }
    its(:page) { should == 2 }
    its(:last?) { should == false }
    its(:total_count) { should == 12345 }
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
