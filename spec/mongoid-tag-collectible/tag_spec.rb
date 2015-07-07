# coding: utf-8
require 'spec_helper'

describe Mongoid::TagCollectible::Tag do
  describe 'tag' do
    it 'stores tags in a collection name defined by the class' do
      expect(TestTaggedTag.collection.name).to eq('test_tagged_tags')
    end
  end
  describe 'without tags' do
    it "generates no entries in 'tags' when tags is nil" do
      TestTagged.create!
      expect(TestTaggedTag.all.size).to eq(0)
    end
    it "generates no entries in 'tags' when tags is empty" do
      TestTagged.create!(tags: [])
      expect(TestTaggedTag.all.size).to eq(0)
    end
    it "generates no entries in 'tags' when tags contains an empty or nil value" do
      TestTagged.create!(tags: ['', nil])
      expect(TestTaggedTag.all.size).to eq(0)
    end
  end
  describe 'with tags' do
    it 'find by id' do
      TestTagged.create!(tags: ['one'])
      expect(TestTaggedTag.find(TestTaggedTag.first.id)).to be_a TestTaggedTag
    end
    it 'find by tag' do
      TestTagged.create!(tags: ['one'])
      expect(TestTaggedTag.find('one')).to be_a TestTaggedTag
    end
    it 'generates a tags collection that is case-sensitive' do
      TestTagged.create!(tags: ['one'])
      TestTagged.create!(tags: ['One'])
      TestTagged.create!(name: 'whatever')
      expect(TestTaggedTag.count).to eq(2)
    end
    it 'generates a tags collection with the tag with several tags' do
      TestTagged.create!(tags: ['one'])
      TestTagged.create!(tags: %w(one two))
      tags = TestTaggedTag.all.desc(:count)
      expect(tags.size).to eq(2)
      expect(tags[0].name).to eq('one')
      expect(tags[0].count).to eq(2)
      expect(tags[1].name).to eq('two')
      expect(tags[1].count).to eq(1)
    end
    it 'prevents duplicates' do
      TestTaggedTag.create!(name: 'one')
      expect { TestTaggedTag.create!(name: 'one') }.to raise_error Moped::Errors::OperationFailure, /duplicate key error/
    end
  end
  describe 'incrementally' do
    before(:each) do
      @instance1 = TestTagged.create!(tags: ['one'])
      @instance2 = TestTagged.create!(tags: %w(one two))
      @tags_before = TestTaggedTag.all.desc(:count)
    end
    it 'increments an existing tag by 1 when a tagged instance is added' do
      TestTagged.create!(tags: %w(one two three))
      tags_after = TestTaggedTag.all.desc(:count)
      expect(tags_after.size).to eq(3)
      # 'one'
      expect(tags_after[0].id).to eq(@tags_before[0].id)
      expect(tags_after[0].name).to eq('one')
      expect(tags_after[0].count).to eq(3)
      # 'two'
      expect(tags_after[1].id).to eq(@tags_before[1].id)
      expect(tags_after[1].name).to eq('two')
      expect(tags_after[1].count).to eq(2)
      # 'three'
      expect(tags_after[2].name).to eq('three')
      expect(tags_after[2].count).to eq(1)
    end
    it 'decrements an existing tag by 1 and removes tags with zero when a tagged instance is removed' do
      @instance2.destroy
      tags_after = TestTaggedTag.all.desc(:count)
      expect(tags_after.size).to eq(2)
      expect(tags_after[0].id).to eq(@tags_before[0].id)
      expect(tags_after[0].name).to eq('one')
      expect(tags_after[0].count).to eq(1)
      expect(tags_after[1].id).to eq(@tags_before[1].id)
      expect(tags_after[1].name).to eq('two')
      expect(tags_after[1].count).to eq(0)
    end
  end
  describe 'renaming' do
    it 'renames all instances of tag' do
      instance = TestTagged.create!(tags: ['one'])
      TestTaggedTag.where(name: 'one').first.update_attributes!(name: 'two')
      expect(instance.reload.tags).to eq(['two'])
      expect(TestTaggedTag.count).to eq(1)
    end
    it 'avoids duplicate tags when renaming to an existing tag' do
      instance = TestTagged.create!(tags: %w(one two))
      TestTaggedTag.where(name: 'one').first.update_attributes!(name: 'two')
      expect(TestTaggedTag.count).to eq(1)
      expect(instance.reload.tags).to eq(['two'])
    end
    it 'preserves renamed tags when TestTaggedTag.update! is called' do
      instance1 = TestTagged.create!(tags: %w(one two))
      instance2 = TestTagged.create!(tags: ['two'])
      instance3 = TestTagged.create!(tags: ['one'])
      TestTaggedTag.where(name: 'one').first.update_attributes!(name: 'two')
      [instance1, instance2, instance3].each { |a| expect(a.reload.tags).to eq(['two']) }
      expect(TestTaggedTag.where(name: 'two').count).to eq(1)
      expect(TestTaggedTag.where(name: 'one').count).to eq(0)
      [instance1, instance2, instance3].each { |a| expect(a.reload.tags).to eq(['two']) }
      expect(TestTaggedTag.where(name: 'two').count).to eq(1)
      expect(TestTaggedTag.where(name: 'one').count).to eq(0)
    end
  end
  describe 'instances' do
    it 'returns all matching tagged instances' do
      TestTagged.create!(tags: ['one'])
      TestTagged.create!(tags: ['one'])
      tag = TestTaggedTag.first
      expect(tag.tagged.count).to eq(2)
      tag.tagged.each { |a| expect(a).to be_a TestTagged }
    end
    it 'returns a non-nil result if there are no matching tagged instances' do
      expect(TestTaggedTag.new.tagged.count).to eq(0)
    end
  end
end
