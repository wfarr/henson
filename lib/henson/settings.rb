module Henson
  class Settings < Hash
    def initialize
      self.merge!(
        :quiet   => false,
        :verbose => false
      )

      self
    end

    def [](key)
      self.fetch(key, nil)
    end
  end
end