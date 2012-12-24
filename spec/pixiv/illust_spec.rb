require 'spec_helper'

describe Pixiv::Illust do
  let(:illust_doc) { fixture_as_doc('illust_345.html') }

  describe '.new' do
    subject { Pixiv::Illust.new(illust_doc) }
    its(:illust_id) { should == 345 }
    its(:member_id) { should == 6 }
    its(:small_image_url) { should == 'http://i1.pixiv.net/img1/img/sayoko/345_s.jpg' }
    its(:medium_image_url) { should == 'http://i1.pixiv.net/img1/img/sayoko/345_m.jpg' }
    its(:original_image_url) { should == 'http://i1.pixiv.net/img1/img/sayoko/345.jpg' }
    its(:num_pages) { should be_nil }
    its(:illust?) { should be_true }
    its(:manga?) { should be_false }
  end

  describe '.new', 'given attrs covers attrs extracted from doc' do
    before do
      @attrs = {
        illust_id: 105,
        member_id: 13,
        small_image_url: 'http://i1.pixiv.net/img1/img/duke/105_s.jpg',
      }
    end
    subject { Pixiv::Illust.new(illust_doc, @attrs) }
    its(:illust_id) { should == 105 }
    its(:member_id) { should == 13 }
    its(:small_image_url) { should == 'http://i1.pixiv.net/img1/img/duke/105_s.jpg' }
    its(:medium_image_url) { should == 'http://i1.pixiv.net/img1/img/duke/105_m.jpg' }
    its(:original_image_url) { should == 'http://i1.pixiv.net/img1/img/duke/105.jpg' }
    its(:num_pages) { should be_nil }
    its(:illust?) { should be_true }
    its(:manga?) { should be_false }
  end

  describe '.url' do
    it 'returns url for illust id' do
      expect(Pixiv::Illust.url(345)).
        to eq('http://www.pixiv.net/member_illust.php?mode=medium&illust_id=345')
    end
  end
end
