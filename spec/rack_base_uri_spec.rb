require File.dirname(__FILE__) + '/spec_helper.rb'
require 'rubygems'
require 'rack/mock'
require 'rack/urlmap'
require 'hpricot'

describe Rack::BaseUri do

  # This class is used to keep us honest... we can only depend on the content
  # responding to each, not necessarily that it is Array-like.
  class ContentStream
    def initialize(content)
      @content = content
    end

    def each
      @content.each do |chunk|
        yield chunk
      end
    end
  end
  
  before :each do
    @headers = {'Content-Type' => 'text/html'}
    @body    = <<-HTML
      <html>
        <head>
          <title>Test Page</title>
        </head>
         <body>Hello World</body>
      </html>
    HTML
    @result  = [
      200,
      @headers,
      ContentStream.new(@body)
    ]
    @app     = stub("app", :call => @result)
    @it      = Rack::BaseUri.new(@app)
    @base    = 'http://example.org/subdir'
    @host    = 'http://example.org'
  end

  def do_request
    @map      = Rack::URLMap.new({@base => @it})
    @request  = Rack::MockRequest.new(@map)
    @response = @request.get("/subdir/foo", 'HTTP_HOST' => @host, :lint => true)
    @doc      = Hpricot(@response.body)
  end

  describe "with HTML content" do
    it "should add a base element to the HTML" do
      do_request
      @response.should be_ok
      tag = @doc.at("head base")
      tag.should_not be_nil
      tag['href'].should == "http://example.org/subdir/"
    end

    describe "with a HTTP_HOST of example.org" do
      before :each do
        @host = "example.org"
      end

      it "should ensure base uri starts with URL scheme" do
        do_request
        @response.should be_ok
        tag = @doc.at("head base")
        tag['href'].should == "http://example.org/subdir/"
      end
    end

  end
  describe "with application/xhtml+xml content type" do
    before :each do
      @headers['Content-Type'] = 'application/xhtml+xml'
    end

    it "should add a base element to the HTML" do
      do_request
      @response.should be_ok
      html = @doc.at("html")
      html.should_not be_nil
      html['xml:base'].should == "http://example.org/subdir/"
    end
  end

  describe "with text/xml content type" do
    before :each do
      @headers['Content-Type'] = 'text/xml'
    end

    it "should add a base element to the HTML" do
      do_request
      @response.should be_ok
      html = @doc.at("html")
      html.should_not be_nil
      html['xml:base'].should == "http://example.org/subdir/"
    end
  end

  describe "with text/xml content type but non-HTML content" do
    before :each do
      @headers['Content-Type'] = 'text/xml'
      @content = "<foo></foo>"
      @body.replace(@content)
    end

    it "should leave the content alone" do
      do_request
      @response.should be_ok
      @response.body.should == @content
    end
  end

  describe "with text/html content type but plain text content" do
    before :each do
      @headers['Content-Type'] = 'text/html'
      @content = "Not HTML"
      @body.replace(@content)
    end

    it "should leave the content alone" do
      do_request
      @response.should be_ok
      @response.body.should == @content
    end
  end
end
