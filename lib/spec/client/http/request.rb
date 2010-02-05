require "spec/client/http/request"
require "spec/client/http/driver/curl_driver"

module Spec
  module Client
    module Http
      class Request
        include Driver::CurlDriver

        attr_accessor :url, :method, :params, :headers

        def initialize(url, method, params, headers)
          @url, @method, @params, @headers = url, method, params, headers
        end

        def url_encode_params
          return nil if params.empty?

          params.inject([]) do |query, (name, value)|
            query << CGI::escape(name) + "=" + CGI::escape(value)
          end.join("&")
        end

        def execute
          driver_execute(url, method, headers, params)
        end

        def driver_execute(url, method, headers, params)
          raise NotImplementedError
        end
      end
    end
  end
end
