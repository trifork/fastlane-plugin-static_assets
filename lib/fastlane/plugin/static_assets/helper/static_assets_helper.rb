module Fastlane
  module Helper
    class StaticAssetsHelper
      def self.fetch_images(paths)
        image = {}
        paths.each do |path|
          path_arr = Dir["#{FastlaneCore::FastlaneFolder.path}../#{path}/**/*.imageset"].each do |image_path|
            path = image_path.sub('.imageset', '')
            path_arr = path.split('/')
            image_name = path_arr[path_arr.length - 1]

            key = self.sanitize_name(image_name)
            image[key] ||= []

            image[key] << image_path
          end
        end
        image
      end

      def self.sanitize_name(name)
        name.tr(' ', '_')
      end

      def self.remove_dir(path)
        if File.directory?(path)
          Dir.foreach(path) do |file|
            if (file.to_s != ".") and (file.to_s != "..")
              remove_dir("#{path}/#{file}")
            end
          end
          Dir.delete(path)
        else
          File.delete(path)
        end
      end
    end
  end
end
