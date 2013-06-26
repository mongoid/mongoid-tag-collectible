# coding: utf-8
require 'spec_helper'

describe Mongoid::TagCollectible::Tag do
  describe "tag" do
    it "stores tags in a collection name defined by the class" do
      TestTaggedTag.collection.name.should == "test_tagged_tags"
    end
  end
  describe "without tags" do
    it "generates no entries in 'tags' when tags is nil" do
      TestTagged.create!
      TestTaggedTag.all.size.should == 0
    end
    it "generates no entries in 'tags' when tags is empty" do
      TestTagged.create!(tags: [])
      TestTaggedTag.all.size.should == 0
    end
    it "generates no entries in 'tags' when tags contains an empty or nil value" do
      TestTagged.create!(tags: ["", nil])
      TestTaggedTag.all.size.should == 0
    end
  end
  describe "with tags" do
    it "find by id" do
      TestTagged.create!(tags: ['one'])
      TestTaggedTag.find(TestTaggedTag.first.id).should be_a TestTaggedTag
    end
    it "find by tag" do
      TestTagged.create!(tags: ['one'])
      TestTaggedTag.find('one').should be_a TestTaggedTag
    end
    it "generates a tags collection that is case-sensitive" do
      TestTagged.create!(tags: ['one'])
      TestTagged.create!(tags: ['One'])
      TestTagged.create!(name: "whatever")
      TestTaggedTag.count.should == 2
    end
    it "generates a tags collection with the tag with several tags" do
      TestTagged.create!(tags: ["one"])
      TestTagged.create!(tags: ["one", "two"])
      tags = TestTaggedTag.all.desc(:count)
      tags.size.should == 2
      tags[0].name.should == "one"
      tags[0].count.should == 2
      tags[1].name.should == "two"
      tags[1].count.should == 1
    end
    it "prevents duplicates" do
      TestTaggedTag.create!(name: "one")
      expect { TestTaggedTag.create!(name: "one") }.to raise_error Moped::Errors::OperationFailure, /duplicate key error/
    end
  end
  describe "incrementally" do
    before(:each) do
      @instance1 = TestTagged.create!(tags: ["one"])
      @instance2 = TestTagged.create!(tags: ["one", "two"])
      @tags_before = TestTaggedTag.all.desc(:count)
    end
    it "increments an existing tag by 1 when a tagged instance is added" do
      TestTagged.create!(tags: ["one", "two", "three"])
      tags_after = TestTaggedTag.all.desc(:count)
      tags_after.size.should == 3
      # 'one'
      tags_after[0].id.should == @tags_before[0].id
      tags_after[0].name.should == "one"
      tags_after[0].count.should == 3
      # 'two'
      tags_after[1].id.should == @tags_before[1].id
      tags_after[1].name.should == "two"
      tags_after[1].count.should == 2
      # 'three'
      tags_after[2].name.should == "three"
      tags_after[2].count.should == 1
    end
    it "decrements an existing tag by 1 and removes tags with zero when a tagged instance is removed" do
      @instance2.destroy
      tags_after = TestTaggedTag.all.desc(:count)
      tags_after.size.should == 2
      tags_after[0].id.should == @tags_before[0].id
      tags_after[0].name.should == "one"
      tags_after[0].count.should == 1
      tags_after[1].id.should == @tags_before[1].id
      tags_after[1].name.should == "two"
      tags_after[1].count.should == 0
    end
  end
  describe "renaming" do
    it "renames all instances of tag" do
      instance = TestTagged.create!(tags: ['one'])
      TestTaggedTag.where(name: 'one').first.update_attributes!(name: 'two')
      instance.reload.tags.should == ['two']
      TestTaggedTag.count.should == 1
    end
    it "avoids duplicate tags when renaming to an existing tag" do
      instance = TestTagged.create!(tags: ['one', 'two'])
      TestTaggedTag.where(name: 'one').first.update_attributes!(name: 'two')
      TestTaggedTag.count.should == 1
      instance.reload.tags.should == ['two']
    end
    it "preserves renamed tags when TestTaggedTag.update! is called" do
      instance1 = TestTagged.create!(tags: ['one', 'two'])
      instance2 = TestTagged.create!(tags: ['two'])
      instance3 = TestTagged.create!(tags: ['one'])
      TestTaggedTag.where(name: 'one').first.update_attributes!(name: 'two')
      [instance1, instance2, instance3].each{ |a| a.reload.tags.should == ['two'] }
      TestTaggedTag.where(name: 'two').count.should == 1
      TestTaggedTag.where(name: 'one').count.should == 0
      [instance1, instance2, instance3].each{ |a| a.reload.tags.should == ['two'] }
      TestTaggedTag.where(name: 'two').count.should == 1
      TestTaggedTag.where(name: 'one').count.should == 0
    end
  end
  describe "instances" do
    it "returns all matching tagged instances" do
      TestTagged.create!(tags: ['one'])
      TestTagged.create!(tags: ['one'])
      tag = TestTaggedTag.first
      tag.tagged.count.should == 2
      tag.tagged.each { |a| a.should be_a TestTagged }
    end
    it "returns a non-nil result if there are no matching tagged instances" do
      TestTaggedTag.new.tagged.count.should == 0
    end
  end
end
