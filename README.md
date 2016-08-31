# rackspace_lb_cli
This is a cli tool for the management of loadbalancers in the Rackspace public cloud.

## Motivation
Unlike other components in the Rackspace Cloud the cloud loadbalancers are not based on Openstack. There is an API for managing those loadbalancers, but the Openstack tools are not compatible with that API. But there is a open-source ruby gem called "fog" which supports this API. rackspace_lb_cli is a ruby based cli tool based on the fog library.

## Build the gem
gem build rackspace_lb_cli.gemspec

## Spec Test
1. Source you Rackspace credentials
2. Define two cloud server you like to use for the test, e.g. export lb_backends=foo:443,bar:8443
3. bundle install
4. bundle exec rake spec

This should give something like:

```
$ rake
/home/aj/.rbenv/versions/2.1.10/bin/ruby -I/home/aj/.rbenv/versions/2.1.10/lib/ruby/gems/2.1.0/gems/rspec-support-3.4.1/lib:/home/aj/.rbenv/versions/2.1.10/lib/ruby/gems/2.1.0/gems/rspec-core-3.4.4/lib /home/aj/.rbenv/versions/2.1.10/lib/ruby/gems/2.1.0/gems/rspec-core-3.4.4/exe/rspec --pattern spec/\*\*\{,/\*/\*\*\}/\*_spec.rb
........

Finished in 1 minute 25.42 seconds (files took 0.35542 seconds to load)
8 examples, 0 failures
```

## Installation
gem install rackspace_lb_cli*.gem
(Not available on rubygems.org yet).

## Usage
The gems ship an executable, if your $PATH is set up correctly you can run from the shell:
    $ rackspace_lb_cli --help
This will show the help. You will need to inject yout rackspace credentials. This can be done by exporting environment variables to via cli options.

## Usage Examples
    source environment-myrackspace
    rackspace_lb_cli --name my-loadbalancer --port 443 --protocol HTTPS --backends someserver:8443,someotherserver:443,someveryotherserver

## Help Output
> Usage: rackspace_lb_cli [options]
> 
> Common options for all actions
>     -k, --rs-apikey rs_apikey        Rackspace Api Key [RS_API_KEY]
>     -u, --rs-username rs_username    Rackspace username [RS_USERNAME]
>     -r, --rs-region rs_region        Rackspace region, defaults to LON [RS_REGION]
>     -h, --help                       Show this message
>     -v, --version                    Show version
> Options for the various actions
>     -a, --action action              [create|destroy|add|remove|list|describe]
>                                      create loadbalancer,destroy loadbalancer, add backends, remove backends
>                                      list list all loadbalancers, desc describe a specific loadbalancer
>     -n, --name lb_name               A Name for the loadbalancer
>     -p, --port port                  The numeric port number, the loadbalancer should listen to
>     -o, --protocol proto             The protocol. HTTPS is default
>     -b, --backends x,y,z             Comma-separated list of backends. Can be in the form backend:port
>     -d, --debug                      Send debug output to stderr. For developers.
    
## Bugs?
Probably. Please open a issue in the github project.

## Patches?
Pull requests welcome.

## Features?
Still some missing. I implemented what I really needed, so in section TODO what's still open.

## Todo
- Use arbitrary IPs as backends ("External Nodes")
- Fine grained configuration of the health checks
- VIP Type (currently 'PUBLIC' is not overrideable)
- Added an output type JSON for better post-processing
- Creating a LB and added backends with one cli call


