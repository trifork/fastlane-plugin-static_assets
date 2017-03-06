require 'find'

module Fastlane
  module Actions
    class UnusedImagesAction < Action
      def self.run(params)
        params[:paths] = [params[:paths]] unless params[:paths].kind_of?(Array)
        params[:ignore] = [params[:ignore]] unless params[:ignore].kind_of?(Array)
        params[:extensions] = [params[:extensions]] unless params[:extensions].kind_of?(Array)

        ignore = params[:ignore].map do |i|
          File.expand_path("#{FastlaneCore::FastlaneFolder.path}/../#{i}")
        end

        code_path = params[:code_path]
        extensions = params[:extensions].join('|')

        image_paths = Helper::StaticAssetsHelper.fetch_images(params[:paths])

        files = Find.find("#{FastlaneCore::FastlaneFolder.path}../#{code_path}").grep(/.*#{extensions}$/)

        files = files.delete_if do |file|
          ignore.include?(File.expand_path(file))
        end

        deletable_images = image_paths.keys.reject do |image|
          r = files.inject(false) do |result, file|
            result || File.foreach(file).grep(/#{image}/).any?
          end
          r
        end

        if deletable_images.count == 0
          UI.success "No unused images present"
        else
          UI.header "#{deletable_images.count} unused images:"
          deletable_images.each do |image|
            image_path = image_paths[image]
            image_path.each do |ip|
              UI.important " - removing #{ip.sub('./fastlane/../', '')}"
              Helper::StaticAssetsHelper.remove_dir(ip) unless params[:dry_run] || !File.exist?(ip)
            end
          end
        end
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :dry_run,
                                  env_name: "FL_IOS_IMAGE_ASSETS_UNUSED_IMAGES_DRY_RUN",
                               description: "Dry run - will not delete images",
                             default_value: false,
                                  optional: true,
                                 is_string: false),
          FastlaneCore::ConfigItem.new(key: :paths,
                                         env_name: 'FL_IOS_IMAGE_ASSETS_UNUSED_IMAGES_PATHS',
                                         description: 'single path or Array of paths to image assets to convert',
                                         is_string: false),
          FastlaneCore::ConfigItem.new(key: :code_path,
                                         env_name: 'FL_IOS_IMAGE_ASSETS_UNUSED_IMAGES_CODE_PATH',
                                         description: 'path to check',
                                         is_string: true),
          FastlaneCore::ConfigItem.new(key: :ignore,
                                         env_name: 'FL_IOS_IMAGE_ASSETS_UNUSED_IMAGES_CODE_IGNORE',
                                         description: 'paths to ignore',
                                         is_string: false),
          FastlaneCore::ConfigItem.new(key: :extensions,
                                         env_name: 'FL_IOS_IMAGE_ASSETS_UNUSED_IMAGES_EXTENSIONS',
                                         description: '',
                                         is_string: false)

        ]
      end

      def self.output
        [
        ]
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        ['Krzysztof Piatkowski', 'Jakob Jensen']
      end

      def self.is_supported?(platform)
        [:ios].include? platform
      end
    end
  end
end
