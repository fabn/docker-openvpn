Then(/^server configuration file should contain:$/) do |text|
  # Dump server configuration to stdout
  step %q{I run `docker run --volumes-from ovpn-data --rm kylemanna/openvpn cat /etc/openvpn/openvpn.conf`}
  step %q{the stdout should contain:}, text
end

Then(/^server configuration file should contain all of these lines:$/) do |lines|
  step %q{I run `docker run --volumes-from ovpn-data --rm kylemanna/openvpn cat /etc/openvpn/openvpn.conf`}
  step %q{the output should contain all of these lines:}, lines
end

And(/^server environment should contain variable "([^"]*)" with value "([^"]*)"$/) do |variable, value|
  step %q{I run `docker run --volumes-from ovpn-data --rm kylemanna/openvpn cat /etc/openvpn/ovpn_env.sh`}
  step %Q{the output should match %r<#{variable}=["']?#{value}["']?$>}
end