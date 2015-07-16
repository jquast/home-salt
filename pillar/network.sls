# arrows indicate egress network traffic direction
#
#                               big bad internet
#                                      ^
#                                      |
#                                      ^
#                            +---------+-----------+
#                            |cablemodem (comcast) |
#                            +---------+-----------+
#                                      ^
#                                      |                                    wireless folk
#                                      |                                         +
#                                      ^                                         V
#   +----------------------------------+----------+                              |
#   |1, eth0: 172.156.19.100|2, vio0: (egress)    |                              |
# +<+host vm, nas device    |openbsd vm           |                              |
# | |nas.modem.xyz          |cable.modem.xyz      |                              V
# | +---------------------------------------------+         +--------------------------+
# | |3, eth3: 172.16.19.14  |4, vio1: 172.16.19.84|         |Apple Airport Express     |
# | |archlinux vm           |openbsd vm           +<-------<+Management IP: 172.16.19.1|
# | |arch.modem.xyz         |gw.modem.xyz         |         |Bridge: Ext, Int, Wifi    |
# | +---------------------------------------------+         +-------------------+------+
# |              V                                                              ^
# |              |                                                              |
# |              +----------------------------------------------+               |
# |                                                             V               |
# |                                                         +-------------------+-+
# |                                                         |5 port network switch+
# |                                                         +-+-------------------+
# |                                                           ^         ^
# +-----------------------------------------------------------+         +---<+lan folk
#

network:
    domain: modem.xyz
    dns_servers:
        # gateway is a primary dns server
        - 172.16.19.84
        # opennic, (CA, US)
        #- 74.207.241.202
        # opennic, (CA, US)
        #- 104.245.33.185
        - 8.8.8.8
        - 8.8.4.4

    egress:
        iface: vio0
        name: cable
        domain: modem.xyz
        route_name: comcast-gw

    dhcp_client:
        iface: vio0

    # nas.modem.xyz acts as a secondary loghost
    loghost: 172.16.19.100

    internal:
        iface: vio1

        subnet: 172.16.0.0
        broadcast: 172.16.255.255
        netmask: 255.255.0.0

        gateway: 172.16.19.84
        gateway_name: gw

    dhcpd:
        iface: vio1
        range: 172.16.19.90 172.16.19.99
        hosts:
            # s/w port

            lightning:
               hwaddr: 68:5b:35:99:19:69
               ipaddr: 172.16.19.55
            docker:
               hwaddr: a8:20:66:20:34:71
               ipaddr: 172.16.19.56
            dockfi:
               hwaddr: 20:c9:d0:d2:d5:87
               ipaddr: 172.16.19.63
            phx:
               hwaddr: 6c:40:08:8d:9b:88
               ipaddr: 172.16.19.57
            nas:
               # interestingly enough, the nas is our host qemu-kvm
               # machine; we run within it.  It beats us to the boot
               # and is static-IP configured.
               hwaddr: 00:08:9b:f0:98:88
               ipaddr: 172.16.19.100
            arch:
               # another qemu-kvm host, arch linux
               hwaddr: 52:54:00:61:6b:e3
               ipaddr: 172.16.19.91
            ap:
               # apple airport runs in wireless and wired bridge-mode;
               # but requires an alias on the managed network for
               # system functions.
               hwaddr: 48:d7:05:ec:af:91
               ipaddr: 172.16.19.1

            # wifi-connected devices (mine)
            grey:
               # ipod
               hwaddr: 88:1f:a1:dd:a1:f4
               ipaddr: 172.16.19.58

            black:
               # blackphone
               hwaddr: d8:3c:69:48:34:3c
               ipaddr: 172.16.19.59

            0c30210212a6:
               # "sky diamond"
               # MAC Address: Apple
               hwaddr: 0c:30:21:02:12:a6
               ipaddr: 172.16.19.60

            fc2535caca53:
               # ??
               hwaddr: fc:25:3f:ca:ca:53
               ipaddr: 172.16.19.61

            843835432f4a:
               # "heatherlees-air"
               hwaddr: 84:38:35:43:2f:4a
               ipaddr: 172.16.19.62

            28c68ef9f973:
               # unknown, 172.16.19.90
               hwaddr: 28:c6:8e:f9:f9:73
               ipaddr: 172.16.19.90


    ntpd:
        servers:
            clock.fmt.he.net:
                description: "statum 1: Hurricane Electric, Fremont, CA"
                weight: 5
            timekeeper.delphij.net:
                description: "stratum 2: freebsd dev, Freemont, CA"
                weight: 3
            resolver1.level3.net:
                description: "stratum 3: level 3 networks, San Jose, CA"
                weight: 3
            time.apple.com:
                description: "stratum 1: Apple"
                weight: 2
                pool: True
            time.windows.com:
                description: "statum 2: Microsoft (160ms delay vs. 20ms in CA)"
                weight: 1
            nas.modem.xyz:
                # this thing is awful at keeping time :(
                description: "stratum 9: local area device"
                weight: 1
