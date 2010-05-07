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

        def execute
          driver_execute(url, method, headers, params)
        end

      end
    end
  end
end
