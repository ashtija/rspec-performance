module Spec
  module Client
    module Http
      module Driver
        module CurlDriver
          def driver_execute(url, method, headers, params)
            # Workaround for potential bug in curl
            request_url = url
            encoded_params = url_encoded_params

            if method == "GET"
              request_url += "?#{encoded_params}"
            end

            response_headers = {}
            response_body = ""

            curl = Curl::Easy.new(request_url)
            curl.headers = headers

            curl.on_header do |header|
              size = header.size; header.chomp!
              name, value = header.split(/\: /)
              response_headers[name] ||= []
              response_headers[name] << value
              size
            end

            curl.on_body do |body|
              body_content += body
              body.size
            end

            case method.upcase
            when "GET"
              curl.http_get
            when "POST"
              curl.http_post(encoded_params)
            end

            response = Response.new
            response.code = curl.response_code
            response.headers = response_headers
            response.body = body_content

            response
          end
        end
      end
    end
  end
end
