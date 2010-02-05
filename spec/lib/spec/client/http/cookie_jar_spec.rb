require "#{File.dirname(__FILE__)}/../../../../spec_helper"

describe Spec::Client::Http::CookieJar do
  attr_reader :jar
  before do
    @jar = Spec::Client::Http::CookieJar.new
  end

  describe ".origin_for" do
    it "retrieves the 'authoritative' TLD for the specified url" do
      klass = Spec::Client::Http::CookieJar
      klass.origin_for("http://example.com/foo").should == "example.com"
      klass.origin_for("http://forums.example.com/foo").should == "example.com"
      klass.origin_for("http://localhost/foo").should == "localhost"
      klass.origin_for("http://x.localhost/foo").should == "localhost"
      klass.origin_for("http://0.0.0.0/foo").should == "0.0.0.0"
    end
  end

  describe "#cookies" do
    it "retrieves all cookies for an origin" do
      cookie = Spec::Client::Http::Cookie.parse("foo=bar")

      jar.put("http://example.com", cookie)
      jar.cookies("example.com").should == [cookie]
      jar.cookies("example.org").should be_empty
    end
  end

  describe "#put" do
    attr_reader :url, :origin
    before do
      @url = "http://example.com"
      @origin = Spec::Client::Http::CookieJar.origin_for(url)
    end

    describe "insertion behavior" do
      it "separates cookies by their name, domain and path" do
        jar.put(url, "foo=bar")
        jar.put(url, "foo=baz; domain=.forums.example.com")
        jar.put(url, "foo=quux; domain=.forums.example.com; path=/")

        cookies = jar.cookies(Spec::Client::Http::CookieJar.origin_for(url))
        cookies.size.should == 3
        cookies.detect {|cookie| cookie.domain == nil}.value.should == "bar"
        cookies.detect {|cookie| cookie.domain == ".forums.example.com" && cookie.path == nil}.value.should == "baz"
        cookies.detect {|cookie| cookie.domain == ".forums.example.com" && cookie.path == "/"}.value.should == "quux"
      end
    end

    describe "when the cookie is new" do
      it "inserts the cookie" do
        jar.put(url, "newcookie=value")
        jar.cookies(Spec::Client::Http::CookieJar.origin_for(url)).size.should == 1
      end
    end

    describe "when the cookie already exists in the cookie jar" do
      it "updates the cookie" do
        jar.put(url, "a=1; domain=.a.example.com; path=/")
        jar.cookies(origin).size.should == 1
        jar.cookies(origin).detect {|c| c.domain == ".a.example.com" && c.path == "/" }.value.should == "1"

        jar.put(url, "a=2")
        jar.cookies(origin).size.should == 2
        jar.cookies(origin).detect {|c| c.domain == nil && c.path == nil }.value.should == "2"
        jar.cookies(origin).detect {|c| c.domain == ".a.example.com" && c.path == "/" }.value.should == "1"

        jar.put(url, "a=3; domain=.a.example.com; path=/")
        jar.cookies(origin).size.should == 2
        jar.cookies(origin).detect {|c| c.domain == nil}.value.should == "2"
        jar.cookies(origin).detect {|c| c.domain == ".a.example.com" && c.path == "/" }.value.should == "3"
      end
    end

    describe "when the cookie being added has an expiration date in the past" do
      it "removes the cookie from the cookie jar" do
        jar.put(url, "a=1")
        jar.put(url, "b=2")

        jar.cookies(origin).size.should == 2
        jar.cookies(origin).detect {|c| c.name == "a" }.value.should == "1"
        jar.cookies(origin).detect {|c| c.name == "b" }.value.should == "2"

        expired_date = (Time.now - 1).httpdate
        jar.put(url, "a=1; expires=#{expired_date}")

        jar.cookies(origin).size.should == 1
        jar.cookies(origin).detect {|c| c.name == "a" }.should be_nil
        jar.cookies(origin).detect {|c| c.name == "b" }.value.should == "2"
      end
    end
  end

  describe "#get" do
    it "gets the cookie for a specific url" do
      url = "http://www.example.com"

      # Test exclusion of paths
      jar.put(url, "foo=bar; path=/bar")
      jar.get("http://www.example.com/foo").should be_empty
      jar.get("http://www.example.com/bar").size.should == 1
      jar.get("http://www.example.com/bar").first.value.should == "bar"

      # Test inclusion of unspecified path
      jar.put(url, "bing=bong")
      jar.put(url, "beer=drunk; path=/foo")
      cookies = jar.get("http://www.example.com/foo?x=y")
      cookies.size.should == 2
      cookies.detect {|c| c.name == "bing" }.value.should == "bong"
      cookies.detect {|c| c.name == "beer" }.value.should == "drunk"

      # Test inclusion of unspecified domain - probably breaks RFC compliance
      jar.put(url, "hokey=pokey; domain=.forums.example.com")
      jar.put(url, "hokey=dokey; domain=.www.example.com")
      cookies = jar.get("http://forums.example.com/some/path")
      cookies.detect {|c| c.name == "hokey" }.value.should == "pokey"
    end

    it "excludes and evicts expired cookies"
  end
end