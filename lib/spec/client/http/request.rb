require "spec/client/http/request"
require "spec/client/http/driver/curl_driver"

module Spec
  module Client
    module Http
      class Request
        attr_accessor :url, :method, :params, :headers

        def initialize(url, method, params, headers, driver=Driver::CurlDriver.new)
          @url, @method, @params, @headers, @driver = url, method, params, headers, driver
        end

        def execute
          driver_execute(url,method,headers,params)
        end

        def driver_execute(url,method,headers,params)
          @driver.execute(url,method,headers,params)
        end
      end
    end
  end
end
