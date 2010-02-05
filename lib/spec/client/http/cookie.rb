module Spec
  module Client
    module Http
      class Cookie
        attr_accessor :name, :value, :domain, :path, :expires
        
        def initialize(params = {})
          @name   = params["name"]
          @value  = params["value"]
          @domain = params["domain"]
          @path   = params["path"]
          
          if exp = params["expires"]
            @expires = exp.is_a?(String) ? Time.parse(exp) : exp
          end
        end
        
        def match?(cookie)
          name == cookie.name && domain == cookie.domain && path == cookie.path
        end
        
        class << self
          def parse(cookie_string)            
            crumb_start = cookie_string.index(";")
            
            params = {}
            cookie = crumb_start ? cookie_string[0..crumb_start-1] : cookie_string
            params["name"], params["value"] = cookie.split(/\=/).map {|p| CGI::unescape(p) }
            
            if crumb_start
              crumbs = parse_crumbs(cookie_string[crumb_start..-1])
              params.merge!(crumbs)
            end
            
            new(params)
          end
          
          def parse_crumbs(crumb_string)
            crumb_string.split("; ").inject({}) do |acc, pair|
              name, value = pair.split(/\=/)
              acc[name] = value if name && value
              acc
            end
          end
        end
        
      end
    end
  end
end
