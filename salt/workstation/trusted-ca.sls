   
{# we only want this state to run it is CentOS #}
{% if grains.os == 'CentOS' %}

  {% set COMMONNAME = grains.master %}
  {% set HOSTNAME = salt['grains.get']('host') %}
  {% set MAININT = salt['pillar.get']('host:mainint') %}
  {% set MAINIP = salt['grains.get']('ip_interfaces').get(MAININT)[0] %}

  {% set global_ca_text = [] %}
  {% set global_ca_server = [] %}
  {% set manager = salt['grains.get']('master') %}
  {% set x509dict = salt['mine.get'](manager | lower~'*', 'x509.get_pem_entries') %}
    {% for host in x509dict %}
      {% if host.split('_')|last in ['manager', 'managersearch', 'standalone', 'import', 'eval'] %}
        {% do global_ca_text.append(x509dict[host].get('/etc/pki/ca.crt')|replace('\n', '')) %}
        {% do global_ca_server.append(host) %}
      {% endif %}
    {% endfor %}
  {% set trusttheca_text = global_ca_text[0] %}
  {% set ca_server = global_ca_server[0] %}

trusted_ca:
  x509.pem_managed:
    - name: /etc/pki/ca-trust/source/anchors/ca.crt
    - text:  {{ trusttheca_text }}

update_ca_certs:
  cmd.run:
    - name: update-ca-trust
    - onchanges:
      - x509: trusted_ca

strelka_cert_directory:
  file.directory:
    - name: /opt/so/conf/strelka/etc/pki
    - makedirs: True

strelka_key:
  x509.private_key_managed:
    - name: /opt/so/conf/strelka/etc/pki/strelka.key
    - CN: {{ COMMONNAME }}
    - bits: 4096
    - days_remaining: 0
    - days_valid: 820
    - backup: True
    - new: True
    {% if salt['file.file_exists']('/opt/so/conf/strelka/etc/pki/strelka.key') -%}
    - prereq:
      - x509: strelka_crt
    {%- endif %}
    - timeout: 30
    - retry:
        attempts: 5
        interval: 30

# Request a cert and drop it where it needs to go to be distributed
strelka_crt:
  x509.certificate_managed:
    - name: /opt/so/conf/strelka/etc/pki/strelka.crt
    - ca_server: {{ ca_server }}
    - signing_policy: managerssl
    - public_key: /opt/so/conf/strelka/etc/pki/strelka.key
    - CN: {{ HOSTNAME }}
    - subjectAltName: DNS:{{ HOSTNAME }}, IP:{{ MAINIP }}
    - days_remaining: 0
    - days_valid: 820
    - backup: True
    - unless:
      # https://github.com/saltstack/salt/issues/52167
      # Will trigger 5 days (432000 sec) from cert expiration
      - 'enddate=$(date -d "$(openssl x509 -in /opt/so/conf/strelka/etc/pki/strelka.crt -enddate -noout | cut -d= -f2)" +%s) ; now=$(date +%s) ; expire_date=$(( now + 432000)); [ $enddate -gt $expire_date ]'
    - timeout: 30
    - retry:
        attempts: 5
        interval: 30

{% else %}

workstation_trusted-ca_os_fail:
  test.fail_without_changes:
    - comment: 'SO Analyst Workstation can only be installed on CentOS'

{% endif %}
