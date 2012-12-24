require 'spec_helper'

describe Pixiv::Member do
  describe '.new' do
    subject { Pixiv::Member.new(fixture_as_doc('member_6.html')) }
    its(:member_id) { should == 6 }
    its(:pixiv_id) { should == 'sayoko' }
    its(:name) { should == 'Sayoko' }
  end

  describe '.new', 'given attrs cover attrs extracted from doc' do
    before do
      @doc = fixture_as_doc('member_6.html')
      @attrs = {
        member_id: 13,
        pixiv_id: 'duke',
        name: 'Duke',
      }
    end
    subject { Pixiv::Member.new(@doc, @attrs) }
    its(:member_id) { should == 13 }
    its(:pixiv_id) { should == 'duke' }
    its(:name) { should == 'Duke' }
  end

  describe '.new', 'attr raises NodeNotFound if doc is wrong' do
    subject { Pixiv::Member.new(fixture_as_doc('empty.html')) }
    it { expect { subject.member_id }.to raise_error(Pixiv::Error::NodeNotFound) }
    it { expect { subject.pixiv_id }.to raise_error(Pixiv::Error::NodeNotFound) }
    it { expect { subject.name}.to raise_error(Pixiv::Error::NodeNotFound) }
  end

  describe '.url' do
    it 'returns url for given member id' do
      expect(Pixiv::Member.url(6)).to eq('http://www.pixiv.net/member.php?id=6')
    end
  end
end