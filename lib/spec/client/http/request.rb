require "spec/client/http/request"
require "spec/client/http/driver/curl_driver"

module Spec
  module Client
    module Http
      class Request
        attr_accessor :url, :request_method, :params, :headers

        def initialize(url, request_method, params, headers, driver=Driver::CurlDriver.new)
          @url, @request_method, @params, @headers, @driver = url, request_method, params, headers, driver
        end

        def url_encoded_params
          @driver.url_encode_params(params)
        end

        def execute
          driver_execute(url,request_method,headers,params)
        end

        def driver_execute(url,request_method,headers,params)
          @driver.execute(url,request_method,headers,params)
        end
      end
    end
  end
end
