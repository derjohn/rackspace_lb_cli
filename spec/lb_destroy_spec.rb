# a file named "spec/thing_spec.rb" with:
require_relative '../lib/rackspace_lb_cli.rb'

RSpec.configure do |config|
  config.before(:example) {
    @binpath     = Dir.pwd + '/bin/rackspace_lb_cli_wrapper.sh'
    @lb_name     = 'rackspace-lb-cli-spectest-delme'
  }
end

def find_lb
  %x(#{@binpath} --action list).to_s.match(/#{@lb_name}/)
end

RSpec.describe 'Run various cli actions.' do
  it 'Destroy loadbalancer' do
    if ! find_lb
      fail "Loadbalancer #{@lb_name} cannot be destroyed . It does not exist."
    end
    output_destroy = %x(#{@binpath} --action destroy --name #{@lb_name}).to_s.chomp
    sleep 20 # destroy needs some time.
    if find_lb
      fail "Loadbalancer #{@lb_name} should not exist after calling destroy."
    end
  end

end
