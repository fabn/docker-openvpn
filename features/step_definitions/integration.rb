Given(/^a configured OpenVPN instance with "([^"]*)"$/) do |flags|
  # Configure the server using a clean data volume and detected ip address
  run_simple %Q{docker run --volumes-from #{@data_volume} --rm kylemanna/openvpn ovpn_genconfig -u tcp://ovpn-server #{flags}}
  # Build a passwordless PKI, it may take long time to complete. Give it 2 minutes to complete
  run_simple %Q{docker run --volumes-from #{@data_volume} --rm -e "EASYRSA_BATCH=1" kylemanna/openvpn ovpn_initpki nopass}, exit_timeout: 120
end

Given(/^a running OpenVPN process$/) do
  # This will run the server image and immediately detach.
  run %Q{docker run --volumes-from #{@data_volume} --name ovpn-server --rm -p 1194:1194 --cap-add=NET_ADMIN kylemanna/openvpn}, startup_wait_time: 10
  # With this variable running server can be accessed later
  @running_server = last_command_started
end

Given(/^a configured client named "([^"]*)"$/) do |client_name|
  # Build certificate for client
  run_simple %Q{docker run --volumes-from #{@data_volume} --rm kylemanna/openvpn easyrsa build-client-full #{client_name} nopass}
  # Get client configuration
  run_simple %Q{docker run --volumes-from #{@data_volume} --rm kylemanna/openvpn ovpn_getclient #{client_name}}
  # Save client config in a named file in clients folder
  write_file("clients/#{client_name}.ovpn", last_command_started.stdout)
end


When(/^I run "([^"]*)" openvpn client in docker$/) do |client_name|
  @clients ||= {}
  # Start openvpn client with the generated config (it must exist)
  openvpn_client = %Q{openvpn --config "/clients/#{client_name}.ovpn"}
  cd 'clients' do
    # Use container linking to make client connection working, mount client config volume and rm it when done
    docker_options = %Q{--rm --cap-add=NET_ADMIN --name #{client_name} --link ovpn-server:ovpn-server --volume #{Dir.getwd}:/clients}
    # Run client daemon in background and return control to process, wait 15 seconds before returing to give time to docker to start
    run %Q{docker run #{docker_options} kylemanna/openvpn #{openvpn_client}}, startup_wait_time: 15
  end
  # Save client command instance to retrieve it later
  @clients[client_name.to_sym] = last_command_started
end

Then(/^client "([^"]*)" should be connected to VPN network$/) do |client|
  # Client command stdout should have finished initialization sequence and be connected
  expect(@clients[client.to_sym]).to have_output an_output_string_including('Initialization Sequence Completed')
end

When(/^I run `([^`]*)` from client "([^"]*)"$/) do |cmd, client|
  run_simple %Q{docker exec #{client} #{cmd}}
end

# Launch an interactive debugging session
When(/^i start a pry session$/) do
  binding.pry
end