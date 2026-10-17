require 'spec_helper'

describe Mongoid::TagCollectible do
  it 'has a version' do
    expect(Mongoid::TagCollectible::VERSION).not_to be_nil
  end

  it 'defines its version when loaded independently' do
    hide_const('Mongoid::TagCollectible::VERSION')
    begin
      load File.expand_path('../../lib/mongoid-tag-collectible/version.rb', __dir__)
      expect(described_class::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
    ensure
      described_class.send(:remove_const, :VERSION) if described_class.const_defined?(:VERSION)
    end
  end

  it 'supports the underscored require alias' do
    require 'mongoid_tag_collectible'
    expect(TestTagged.ancestors).to include(described_class::Tagged)
  end
end
