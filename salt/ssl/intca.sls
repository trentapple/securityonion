{% set manager = salt['grains.get']('master') %}
{% set managerip = salt['pillar.get']('global:managerip', '') %}
{% set HOSTNAME = salt['grains.get']('host') %}
{% set global_ca_text = [] %}
{% set global_ca_server = [] %}
{% set MAININT = salt['pillar.get']('host:mainint') %}
{% set MAINIP = salt['grains.get']('ip_interfaces').get(MAININT)[0] %}
{% set CUSTOM_FLEET_HOSTNAME = salt['pillar.get']('global:fleet_custom_hostname', None) %}
{% if grains.role in ['so-heavynode'] %}
  {% set COMMONNAME = salt['grains.get']('host') %}
{% else %}
  {% set COMMONNAME = manager %}
{% endif %}

{% if grains.id.split('_')|last in ['manager', 'managersearch', 'eval', 'standalone', 'import', 'helixsensor'] %}
include:
  - ca
    {% set intca_text = salt['cp.get_file_str']('/etc/pki/ca.crt')|replace('\n', '') %}
    {% set ca_server = grains.id %}
{% else %}
include:
  - ca.dirs
    {% set x509dict = salt['mine.get'](manager | lower~'*', 'x509.get_pem_entries') %}
    {% for host in x509dict %}
      {% if 'manager' in host.split('_')|last or host.split('_')|last == 'standalone' %}
        {% do global_ca_text.append(x509dict[host].get('/etc/pki/ca.crt')|replace('\n', '')) %}
        {% do global_ca_server.append(host) %}
      {% endif %}
    {% endfor %}
    {% set intca_text = global_ca_text[0] %}
    {% set ca_server = global_ca_server[0] %}
{% endif %}

# Trust the CA
intca:
  x509.pem_managed:
    - name: /etc/ssl/certs/intca.crt
    - text:  {{ intca_text }}
    - onchanges_in:
      file: remove_telegraf_key
      file: remove_telegraf_crt
