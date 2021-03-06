{% set egress_iface = pillar['network']['egress']['iface'] %}

{% set int_iface = pillar['network']['internal']['iface'] %}
{% set int_ip_addr = pillar['network']['internal']['gateway'] %}
{% set int_netmask = pillar['network']['internal']['netmask'] %}

{% set arch_ipaddr = pillar['network']['dhcpd']['hosts']['arch']['ipaddr'] %}

/etc/hostname.{{ int_iface }}:
    file.managed:
        - user: root
        - group: wheel
        - mode: 640
        - contents: |
            inet {{ int_ip_addr }} {{ int_netmask }}

plumb-iface-{{ int_iface }}:
    cmd.run:
        - name: /bin/sh /etc/netstart {{ int_iface }}
        - onchanges:
            - file: /etc/hostname.{{ int_iface }}

/etc/pf.conf:
    file.managed:
        - user: root
        - group: wheel
        - mode: 600
        - contents: |
            # vim: syntax=pf
            set skip on lo
            block return quick inet6

            # nat rewrite all traffic from non-egress int_iface networks to egress
            match out on {{ egress_iface }} inet from !({{ egress_iface }}:network) to any nat-to ({{ egress_iface }}:0)

            # joe's redirect
            pass in log quick on {{ egress_iface }} inet proto tcp \
                 from any to ({{ egress_iface }}) port 11011 \
                 rdr-to {{ arch_ipaddr }} port ssh

            # normalized fragmented packets, anonymize our tcp-id's
            match in all scrub (no-df random-id reassemble tcp)

            # allow all outbound traffic
            pass out quick

            # allow all inbound lan traffic
            pass in quick on !{{ egress_iface }}

            # block all remaining traffic
            block return log on {{ egress_iface }}

pfctl -f /etc/pf.conf:
    cmd.run:
        - watch:
            - file: /etc/pf.conf

refresh-firewall-ruleset:
    cmd.wait:
        - name: pfctl -f /etc/pf.conf
        - onchanges:
            - file: /etc/pf.conf

persist-ip-forwarding:
    file.append:
        - name: /etc/sysctl.conf 
        - text:
            - net.inet.ip.forwarding=1

full-pflog-snaplen:
    file.append:
        - name: /etc/rc.conf.local
        - text:
            # get full MTU sized contents
            - pflogd_flags="-s 1500"

enable-ip-forwarding:
    cmd.run:
        - name: sysctl net.inet.ip.forwarding=1
        - onlyif: [ X"$(sysctl net.inet.ip.forwarding)" != X"net.inet.ip.forwarding=1" ]
