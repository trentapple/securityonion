remove_telegraf_key:
  file.absent:
    - name: /etc/pki/telegraf.key

# Create a cert for the talking to telegraf
remove_telegraf_crt:
  file.absent:
    - name: /etc/pki/telegraf.crt
