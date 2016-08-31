# a file named "spec/thing_spec.rb" with:
require_relative '../lib/rackspace_lb_cli.rb'

RSpec.configure do |config|
  config.before(:example) {
    @binpath     = Dir.pwd + '/bin/rackspace_lb_cli_wrapper.sh'
    @lb_name     = 'rackspace-lb-cli-spectest-delme'
    @lb_backends = ENV['lb_backends']
  }
end

def find_lb
  %x(#{@binpath} --action list).to_s.match(/#{@lb_name}/)
end

RSpec.describe "Create LB #{Dir.pwd}" do
  it "Create LB #{Dir.pwd}" do 
    ARGV << '--help'
    class RackspaceLbCliStub < RackspaceLbCli
      def initialize
        # stub
      end
    end
    rbcli = RackspaceLbCliStub.new
    rbcli.cmdlineopts(ARGV)
  end
end

RSpec.describe 'Run various cli actions.' do
  it 'Version output should be working' do
    versionstring = %x(#{@binpath} -v).to_s.chomp
    if versionstring.empty?
      fail
    else
      true
    end
  end

  it 'Credentials should not be empty - without working credantials there is no test possible. No mocks are implemented for the fog lib.' do
    if ENV['RS_USERNAME'].nil?
      fail 'EnvVar RS_USERNAME must not be empty'
    end
    if ENV['RS_API_KEY'].nil?
      fail 'EnvVar RS_API_KEY must nit be empty'
    end
  end

  it 'Create loadbalancer' do
    if ! find_lb
      output_create = %x(#{@binpath} --action create --name #{@lb_name}).to_s.chomp
    else
      fail "Loadbalancer #{@lb_name} already exists"
    end
    if ! find_lb
      fail "Loadbalancer #{@lb_name} should exist after creating"
    end
  end

  it 'List existing loadbalancer' do
    output = %x(#{@binpath} --action list).to_s.chomp
    if output.empty?
      fail
    else
      true
    end
  end

  it 'Should add backend' do
    if ! find_lb
      fail "Loadbalancer #{@lb_name} does not exist. Backend cant be added"
    end
    output_add_lb_backends = %x(#{@binpath} --action add --name #{@lb_name} --backends #{@lb_backends}).to_s.chomp
  end

  it 'Describe LB and look for backends' do
    output_describe = %x(#{@binpath} --action describe --name #{@lb_name}).to_s.chomp
    @lb_backends.split(',').each do | be |
      be_name, be_port = be.split(':')
      be_port = be_port || '443'
      if ! output_describe.match(/:#{be_port}/)
        fail "Backend was not added: #{be} #{be_port}"
      end
    end
  end

end
