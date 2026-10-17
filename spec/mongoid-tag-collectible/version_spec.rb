require 'spec_helper'

describe Mongoid::TagCollectible do
  it 'has a version' do
    expect(Mongoid::TagCollectible::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end

  it 'supports the underscored require alias' do
    require 'mongoid_tag_collectible'
    expect(TestTagged.ancestors).to include(described_class::Tagged)
  end
end
