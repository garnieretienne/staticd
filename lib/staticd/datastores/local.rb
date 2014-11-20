require 'digest/sha1'

module Staticd
  module Datastores
    class Local

      def initialize(params)
        @path = params[:path]
        verify_store_path
      end

      def put(file_path)
        if File.exist? file_path
          FileUtils.copy_file file_path, stored_file_path(file_path)
          stored_file_path(file_path)
        end
      end

      def exist?(file_path)
        if File.exist? stored_file_path(file_path)
          stored_file_path(file_path)
        end
      end

      private

      def verify_store_path
        Dir.mkdir(@path) unless File.directory?(@path)
      end

      def sha1(file_path)
        Digest::SHA1.hexdigest File.read(file_path)
      end

      def stored_file_path(file_path)
        stored_file_path = "#{@path}/#{sha1(file_path)}"
      end
    end
  end
end
