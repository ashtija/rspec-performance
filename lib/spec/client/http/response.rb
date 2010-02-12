require "spec/client/http/cookie"

module Spec
  module Client
    module Http
      class Response
        attr_accessor :code, :headers, :body

        def initialize
          @code = 0
          @headers = {}
          @body = ""
        end

        def cookies
          @cookies ||= headers["Set-Cookie"].map do |raw_cookie|
            Spec::Client::Http::Cookie.parse(raw_cookie)
          end
          @cookies
        end
      end
    end
  end
end