require 'spec_helper'

describe Mongoid::TagCollectible do
  it "has a version" do
    Mongoid::TagCollectible::VERSION.should_not be_nil
  end
end
