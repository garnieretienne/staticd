require 'digest/sha1'
require 'aws-sdk'

module Staticd

  module Datastore

    class S3

      def initialize(params)
        @bucket_name = params[:host]
        @access_key = params[:username]
        @secret_key = params[:password]
      end

      def put(file_path)
        timestamp = Time.now.to_i
        object = bucket.objects[sha1(file_path)].write({
          file: file_path
        })
        object.acl = :public_read
        object.public_url secure: false
      end

      def exist?(file_path)
        object = bucket.objects[sha1(file_path)]
        object.public_url secure: false if object.exists?
      end

      private

      def s3
        @s3 ||= AWS::S3.new({
          access_key_id: @access_key,
          secret_access_key: @secret_key
        })
      end

      def bucket
        @bucket ||= s3.buckets[@bucket_name]
      end

      def sha1(file_path)
        Digest::SHA1.hexdigest File.read(file_path)
      end
    end
  end
end
