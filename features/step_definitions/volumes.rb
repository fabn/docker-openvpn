Given(/^I have a clean data volume named "([^"]+)"$/) do |data_container|
  `docker rm -f -v #{data_container} 2> /dev/null`
  `docker run --name "#{data_container}" -v /etc/openvpn busybox`
end