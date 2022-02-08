{% from 'ssl/map.jinja' import HOSTNAME %}
{% from 'ssl/map.jinja' import MAINIP %}
{% from 'ssl/map.jinja' import ca_server %}

influxdb_key:
  x509.private_key_managed:
    - name: /etc/pki/influxdb.key
    - CN: {{ HOSTNAME }}
    - bits: 4096
    - days_remaining: 0
    - days_valid: 820
    - backup: True
    - new: True
    {% if salt['file.file_exists']('/etc/pki/influxdb.key') -%}
    - prereq:
      - x509: /etc/pki/influxdb.crt
    {%- endif %}
    - timeout: 30
    - retry:
        attempts: 5
        interval: 30

# Create a cert for the talking to influxdb
influxdb_crt:
  x509.certificate_managed:
    - name: /etc/pki/influxdb.crt
    - ca_server: {{ ca_server }}
    - signing_policy: influxdb
    - public_key: /etc/pki/influxdb.key
    - CN: {{ HOSTNAME }}
    - subjectAltName: DNS:{{ HOSTNAME }}, IP:{{ MAINIP }} 
    - days_remaining: 0
    - days_valid: 820
    - backup: True
{% if grains.role not in ['so-heavynode'] %}
    - unless:
      # https://github.com/saltstack/salt/issues/52167
      # Will trigger 5 days (432000 sec) from cert expiration
      - 'enddate=$(date -d "$(openssl x509 -in /etc/pki/influxdb.crt -enddate -noout | cut -d= -f2)" +%s) ; now=$(date +%s) ; expire_date=$(( now + 432000)); [ $enddate -gt $expire_date ]'
{% endif %}
    - timeout: 30
    - retry:
        attempts: 5
        interval: 30

influxdb_key_perms:
  file.managed:
    - replace: False
    - name: /etc/pki/influxdb.key
    - mode: 640
    - group: 939
