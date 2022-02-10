influxdb_key:
  file.absent:
    - name: /etc/pki/influxdb.key

influxdb_crt:
  file.absent:
    - name: /etc/pki/influxdb.crt
