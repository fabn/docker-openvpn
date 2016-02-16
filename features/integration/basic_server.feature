Feature: Running the simplest OpenVPN server

  @dataVolume @fetchIP @announce-command @announce-stderr @announce-stdout
  Scenario: Start a server

    Given a configured OpenVPN instance with "-D -d"
    And a running OpenVPN process
    And a configured client named "first-client"

    When I run "first-client" openvpn client in docker

    When I run `ping -c 1 10.10.10.1` from client "first-client"
    Then the exit status should be 0

    # Then client "foo" should be connected to VPN network

    # When I run `ls /clients` in client "first-client"
