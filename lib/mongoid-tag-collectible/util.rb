module Mongoid
  module TagCollectible
    module Util
      def self.capitalize(name)
        name = name.strip.capitalize
        name = name.split(" ").map{ |word| word.capitalize }.join(" ") if name =~ /\s/
        name = name.split("-").map{ |word| word.capitalize }.join("-") if name =~ /-/
        name
      end
    end
  end
end
