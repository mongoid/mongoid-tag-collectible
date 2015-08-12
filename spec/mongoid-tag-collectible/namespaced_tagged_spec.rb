require 'spec_helper'

describe Mongoid::TagCollectible::Tagged do
  let(:instance) { Namespaced::TestTagged.create! }
  describe 'tag_class' do
    it 'defines tag_class' do
      expect(instance.class.tag_class).to eq(Namespaced::TestTaggedTag)
    end
  end
  describe 'rename_tag' do
    context "doesn't match an existing tag" do
      it 'is the same' do
        old_tags = instance.class.all.map(&:tags)
        instance.class.rename_tag! 'Yellow', 'yellow'
        expect(instance.class.all.map(&:tags)).to eq old_tags
      end
    end
    context 'matches an existing tag' do
      it 'is different' do
        instance.tags = %w(Yellow Mellow)
        instance.save!
        old_tags = instance.class.all.map(&:tags)
        instance.class.rename_tag! 'Yellow', 'Blue'
        expect(instance.class.all.map(&:tags)).not_to eq old_tags
        expect(instance.reload.tags).to include 'Blue'
        expect(instance.tags).to include 'Mellow'
        expect(instance.tags).not_to include 'Yellow'
      end
    end
  end
  describe 'remove_tag!' do
    it 'deletes tag' do
      instance.tags = %w(Yellow Mellow)
      instance.save!
      instance.class.remove_tag!('Yellow')
      expect(instance.class.find(instance.id).tags).to eq(['Mellow'])
    end
  end
end
