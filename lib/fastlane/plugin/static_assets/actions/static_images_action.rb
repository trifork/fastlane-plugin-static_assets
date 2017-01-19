module Fastlane
  module Actions
    class StaticImagesAction < Action
      def self.run(params)
        unless params[:paths].kind_of?(Array)
          params[:paths] = [params[:paths]]
        end

        image_names = []
        params[:paths].each do |path|
          path_arr = Dir["#{FastlaneCore::FastlaneFolder.path}../#{path}/**/*.imageset"].each do |image_path|
            path_arr = image_path.split('/')
            image_name = path_arr[path_arr.length - 1].sub('.imageset', '')
            if image_names.include?(image_name)
              raise "'#{image_name}' is a duplicate".red
            end
            image_names << image_name
          end
        end
        output_path = "#{FastlaneCore::FastlaneFolder.path}/../#{params[:output]}"
        FileUtils.mkdir_p(File.dirname(output_path))
        file = open(output_path, 'w')

        if params[:is_xamarin]
          file.write("using System;\nusing UIKit;\npublic class Images {\n")
          image_names.each do |image_name|
            sanitized_image_name = sanitize_name(image_name)
            file.write("\tpublic static UIImage #{sanitized_image_name} { get { return UIImage.FromBundle(\"#{image_name}\"); } }\n")
          end
          file.write("}")
        else
          file.write("import UIKit\nstruct Images {\n")

          image_names.each do |image_name|
            sanitized_image_name = sanitize_name(image_name)
            file.write("\tstatic let #{sanitized_image_name} = UIImage(named:\"#{image_name}\")!\n")
          end
          file.write("}")
        end

        file.close
      end

      def self.sanitize_name(name)
        name.tr(' ', '_')
      end

      def self.description
        "Generate code for buildtime-safe assignments of images."
      end

      def self.authors
        ["Krzysztof Piatkowski", "Jakob Jensen"]
      end

      def self.return_value
      end

      def self.details
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :output,
                                       env_name: "FL_IOS_IMAGE_ASSET_OUTPUT",
                                       description: "output file"),
          FastlaneCore::ConfigItem.new(key: :paths,
                                       env_name: "FL_IOS_IMAGE_ASSET_PATHS",
                                       description: "single path or Array of paths to image assets to convert",
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :is_xamarin,
                                       env_name: "FL_IOS_IMAGE_ASSET_IS_XAMARIN",
                                       description: "should output as xamarin (C#)?",
                                       default_value: false,
                                       is_string: false)
        ]
      end

      def self.is_supported?(platform)
        [:ios].include? platform
      end
    end
  end
end
