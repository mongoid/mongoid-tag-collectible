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
    it "generates a tags collection with the tag capitalized with 1 tag" do
      TestTagged.create!(tags: ['one'])
      TestTaggedTag.update!
      tags = TestTaggedTag.all
      tags.size.should == 1
      tags[0].name.should == "One"
      tags[0].count.should == 1
    end
    it "generates a tags collection that is not case-sensitive" do
      TestTagged.create!(tags: ['One'])
      TestTagged.create!(tags: ['one'])
      TestTaggedTag.update!
      tags = TestTaggedTag.all
      tags.size.should == 1
      tags[0].name.should == "One"
      tags[0].count.should == 2
    end
    it "generates a tags collection with the tag with several tags" do
      TestTagged.create!(tags: ["one"])
      TestTagged.create!(tags: ["one", "two"])
      TestTaggedTag.update!
      tags = TestTaggedTag.all.desc(:count)
      tags.size.should == 2
      tags[0].name.should == "One"
      tags[0].count.should == 2
      tags[1].name.should == "Two"
      tags[1].count.should == 1
    end
    it "avoids creating duplicates with different capitalization" do
      instance1 = TestTagged.create!(tags: ['one','two'])
      instance2 = TestTagged.create!(tags: ['One'])
      instance2.reload.tags.should == ['One']
      instance1.reload.tags.should == ['One','Two']
      TestTaggedTag.update!
      TestTaggedTag.count.should == 2
    end
    it "deletes duplicates with the same name" do
      TestTaggedTag.create!(name: "one")
      TestTaggedTag.create!(name: "one")
      TestTagged.create!(tags: ['one'])
      TestTaggedTag.update!
      TestTaggedTag.count.should == 1
    end
  end
  describe "incrementally" do
    before(:each) do
      @instance1 = TestTagged.create!(tags: ["one"])
      @instance2 = TestTagged.create!(tags: ["one", "two"])
      TestTaggedTag.update!
      @tags_before = TestTaggedTag.all.desc(:count)
    end
    it "increments an existing tag by 1 when a tagged instance is added" do
      TestTagged.create!(tags: ["one", "two", "three"])
      TestTaggedTag.update!
      tags_after = TestTaggedTag.all.desc(:count)
      tags_after.size.should == 3
      # 'one'
      tags_after[0].id.should == @tags_before[0].id
      tags_after[0].name.should == "One"
      tags_after[0].count.should == 3
      # 'two'
      tags_after[1].id.should == @tags_before[1].id
      tags_after[1].name.should == "Two"
      tags_after[1].count.should == 2
      # 'three'
      tags_after[2].name.should == "Three"
      tags_after[2].count.should == 1
    end
    it "decrements an existing tag by 1 and removes tags with zero when a tagged instance is removed" do
      @instance2.destroy
      TestTaggedTag.update!
      tags_after = TestTaggedTag.all.desc(:count)
      tags_after.size.should == 1
      tags_after[0].id.should == @tags_before[0].id
      tags_after[0].name.should == "One"
      tags_after[0].count.should == 1
    end
  end
  describe "renaming" do
    it "renames all instances of tag" do
      instance = TestTagged.create!(tags: ['One'])
      TestTaggedTag.update!
      TestTaggedTag.where(name: 'One').first.update_attributes!(name: 'Two')
      instance.reload.tags.should == ['Two']
      TestTaggedTag.count.should == 1
    end
    it "avoids duplicate tags when renaming to an existing tag" do
      instance = TestTagged.create!(tags: ['One', 'Two'])
      TestTaggedTag.update!
      TestTaggedTag.where(name: 'One').first.update_attributes!(name: 'Two')
      TestTaggedTag.count.should == 1
      instance.reload.tags.should == ['Two']
    end
    it "preserves renamed tags when TestTaggedTag.update! is called" do
      instance1 = TestTagged.create!(tags: ['One', 'Two'])
      instance2 = TestTagged.create!(tags: ['Two'])
      instance3 = TestTagged.create!(tags: ['One'])
      TestTaggedTag.update!
      TestTaggedTag.where(name: 'One').first.update_attributes!(name: 'Two')
      [instance1, instance2, instance3].each{ |a| a.reload.tags.should == ['Two'] }
      TestTaggedTag.where(name: 'Two').count.should == 1
      TestTaggedTag.where(name: 'One').count.should == 0
      TestTaggedTag.update!
      [instance1, instance2, instance3].each{ |a| a.reload.tags.should == ['Two'] }
      TestTaggedTag.where(name: 'Two').count.should == 1
      TestTaggedTag.where(name: 'One').count.should == 0
    end
    it "preserves slugs when tags are renamed and rebuilt" do
      instance1 = TestTagged.create!(tags: ['One', 'Two'])
      instance2 = TestTagged.create!(tags: ['Two'])
      instance3 = TestTagged.create!(tags: ['One'])
      TestTaggedTag.update!
      two_slug = TestTaggedTag.where(name: 'Two').first.slug
      TestTaggedTag.where(name: 'One').first.update_attributes!(name: 'Two')
      TestTaggedTag.where(name: 'Two').first.slug.should == two_slug
      TestTaggedTag.update!
      TestTaggedTag.where(name: 'Two').first.slug.should == two_slug
    end
  end
  describe "rebuild" do
    it "de-duplicates tags with the same name, preferring the tag with the shortest slug" do
      TestTagged.create!(tags: ['Rustled Jimmies'])
      jimmies = 10.times.map { TestTaggedTag.create(name: 'Rustled Jimmies') }
      tag_with_shortest_slug = jimmies.min_by{ |t| t.slug.length }
      TestTaggedTag.where(name: 'Rustled Jimmies').count.should == jimmies.count
      TestTaggedTag.update!
      TestTaggedTag.where(name: 'Rustled Jimmies').count.should == 1
      TestTaggedTag.find(tag_with_shortest_slug.slug).should == tag_with_shortest_slug
    end
  end
  describe "instances" do
    it "returns all matching tagged instances" do
      TestTagged.create!(tags: ['One'])
      TestTagged.create!(tags: ['one'])
      TestTaggedTag.update!
      tag = TestTaggedTag.first
      tag.tagged.count.should == 2
      tag.tagged.each { |a| a.should be_a TestTagged }
    end
    it "returns a non-nil result if there are no matching tagged instances" do
      TestTaggedTag.new.tagged.count.should == 0
    end
  end
end
