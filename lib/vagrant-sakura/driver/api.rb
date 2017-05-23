require 'log4r'
require 'net/https'
require 'json'

module VagrantPlugins
  module Sakura
    module Driver
      APIHOST   = "secure.sakura.ad.jp"
      CERTFILE = File.expand_path("../cert.pem", __FILE__)

      class API
        def initialize(access_token, access_token_secret, zone_id)
          @logger = Log4r::Logger.new("vagrant::provider::sakura")

          @access_token = access_token
          @access_token_secret = access_token_secret
          @prefix = "/cloud/zone/#{zone_id}/api/cloud/1.1"

          @https = Net::HTTP.new(APIHOST, 443)
          @https.use_ssl = true
          @https.ca_file = CERTFILE
          @https.verify_mode = OpenSSL::SSL::VERIFY_PEER
          @https.verify_depth = 3
        end

        def delete(resource, data = nil)
          request = Net::HTTP::Delete.new(@prefix + resource)
          request.body = data.to_json if data
          do_request request
        end

        def get(resource, data = nil)
          request = Net::HTTP::Get.new(@prefix + resource)
          request.body = data.to_json if data
          do_request request
        end

        def post(resource, data)
          request = Net::HTTP::Post.new(@prefix + resource)
          request.body = data.to_json
          do_request request
        end

        def put(resource, data = nil)
          request = Net::HTTP::Put.new(@prefix + resource)
          request.body = if data then data.to_json else '' end
          do_request request
        end

        def do_request(request)
          request.basic_auth @access_token, @access_token_secret
          response = @https.request(request)
          @logger.debug("#{request.method} #{request.path} #{request.body} "+
                        "=> #{response.code} : #{response.body}")

          emsg_detail = JSON.pretty_generate JSON.parse(response.body)
          emsg = "#{response.code} (#{request.method} #{request.path})\n#{emsg_detail}"
          case response.code
          when /2../
            # Success
          when "400"
            raise BadRequestError, emsg
          when "404"
            raise NotFoundError, emsg
          when "409"
            raise ConflictError, emsg
          else
            raise GenericError, emsg
          end

          JSON.parse response.body
        end
        private :do_request
      end

      class BadRequestError < RuntimeError; end
      class ConflictError < RuntimeError; end
      class GenericError < RuntimeError; end
      class NotFoundError < RuntimeError; end
    end
  end
end
