require 'digest/md5'
require 'base64'

module Staticd

  # @todo See for base64 headers to support the encoded file mime type and guess the
  # file's extention from it.
  module Datastore
    class Local

      STORE_PATH="/tmp/store"

      def self.put(file_path)
        verify_store_path
        if File.exist? file_path
          basename = File.basename file_path
          md5 = Digest::MD5.hexdigest File.read(file_path)
          stored_file_path = "#{STORE_PATH}/#{md5}.tar.gz"
          FileUtils.copy_file file_path, stored_file_path
          stored_file_path
        end
      end

      def self.put_base64(base64)
        verify_store_path
        md5 = Digest::MD5.hexdigest base64
        stored_file_path = "#{STORE_PATH}/#{md5}.tar.gz"
        File.open stored_file_path, "w" do |file|
          file.write Base64.decode64(base64)
        end
        stored_file_path
      end

      def self.verify_store_path
        if ! File.directory?(STORE_PATH)
          Dir.mkdir STORE_PATH
        end
      end
    end
  end
end
