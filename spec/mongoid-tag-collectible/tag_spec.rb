# coding: utf-8
require 'spec_helper'

describe Mongoid::TagCollectible::Tag do
  describe "without tags" do
    it "generates no entries in 'tags' when tags is nil" do
      TestTagged.create!
      TestTag.all.size.should == 0
    end
    it "generates no entries in 'tags' when tags is empty" do
      TestTagged.create!(tags: [])
      TestTag.all.size.should == 0
    end
    it "generates no entries in 'tags' when tags contains an empty or nil value" do
      TestTagged.create!(tags: ["", nil])
      TestTag.all.size.should == 0
    end
  end
  describe "with tags" do
    it "generates a tags collection with the tag capitalized with 1 tag" do
      TestTagged.create!(tags: ['one'])
      TestTag.rebuild!
      tags = TestTag.all
      tags.size.should == 1
      tags[0].name.should == "One"
      tags[0].count.should == 1
    end
    it "generates a tags collection that is not case-sensitive" do
      TestTagged.create!(tags: ['One'])
      TestTagged.create!(tags: ['one'])
      TestTag.rebuild!
      tags = TestTag.all
      tags.size.should == 1
      tags[0].name.should == "One"
      tags[0].count.should == 2
    end
    it "generates a tags collection with the tag with several tags" do
      TestTagged.create!(tags: ["one"])
      TestTagged.create!(tags: ["one", "two"])
      TestTag.rebuild!
      tags = TestTag.all.desc(:count)
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
      TestTag.rebuild!
      TestTag.count.should == 2
    end
    it "deletes duplicates with the same name" do
      TestTag.create!(name: "one")
      TestTag.create!(name: "one")
      TestTagged.create!(tags: ['one'])
      TestTag.rebuild!
      TestTag.count.should == 1
    end
  end
  describe "incrementally" do
    before(:each) do
      @instance1 = TestTagged.create!(tags: ["one"])
      @instance2 = TestTagged.create!(tags: ["one", "two"])
      TestTag.rebuild!
      @tags_before = TestTag.all.desc(:count)
    end
    it "increments an existing tag by 1 when a tagged instance is added" do
      TestTagged.create!(tags: ["one", "two", "three"])
      TestTag.rebuild!
      tags_after = TestTag.all.desc(:count)
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
      TestTag.rebuild!
      tags_after = TestTag.all.desc(:count)
      tags_after.size.should == 1
      tags_after[0].id.should == @tags_before[0].id
      tags_after[0].name.should == "One"
      tags_after[0].count.should == 1
    end
  end
  describe "renaming" do
    it "renames all instances of tag" do
      instance = TestTagged.create!(tags: ['One'])
      TestTag.rebuild!
      TestTag.where(name: 'One').first.update_attributes!(name: 'Two')
      instance.reload.tags.should == ['Two']
      TestTag.count.should == 1
    end
    it "avoids duplicate tags when renaming to an existing tag" do
      instance = TestTagged.create!(tags: ['One', 'Two'])
      TestTag.rebuild!
      TestTag.where(name: 'One').first.update_attributes!(name: 'Two')
      TestTag.count.should == 1
      instance.reload.tags.should == ['Two']
    end
    it "preserves renamed tags when TestTag.rebuild! is called" do
      instance1 = TestTagged.create!(tags: ['One', 'Two'])
      instance2 = TestTagged.create!(tags: ['Two'])
      instance3 = TestTagged.create!(tags: ['One'])
      TestTag.rebuild!
      TestTag.where(name: 'One').first.update_attributes!(name: 'Two')
      [instance1, instance2, instance3].each{ |a| a.reload.tags.should == ['Two'] }
      TestTag.where(name: 'Two').count.should == 1
      TestTag.where(name: 'One').count.should == 0
      TestTag.rebuild!
      [instance1, instance2, instance3].each{ |a| a.reload.tags.should == ['Two'] }
      TestTag.where(name: 'Two').count.should == 1
      TestTag.where(name: 'One').count.should == 0
    end
    it "preserves slugs when tags are renamed and rebuilt" do
      instance1 = TestTagged.create!(tags: ['One', 'Two'])
      instance2 = TestTagged.create!(tags: ['Two'])
      instance3 = TestTagged.create!(tags: ['One'])
      TestTag.rebuild!
      two_slug = TestTag.where(name: 'Two').first.slug
      TestTag.where(name: 'One').first.update_attributes!(name: 'Two')
      TestTag.where(name: 'Two').first.slug.should == two_slug
      TestTag.rebuild!
      TestTag.where(name: 'Two').first.slug.should == two_slug
    end
  end
  describe "rebuild" do
    it "de-duplicates tags with the same name, preferring the tag with the shortest slug" do
      TestTagged.create!(tags: ['Rustled Jimmies'])
      jimmies = 10.times.map { TestTag.create(name: 'Rustled Jimmies') }
      tag_with_shortest_slug = jimmies.min_by{ |t| t.slug.length }
      TestTag.where(name: 'Rustled Jimmies').count.should == jimmies.count
      TestTag.rebuild!
      TestTag.where(name: 'Rustled Jimmies').count.should == 1
      TestTag.find(tag_with_shortest_slug.slug).should == tag_with_shortest_slug
    end
  end
  describe "instances" do
    it "returns all matching tagged instances" do
      TestTagged.create!(tags: ['One'])
      TestTagged.create!(tags: ['one'])
      TestTag.rebuild!
      tag = TestTag.first
      tag.test_taggeds.count.should == 2
      tag.test_taggeds.each { |a| a.should be_a TestTagged }
    end
    it "returns a non-nil result if there are no matching tagged instances" do
      TestTag.new.test_taggeds.count.should == 0
    end
  end
end
