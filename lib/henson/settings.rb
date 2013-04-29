module Henson
  class Settings < Hash
    def initialize
      self.merge!(
        :quiet      => false,
        :verbose    => false,
        :puppetfile => "#{Dir.pwd}/Puppetfile",
        :path       => "#{Dir.pwd}/shared",
        :cache_path => "#{Dir.pwd}/.henson/cache",
      )

      self
    end

    def [](key)
      self.fetch(key, nil)
    end
  end
end
