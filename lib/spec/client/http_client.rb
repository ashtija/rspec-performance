require "spec/client/http/session"

module Spec
  module Client
    class HttpClient
      attr_reader :session, :base_uri
      
      def initialize(base_uri)
        @base_uri = base_uri
        @session = Http::Session.new(self)
      end
      
      def get(path, params = {})
        session.get(full_url(path), params)
      end
      
      def post(path, params = {})
        session.post(full_url(path), params)
      end
      
      def full_url(path)
        URI.join(base_uri, path).to_s
      end
      
    end
  end
end
