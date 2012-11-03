module Henson
  module Source
    class Forge < Generic
      def initialize(forge)
        @forge = forge
      end

      def fetch!
        Henson.ui.debug "Fetching module from Puppet Forge as #{@forge}..."
        Henson.ui.info  "Fetching module from Puppet Forge as #{@forge}..."
        Henson.ui.warning "Not really fetching."
      end
    end
  end
end
