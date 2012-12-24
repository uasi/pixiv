require 'spec_helper'

describe Pixiv::Page do
  let(:doc) { fixture_as_doc('empty.html') }
  let(:doc_creator) { Proc.new { doc } }
  let(:attrs) { {} }

  describe '.lazy_new', 'with doc_creator' do
    subject { Pixiv::Page.lazy_new(&doc_creator) }
    its(:doc) { should == doc }
  end

  describe '.lazy_new', 'with attrs and doc_creator' do
    subject { Pixiv::Page.lazy_new(attrs, &doc_creator) }
    its(:doc) { should == doc }
  end
end
