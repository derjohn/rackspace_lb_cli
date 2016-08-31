require 'fog' # http://www.rubydoc.info/github/fog/fog/Fog/Rackspace/LoadBalancers/LoadBalancer
require 'optparse' # http://ruby-doc.org/stdlib-1.9.3/libdoc/optparse/rdoc/OptionParser.html
require 'ostruct'

class RackspaceLbCli

  def initialize  
    @options = cmdlineopts(ARGV)
    @lb_api = init_rackspace_lb_api
    @nova_api = init_rackspace_nova_api

    debug "Action: #{@options.action.to_s}"

    case @options.action
    when :list
      list_lbs
    when :create
      # Create LB, Add BEs
      if get_lb(@options.lb_name,@options.lb_port,@options.lb_proto).nil?
        lb = create_lb(@options.lb_name,@options.lb_port,@options.lb_proto)
        health_monitor_lb(lb)
      end
    when :destroy
      # Destroy LB, BE are removed automatically
      if get_lb(@options.lb_name,@options.lb_port,@options.lb_proto)
        destroy_lb(@options.lb_name,@options.lb_port,@options.lb_proto)
      end
    when :add
      # Add BE to LB
      if lb = get_lb(@options.lb_name,@options.lb_port,@options.lb_proto)
        if @options.lb_backends
          @options.lb_backends.each do | be |
            be_name, be_port = be.split(':')
            be_port = be_port || @options.lb_port 
            cldsrv = get_server(be_name)
            if cldsrv
              add_backend(lb, cldsrv, be_port)
            end
          end
        end
      end
    when :remove
      # Remove BE from LB
      if lb = get_lb(@options.lb_name,@options.lb_port,@options.lb_proto)
        if @options.lb_backends
          @options.lb_backends.each do | be |
            be_name, be_port = be.split(':')
            be_port = be_port || @options.lb_port 
            cldsrv = get_server(be_name)
            if cldsrv
              remove_backend(lb, cldsrv, be_port)
            end
          end
        end
      end
    when :describe
      # Describe LB with it's backends
      if lb = get_lb(@options.lb_name,@options.lb_port,@options.lb_proto)
        describe_lb(lb)       
      end
    end
  end

  def debug(debugoutput)
    if @options.debug
      puts STDERR.puts(debugoutput)
    end
  end
  
  def init_rackspace_lb_api()
    Fog::Rackspace::LoadBalancers.new(
    :rackspace_username => @options.rs_username,
    :rackspace_api_key  => @options.rs_apikey,
    :rackspace_region   => @options.rs_region
    )
  end

  def init_rackspace_nova_api()
    Fog::Compute.new(
    :provider           => 'rackspace',
    :rackspace_username => @options.rs_username,
    :rackspace_api_key  => @options.rs_apikey,
    :rackspace_region   => @options.rs_region
    )
  end
  
  def get_lb(lb_name, lb_port, lb_proto)
    lb = @lb_api.load_balancers.all.find { |lb| lb.name == lb_name }
    if lb
      debug "LB object: name=#{lb.name.to_s} Port=#{lb.port.to_s} Proto=#{lb.protocol.to_s}"
      if lb.port.to_s == lb_port and lb.protocol.to_s == lb_proto
        return lb
      end
    end
    return nil
  end

  def create_lb(lb_name, lb_port = '443', lb_proto = 'HTTPS', lb_viptype = 'PUBLIC')
    if not get_lb(lb_name, lb_port, lb_proto)
      lb = @lb_api.load_balancers.create(
      :name        => lb_name,
      :protocol    => lb_proto,
      :port        => lb_port,
      :virtual_ips => [{ :type => lb_viptype }],
      :nodes       => []
      )
      lb.wait_for { ready? }
      return lb
    end
  end

  def destroy_lb(lb_name, lb_port, lb_proto)
    if lb = get_lb(lb_name, lb_port, lb_proto)
      lb.destroy
    end
  end

  def health_monitor_lb(lb, monitor=['CONNECT',10,10,3])
    lb.enable_health_monitor(*monitor)
    lb.wait_for { ready? }
  end

  def get_server(server_name)
    @nova_api.servers.all.find { |srv| srv.name == server_name }
  end

  def get_backend(lb, ip)
    lb.nodes.all.find { |nde| nde.address == ip }
  end

  def remove_backend(lb, be)
    be.destroy
    lb.wait_for { ready? }
  end

  def add_backend(lb, be, be_port)
    #if not be_port be_port = lb.port
    if not lb.nodes.all.find { |nde| nde.address == be.public_ip_address }
      lb.nodes.create(
      :address   => be.public_ip_address,
      :port      => be_port,
      :condition => 'ENABLED'
      )
      lb.wait_for { ready? }
    end
  end

  def list_lbs()
    @lb_api.load_balancers.all.each { |lb| puts "#{lb.id} | #{lb.name.ljust(30)} |  #{lb.port.to_s.ljust(5)} | #{lb.protocol.ljust(18)} | #{lb.virtual_ips.map{ |vip| vip.address }.join(',')}" }
  end

  def describe_lb(lb)
    puts "Id:       #{lb.id}"
    puts "Port:     #{lb.port}"
    puts "Proto:    #{lb.protocol}"
    puts "VIPs:     #{lb.virtual_ips.map{ |vip| vip.address }.join(',')}"
    puts "Backends:"
    puts "#{lb.nodes.map{ |nde| "          #{nde.address}:#{nde.port}" }.join("\n")}"
  end

  def cmdlineopts(args)

    # defaults
    options = OpenStruct.new
    options.action = :list
    options.rs_region = ENV['RS_REGION'] || 'LON'
    options.rs_apikey = ENV['RS_API_KEY']
    options.rs_username = ENV['RS_USERNAME']
    options.lb_port = '443'
    options.lb_proto = 'HTTPS'
    options.debug = false

    args.options do |opts|

      opts.banner = 'Usage: rackspace_lb_cli [options]'
      opts.separator ''

      opts.on_tail("-d", "--debug", "Send debug output to stderr. For developers.") do
        options.debug = true
      end
      
      opts.separator 'Common options for all actions'
      opts.on('-k','--rs-apikey rs_apikey','Rackspace Api Key [RS_API_KEY]') do |opt|
        options.rs_apikey = opt
      end
      
      opts.on('-u','--rs-username rs_username','Rackspace username [RS_USERNAME]') do |opt|
        options.rs_username = opt
      end

      opts.on('-r','--rs-region rs_region','Rackspace region, defaults to LON [RS_REGION]') do |opt|
        options.rs_region = opt
      end
            
      opts.on("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      opts.on('-v','--version', "Show version") do
        spec = Gem::Specification::load("rackspace_lb_cli.gemspec")
        puts spec.version
        exit
      end
   
      opts.separator 'Options for the various actions'   
      opts.on('-a','--action action','[create|destroy|add|remove|list|describe]','create loadbalancer,destroy loadbalancer, add backends, remove backends','list list all loadbalancers, desc describe a specific loadbalancer') do |opt|
        options.action = opt.to_sym
      end
      
      opts.on('-n','--name lb_name','A Name for the loadbalancer') do |opt|
        options.lb_name = opt
      end
  
      opts.on('-p','--port port','The numeric port number, the loadbalancer should listen to') do |opt|
        options.lb_port = opt
      end
  
      opts.on('-o','--protocol proto','The protocol. HTTPS is default') do |opt|
        options.lb_proto = opt
      end

      opts.on('-b','--backends x,y,z','Comma-separated list of backends. Can be in the form backend:port') do |opt|
        options.lb_backends = opt.split(',')
      end
            
    opts.parse!
    
    raise OptionParser::MissingArgument if options.rs_username.nil?
    raise OptionParser::MissingArgument if options.rs_apikey.nil?
        
    end

    return options
  end
end
