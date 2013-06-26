require 'spec_helper'

describe Mongoid::TagCollectible::Tagged do
  let(:instance) { TestTagged.create! }
  describe "rename_tag" do
    context "doesn't match an existing tag" do
      it "is the same" do
        old_tags = instance.class.all.map{ |a| a.tags }
        instance.class.rename_tag! 'Yellow', 'yellow'
        instance.class.all.map{ |a| a.tags }.should eq old_tags
      end
    end
    context "matches an existing tag" do
      it "is different" do
        instance.tags = [ 'Yellow', 'Mellow' ]
        instance.save!
        old_tags = instance.class.all.map{ |a| a.tags }
        instance.class.rename_tag! 'Yellow', 'Blue'
        instance.class.all.map{ |a| a.tags }.should_not eq old_tags
        instance.reload.tags.should include 'Blue'
        instance.tags.should include 'Mellow'
        instance.tags.should_not include 'Yellow'
      end
    end
  end
  describe "remove_tag!" do
    it "deletes tag" do
      instance.tags = [ 'Yellow', 'Mellow' ]
      instance.save!
      instance.class.remove_tag!('Yellow')
      instance.class.find(instance.id).tags.should == [ 'Mellow' ]
    end
  end
end
