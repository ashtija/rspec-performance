require "spec/client/http/cookie"

# NOTE:  This is nowhere near an RFC compliant implementation of how HTTP clients should handle cookies.
#        There are bugs in this implementation, but it works for what I need at the moment.
#        I would love help with this. - BR
# TODO:  Someday this might be RFC compliant
module Spec
  module Client
    module Http
      class CookieJar
        def initialize
          @origins = {}
        end

        def put(url, cookie)
          case cookie
            when String
              put(url, Cookie.parse(cookie))
            when Cookie
              insert_or_expire(url, cookie)
            else
              raise "Unrecognized type: #{cookie.class}"
          end
        end

        def get(url)
          uri = URI.parse(url)

          matching_cookies = {}
          matching_cookies = matching_cookie_hash(uri)
          matching_cookies.merge!(matching_cookie_hash(uri, "." + uri.host))
          matching_cookies.merge!(matching_cookie_hash(uri, nil, uri.path))
          matching_cookies.merge!(matching_cookie_hash(uri, "." + uri.host, uri.path))
          matching_cookies.values
        end

        def cookies(origin)
          return [] unless cookies = @origins[origin]
          cookies.values.flatten
        end


        def to_s(url = nil)
          ""
        end

        class << self
          def origin_for(url_or_uri)
            # FIXME: This function fails horribly for TLDS like gaurdian.co.uk
            domain = url_or_uri.is_a?(URI) ? url_or_uri.host : URI.parse(url_or_uri).host

            return domain if domain =~ /^\d{0,3}\.\d{0,3}\.\d{0,3}\.\d{0,3}$/
            return "localhost" if domain =~ /localhost$/

            split_domain = domain.split(/\./)
            raise "Invalid top level domain: " unless (size = split_domain.size) >= 2

            split_domain[size-2..size-1].join(".")
          end
        end

        private

        def matching_cookie_hash(uri, domain = nil, path = nil)
          cookies = cookies(CookieJar.origin_for(uri))
          return {} if cookies.empty?

          cookies.inject({}) do |acc, cookie|
            acc[cookie.name] = cookie if cookie.domain == domain && cookie.path == path
            acc
          end
        end

        def cookie_hash_for(url)
          @origins[CookieJar.origin_for(url)] || {}
        end

        def insert_or_expire(url, cookie)
          origin = CookieJar.origin_for(url)
          @origins[origin] ||= {}
          @origins[origin][cookie.name] ||= []
          cookies = @origins[origin][cookie.name]

          if match_index = cookies.find_index {|c| c.match?(cookie) }
            return cookies.delete_at(match_index) if cookie.expires && cookie.expires < Time.now
            cookies[match_index] = cookie
          elsif cookie.expires.nil? || cookie.expires > Time.now
            cookies << cookie
          end

          cookies
        end

      end
    end
  end
end
