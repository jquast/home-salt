{% set dhcp_iface = pillar['network']['dhcp_client']['iface'] %}
{% set dns_servers = pillar['network']['dns_servers'] | join(", ") %}
{% set my_name = pillar['network']['egress']['name'] %}
{% set my_domain = pillar['network']['domain'] %}

/etc/hostname.{{ dhcp_iface }}:
    file.managed:
        - user: root
        - group: wheel
        - mode: 640
        - contents: |
            !rm -f /var/db/dhclient.leases.vio0
            dhcp

/etc/dhclient.conf:
    file.managed:
        - user: root
        - group: wheel
        - mode: 644
        - contents: |
            send host-name "{{ my_name }}";
            supersede domain-name "{{ my_domain }}";
            request subnet-mask, broadcast-address, routers;
            supersede domain-name-servers {{ dns_servers }};

/usr/local/bin/update-hover-dns.py:
    file.managed:
        - user: root
        - group: wheel
        - mode: 755
        - source: salt://files/update-hover-dns.py

configure-dhcp-iface:
    cmd.run:
        - name: /bin/sh /etc/netstart {{ dhcp_iface }}
        - onchanges:
            - file: /etc/hostname.{{ dhcp_iface }}
            - file: /etc/dhclient.conf

{% if pillar.get('secrets', 'hover-username') %}
{% set _egress_iface = pillar['network']['egress']['iface'] %}
{% set _egress_dnsname = pillar['network']['egress']['name'] %}
{% set _egress_domainname = pillar['network']['egress']['domain'] %}
{% set egress_ip = salt['network.ip_addrs'](_egress_iface)[0] %}
{% set egress_name = _egress_dnsname + "." + _egress_domainname %}

update-hover-dns:
    cmd.run:
         # set external interface ip addres
         - name: /usr/local/bin/update-hover-dns.py {{ egress_ip }} {{ egress_name }}
         - env:
             - HOVER_USERNAME: {{ pillar['secrets']['hover-username'] }}
             - HOVER_PASSWORD: {{ pillar['secrets']['hover-password'] }}
#         - onchanges:
#             - file: /usr/local/bin/update-hover-dns.py
#             - cmd: configure-dhcp-iface

{% endif %}
