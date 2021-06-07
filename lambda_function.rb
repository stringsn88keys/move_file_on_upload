# FIXME this shouldn't have to be top of this file
gem_path = Dir["./vendor/bundle/ruby/2.7.0/gems/**/lib"]
$:.unshift(*gem_path)

require 'aws-sdk-s3'
require 'json'
require 'cgi'

def is_top_level?(key)
    key['/'].nil?
end

def error_json(e)
    [e.message, e.backtrace].to_json
end

# this assumes an event generated from a PUT object call
def lambda_handler(event:, context:)
    client = Aws::S3::Client.new
    from_bucket = ENV['FROM_BUCKET']
    to_bucket = ENV['TO_BUCKET']

    event['Records'].each do |record|
        # key will be url encoded
        key=record['s3']['object']['key']

        # Don't process or delete top level folders
        next if is_top_level?(key)
        
        begin 
            puts "Copying #{CGI.unespace(key)} from #{from_bucket} to #{to_bucket}"

            # copy_source needs url encoded
            # key needs to be unescaped or else your key will just have url_encoded
            # characters
            resp = client.copy_object({
                bucket: to_bucket,
                copy_source: "#{from_bucket}/#{key}",
                key: CGI.unescape(key)
            })
            puts resp.to_json    
            resp = client.delete_object({
                bucket: from_bucket,
                key: CGI.unescape(key)
            })
            puts resp.to_json
        rescue Aws::S3::Errors::NoSuchKey => nsk
            return {statusCode: 404, error_json(nsk)}
        rescue => e
            return {statusCode: 500, error_json(e)}
        end
    end

    { statusCode: 200, body: response.to_json }
end