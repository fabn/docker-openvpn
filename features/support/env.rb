require 'aruba/cucumber'
require 'system/getifaddrs'
require 'pry'

Around('@dataVolume') do |scenario, block|
  @data_volume = 'ovpn-data'
  step %Q{I have a clean data volume named "#{@data_volume}"}
  # Move to a temporary directory with client stuff
  create_directory 'clients'
  # Execute scenario
  block.call
end

Before('@fetchIP') do
  if ENV['SERVER_IP']
    @ip_address = ENV['SERVER_IP']
  else
    # Autodetect server ip addresses using eth0 or the given interface
    iface = System.get_ifaddrs[ENV.fetch('IFACE', 'eth0').to_sym]
    pending "Cannot detect ip address for interface #{ENV.fetch('IFACE', 'eth0')}" unless iface
    # Store detected ip address in steps
    @ip_address = iface[:inet_addr]
  end
end
