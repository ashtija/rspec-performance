require "#{File.dirname(__FILE__)}/../../../../spec_helper"

describe Spec::Client::Http::Cookie do
  describe ".parse" do
    attr_reader :cookie_string
    before do
      @cookie_string = "RMID=a%20b; expires=Fri, 31-Dec-2010 23:59:59 GMT; path=/; domain=.example.net"
    end

    it "parses a cookie string and returns a Cookie" do
      cookie = Spec::Client::Http::Cookie.parse(cookie_string)
      cookie.name.should    == "RMID"
      cookie.value.should   == "a b"
      cookie.domain.should  == ".example.net"
      cookie.path.should    == "/"
      cookie.expires.should be_a(Time)
      cookie.expires.to_i.should == Time.parse("31-Dec-2010 23:59:59 GMT").to_i
    end
  end

  describe "#match?" do
    def cookie_match(cookie_str1, cookie_str2)
      cookie1 = Spec::Client::Http::Cookie.parse(cookie_str1)
      cookie2 = Spec::Client::Http::Cookie.parse(cookie_str2)
      cookie1.match?(cookie2)
    end

    describe "when the cookie matches on name, domain and path" do
      it "returns true" do
        cookie_match("a=b", "a=c").should be_true
        cookie_match("a=b; domain=; path=", "a=c").should be_true
        cookie_match("a=b; path=", "a=c").should be_true
        cookie_match("a=b; domain=", "a=c").should be_true
        cookie_match("a=b; domain=.x.y.z; path=/foo", "a=c; domain=.x.y.z; path=/foo").should be_true
      end
    end

    describe "when the cookie DOES NOT match on name, domain and path" do
      it "returns false" do
        cookie_match("x=y", "a=c").should be_false
        cookie_match("x=y; path=/", "x=z").should be_false
        cookie_match("x=y; path=/", "x=z; path=").should be_false
        cookie_match("x=y; domain=.x.y.z", "x=z; domain=.u.y.z").should be_false
      end
    end
  end
end