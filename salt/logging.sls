/etc/syslog.conf:
    - user: root
    - group: wheel
    - mode: 644
    - source: salt://files/syslog.conf
    - template: jinja
    - context:
        loghost: {{ pillar['network']['loghost'] }}
