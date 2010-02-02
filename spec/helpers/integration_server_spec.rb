require "#{File.dirname(__FILE__)}/../spec_helper"

describe IntegrationServer do
  describe "HostEchoAdapter" do
    describe "when HTTP_HOST is set by the client" do
      it "echos the client specified value back" do
        uri = URI.parse("http://localhost:8888/host_echo")
        http = Net::HTTP.start(uri.host, uri.port)
        response = http.get(uri.request_uri, { "Host" => "x.y.z.com" })
        http.finish

        response.body.should include("x.y.z.com")
      end
    end

    describe "when HTTP_HOST is not set" do
      it "defaults to the machine name"
    end
  end
end
