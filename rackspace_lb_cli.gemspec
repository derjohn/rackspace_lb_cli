# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'rackspace_lb_cli'
  spec.version       = '0.2.2'
  spec.authors       = ['Andreas John']
  spec.email         = ['himself@derjohn.de']
  spec.summary       = %q{ This is a cli tool for the management of loadbalancers in the Rackspace public cloud. }
  spec.description   = %q{ This is a cli tool for the management of loadbalancers in the Rackspace public cloud. }
  spec.homepage      = 'https://github.com/derjohn/rackspace_lb_cli' 
  spec.license       = 'Apache-2.0'

  spec.files         = ['bin/rackspace_lb_cli','lib/rackspace_lb_cli.rb']
  spec.executables   = ['rackspace_lb_cli']

  spec.add_dependency 'fog', '~> 1.38'
  spec.add_dependency 'fog-rackspace', '~> 0.1', '>= 0.1.1'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.3', '>= 10.3.2'
  spec.add_development_dependency 'rspec', '~> 0'

end
