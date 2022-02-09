include:
  - ssl.intca

remove_telegraf_key:
  file.absent:
    - name: /etc/pki/telegraf.key
    - onchanges:
      - x509: intca

remove_telegraf_crt:
  file.absent:
    - name: /etc/pki/telegraf.crt
    - onchanges:
      - x509: intca
