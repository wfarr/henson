module Henson
  module Source
    class Forge < Generic

      # Public: Returns the String name of the module.
      attr_reader :name

      # Public: Returns the String name of the forge.
      attr_reader :api


      # Public: Initialize a new Henson::Source::Forge
      #
      # name  - The String name of the module.
      # forge - The String hostname of the Puppet Forge.
      def initialize name, requirement, forge
        @name  = name
        @api   = Henson.api_clients.puppet_forge forge

        @requirement = requirement
      end

      def fetched?;   end

      def versions; []; end

      def fetch!
        # TODO implement me
      end

      def install!
        # TODO implement me
      end
    end
  end
end
