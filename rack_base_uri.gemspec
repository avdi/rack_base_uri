Gem::Specification.new do |spec|
  spec.name                     = 'rack_base_uri'
  spec.version                  = "0.0.4"
  spec.author                   = 'Avdi Grimm'
  spec.email                    = 'avdi@avdi.org'
  spec.homepage                 = "http://github.com/avdi/rack_base_uri/"
  spec.summary  =
    'A Rack middleware for automatically setting [X]HTML document base URIs.'
  spec.description = <<-EOF
A middleware to automatically set the base URI for [X]HTML documents. This is
useful when you want to mount a web application on a subdirectory,
e.g. http://example.org/myapp/
EOF

  spec.has_rdoc                 = true

  spec.platform                 = Gem::Platform::RUBY
  spec.required_ruby_version    = '>= 1.8.0'

  spec.add_dependency('rack', "0.3.0")
  spec.add_dependency('hpricot', "0.6")

  spec.files                    = [
    # Misc
    'README',

    # Libraries
    'lib/rack_base_uri.rb',
    'lib/rack_base_uri/version.rb',

    # Specifications
    'spec/spec_helper.rb',
    'spec/rack_base_uri_spec.rb',
  ]
end
