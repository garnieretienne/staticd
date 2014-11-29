require "digest/sha1"

module Staticd
  module Datastores

    # Datastore storing files on local directory.
    #
    # It use the file SHA1 digest as a filename so two identical files are not
    # stored twice.
    #
    # Example:
    #   datastore = Staticd::Datastores::Local.new(path: "/tmp/datastore")
    #   datastore.put(file_path) unless datastore.exist?(file_path)
    #   # => "/tmp/datastore/sha1_digest"
    class Local

      def initialize(params)
        @path = params[:path]
        check_store_directory
      end

      def put(file_path)
        datastore_file = stored_file_path(file_path)
        FileUtils.copy_file(file_path, datastore_file) unless exist?(file_path)
        datastore_file
      end

      def exist?(file_path)
        datastore_file = stored_file_path(file_path)
        File.exist?(datastore_file) ? datastore_file : false
      end

      private

      def check_store_directory
        FileUtils.mkdir_p(@path) unless File.directory?(@path)
      end

      def sha1(file_path)
        Digest::SHA1.hexdigest(File.read(file_path))
      end

      def stored_file_path(file_path)
        "#{@path}/#{sha1(file_path)}"
      end
    end
  end
end
