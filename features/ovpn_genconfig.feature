Feature: Configure OpenVPN server process using ovpn_genconfig
  The first step to run an OpenVPN server instance is server configuration generation.
  In order to do that the `ovpn_genconfig` must be used

  Background: A clean data volume exist
    Given I have a clean data volume named "ovpn-data"

  Scenario: Default configuration
    When I run `docker run --volumes-from ovpn-data --rm kylemanna/openvpn ovpn_genconfig -u udp://vpn.example.com`

    Then server configuration file should contain all of these lines:
      | ca /etc/openvpn/pki/ca.crt |
      | proto udp                  |
      | persist-key                |
      | persist-tun                |
      | user nobody                |
      | group nogroup              |

    And server environment should contain variable "OVPN_CN" with value "vpn.example.com"
    And server environment should contain variable "OVPN_SERVER_URL" with value "udp://vpn.example.com"

  Scenario: OTP configuration
    When I run `docker run --volumes-from ovpn-data --rm kylemanna/openvpn ovpn_genconfig -u udp://vpn.example.com -2`

    Then server configuration file should contain:
    """
    plugin /usr/lib/openvpn/plugins/openvpn-plugin-auth-pam.so openvpn
    """
