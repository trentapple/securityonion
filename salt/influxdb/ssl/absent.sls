remove_influxdb_key:
  file.absent:
    - name: /etc/pki/influxdb.key

remove_influxdb_crt:
  file.absent:
    - name: /etc/pki/influxdb.crt
