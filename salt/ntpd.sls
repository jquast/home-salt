ntpd:
   service.running:
       - enable: True
       - flags: "-sv"
       - watch:
           - file: /etc/ntpd.conf

/etc/ntpd.conf:
    file.managed:
        - user: root
        - owner: wheel
        - mode: 640
        - contents: |
            listen on {{ pillar['network']['internal']['gateway'] }}
            {% set ntpd_servers = pillar['network']['ntpd']['servers'] %}
            {% for server_name, ntpcfg in ntpd_servers.items() %}
            # {{ ntpcfg.get('description', '') }}
            {% set server = "server" -%}
            {%- if ntpcfg.get('pool', False) -%}
            {%-   set server = "servers" -%}
            {%- endif -%}
            {{ server }} {{ server_name }} weight {{ ntpcfg.get('weight', 1) }}
            {%- endfor %}
