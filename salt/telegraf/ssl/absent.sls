remove_telegraf_key:
  file.absent:
    - name: /etc/pki/telegraf.key

remove_telegraf_crt:
  file.absent:
    - name: /etc/pki/telegraf.crt
