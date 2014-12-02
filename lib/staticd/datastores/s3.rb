require "digest/sha1"
require "aws-sdk"

module Staticd
  module Datastores

    # Datastore storing files on Amazon S3.
    #
    # It use the file SHA1 digest as a filename so two identical files are not
    # stored twice.
    # Each files can be accessed afterwards using a public HTTP(S) address.
    #
    # Example:
    #   datastore = Staticd::Datastores::S3.new(
    #     host: bucket_name,
    #     username: access_key_id,
    #     password: secret_access_key
    #   )
    #   datastore.put(file_path) unless datastore.exist?(file_path)
    #   # => http://bucket_name.hostname/sha1_digest
    class S3

      def initialize(params)
        @bucket_name = params[:host]
        @access_key = ENV["AWS_ACCESS_KEY_ID"]
        @secret_key = ENV["AWS_SECRET_ACCESS_KEY"]
      end

      def put(file_path)
        s3_object = object(file_path)
        s3_object.write(file: file_path)
        s3_object.acl = :public_read
        s3_object.public_url(secure: false).to_s
      end

      def exist?(file_path)
        s3_object = object(file_path)
        s3_object.exists? ? s3_object.public_url(secure: false) : false
      end

      private

      def s3
        @s3 ||= AWS::S3.new(
          access_key_id: @access_key,
          secret_access_key: @secret_key
        )
      end

      def bucket
        @bucket ||= s3.buckets[@bucket_name]
      end

      def object(file_path)
        bucket.objects[sha1(file_path)]
      end

      def sha1(file_path)
        Digest::SHA1.hexdigest(File.read(file_path))
      end
    end
  end
end
