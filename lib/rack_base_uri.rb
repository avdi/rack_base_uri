$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'rack'
require 'hpricot'

module Rack
  class BaseUri
    def initialize(app)
      @app = app
    end

    def call(env)
      host    = env.fetch('HTTP_HOST') {
        env['SERVER_NAME']  + ':' + env['SERVER_PORT']
      }
      base    = host + env['SCRIPT_NAME']

      # Make sure it begins with e.g. 'http://'
      unless base =~ %r[://]
        base = (env['rack.url_scheme'] + '://' + base)
      end

      base.sub!(%r[/*$], '/')   # Make sure it ends with a '/'

      result  = @app.call(env)
      headers = result[1]

      # We have to get the content this way because the Rack spec only
      # guarantees the presence of an #each method that yields Strings.  We
      # can't expect #inject or #to_s or anything.
      content = ""
      result[2].each do |chunk|
        content << chunk
      end

      doc     = Hpricot(content)
      case headers['Content-Type']
      when 'text/html'
        (doc/'head').append("<base href='#{base}'>")
      when 'application/xhtml+xml', 'text/xml'
        root = doc.root
        if root.name.downcase == 'html'
          root['xml:base'] = base
        end
      end
      return [
        result[0],
        result[1],
        Array(doc.to_s)
      ]
    end
  end
end
