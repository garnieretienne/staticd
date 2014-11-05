require 'digest/md5'

module Staticd
  module Datastore
    class Local

      def initialize(params)
        @path = params[:path]
        verify_store_path
      end

      def put(file_path)
        if File.exist? file_path
          basename = File.basename file_path
          md5 = Digest::MD5.hexdigest File.read(file_path)
          stored_file_path = "#{@path}/#{md5}.tar.gz"
          FileUtils.copy_file file_path, stored_file_path
          stored_file_path
        end
      end

      private

      def verify_store_path
        Dir.mkdir(@path) unless File.directory?(@path)
      end
    end
  end
end
