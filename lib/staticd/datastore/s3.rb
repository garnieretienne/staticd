require 'digest/md5'
require 'aws-sdk'

module Staticd

  module Datastore

    class S3

      def initialize(params)
        @bucket = params[:host]
        @access_key = params[:username]
        @secret_key = params[:password]
      end

      def put(file_path)
        s3 = AWS::S3.new({
          access_key_id: @access_key,
          secret_access_key: @secret_key
        })
        bucket = s3.buckets[@bucket]
        md5 = Digest::MD5.hexdigest File.read(file_path)
        timestamp = Time.now.to_i
        object = bucket.objects["#{md5}-#{timestamp}.tar.gz"].write({
          file: file_path
        })
        object.acl = :public_read
        object.public_url secure: false
      end
    end
  end
end
