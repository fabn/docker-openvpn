Given(/^a configured OpenVPN instance with "([^"]*)"$/) do |flags|
  # Configure the server using a clean data volume and detected ip address
  run_simple %Q{docker run --volumes-from #{@data_volume} --rm kylemanna/openvpn ovpn_genconfig -u udp://#{@ip_address} #{flags}}
  # Build a passwordless PKI, it may take long time to complete. Give it 2 minutes to complete
  run_simple %Q{docker run --volumes-from #{@data_volume} --rm -e "EASYRSA_BATCH=1" kylemanna/openvpn ovpn_initpki nopass}, exit_timeout: 120
end

Given(/^a running OpenVPN process$/) do
  # This will run the server image and immediately detach.
  run %Q{docker run --volumes-from #{@data_volume} --rm -p 1194:1194/udp --privileged kylemanna/openvpn}
  # With this variable running server can be accessed later
  @running_server = last_command_started
end

Given(/^a configured client named "([^"]*)"$/) do |client_name|
  # Build certificate for client
  run_simple %Q{docker run --volumes-from #{@data_volume} --rm kylemanna/openvpn easyrsa build-client-full #{client_name} nopass}
  # Get client configuration
  run_simple %Q{docker run --volumes-from #{@data_volume} --rm kylemanna/openvpn ovpn_getclient #{client_name}}
  # Save client config in a named file in clients folder
  step %Q{a file named "clients/#{client_name}.ovpn" with:}, last_command_started.stdout
end


When(/^I run "([^"]*)" openvpn client in docker$/) do |client_name|
  # Start openvpn client with the generated config (it must exist)
  openvpn_client = %Q{openvpn --config "/clients/#{client_name}.ovpn"}
  cd 'clients' do
    # Run client daemon in background and return control to process, wait 5 seconds before returing to give time to docker to start
    run %Q{docker run --rm --net=host --privileged --name #{client_name} --volume #{Dir.getwd}:/clients kylemanna/openvpn #{openvpn_client}}, startup_wait_time: 5
  end
end

When(/^I run `([^`]*)` from client "([^"]*)"$/) do |cmd, client|
  run_simple %Q{docker exec #{client} #{cmd}}
end