module Henson
  module Source
    class Generic
      def fetch!
        raise NotImplementedError
      end
    end
  end
end
