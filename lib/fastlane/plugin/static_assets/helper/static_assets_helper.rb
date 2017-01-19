module Fastlane
  module Helper
    class StaticAssetsHelper
      # class methods that you define here become available in your action
      # as `Helper::StaticAssetsHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the static_assets plugin helper!")
      end
    end
  end
end
