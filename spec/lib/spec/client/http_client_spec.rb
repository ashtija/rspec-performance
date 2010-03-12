require "#{File.dirname(__FILE__)}/../../../spec_helper"

describe Spec::Client::HttpClient do

  describe "#full_url" do
    it "creates a full url from base_uri and a path" do
      full_url = Spec::Client::HttpClient.new("http://example.com").full_url("foo")
      full_url.should == "http://example.com/foo"
    end
  end
end
