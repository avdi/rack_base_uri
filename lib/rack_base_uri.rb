$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
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
        env['rack.url_scheme'] + '://' + env['SERVER_NAME']  + ':' + env['SERVER_PORT']
      }
      base    = host + env['SCRIPT_NAME']
      result  = @app.call(env)
      headers = result[1]
      doc     = Hpricot(result[2].to_s)
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
