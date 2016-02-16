Feature: Running the simplest OpenVPN server

  @dataVolume @fetchIP @announce-command @announce-stderr @announce-stdout
  Scenario: Start a server

    Given a configured OpenVPN instance with "-D -d"
    And a running OpenVPN process
    And a configured client named "first-client"

    When I run "first-client" openvpn client in docker

    Then client "first-client" should be connected to VPN network

    When I run `ping -c 1 192.168.255.1` from client "first-client"
    Then the exit status should be 0
