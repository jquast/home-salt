# Simple home office ISC dhcpd server.

# external ip determined at highstate,
{% set _egress_iface = pillar['network']['egress']['iface'] %}
{% set egress_ip = salt['network.ip_addrs'](_egress_iface)[0] %}

# static valeus
{% set egress_name = pillar['network']['egress']['name'] %}
{% set domain_name = pillar['network']['domain'] %}
{% set dns_servers = pillar['network']['dns_servers'] | join(", ") %}
{% set subnet = pillar['network']['internal']['subnet'] %}
{% set netmask = pillar['network']['internal']['netmask'] %}
{% set broadcast = pillar['network']['internal']['broadcast'] %}
{% set gateway = pillar['network']['internal']['gateway'] %}
{% set gateway_name = pillar['network']['internal']['gateway_name'] %}
{% set dhcpd_iface = pillar['network']['dhcpd']['iface'] %}
{% set dhcp_range = pillar['network']['dhcpd']['range'] %}
{% set dhcp_hosts = pillar['network']['dhcpd']['hosts'] %}

dhcpd:
   service.running:
       - enable: True
       - flags: "{{ dhcpd_iface }}"
       - watch:
           - file: /etc/dhcpd.conf
           - file: /etc/hosts

dnsmasq:
    service.running:
       - enable: True
       - watch:
           - file: /etc/dnsmasq.conf

/etc/dhcpd.conf:
    file.managed:
        - mode: 644
        - user: root
        - group: wheel
        - contents: |
            option domain-name "{{ domain_name }}";
            option domain-name-servers {{ dns_servers }};
            subnet {{ subnet }} netmask {{ netmask }} {
                option broadcast-address {{ broadcast }};
                option routers {{ gateway }};
                option ntp-servers {{ gateway }};
                range {{ dhcp_range }};
                default-lease-time 1800;
                max-lease-time 86400;

                {%- for hostname, netcfg in dhcp_hosts.items() -%}
                host {{ hostname }} {
                        hardware ethernet {{ netcfg['hwaddr'] }};
                        fixed-address {{ netcfg['ipaddr'] }};
                }
                {% endfor -%}
            }
 
/etc/hosts:
    file.managed:
        - contents: |
            127.0.0.1	localhost
            ::1		localhost

            {{ egress_ip }}	{{ egress_name }}.{{ domain_name }} {{ gateway_name }}

            # static internal network gateway ip
            {{ gateway }}	{{ gateway_name }}.{{ domain_name }} {{ gateway_name }}

            # dhcpd-managed hosts,
            {%- for hostname, netcfg in dhcp_hosts.items() %}
            {{ netcfg['ipaddr'] }}	{{ hostname }}.{{ domain_name }} {{ hostname }}
            {% endfor %}

/etc/myname:
    file.managed:
        - user: root
        - group: wheel
        - mode: 644
        - contents: {{ gateway_name }}.{{ domain_name }}


/etc/dnsmasq.conf:
    file.managed:
       - user: root
       - group: wheel
       - mode: 644
       # or NS1.HOVER.COM ?
       - contents: |
           interface={{ dhcpd_iface }}
           domain={{ domain_name }}
