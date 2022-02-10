update_influxdb:
  salt.state:
    - tgt: 'P@role:(so-manager|so-managersearch|so-standalone|so-eval|so-import)'
    - tgt_type: compound
    - sls:
      - influxdb

update_telegraf:
  salt.state:
    - tgt: 'not P@role:(so-manager|so-managersearch|so-standalone|so-eval|so-import)'
    - tgt_type: compound
    - sls:
      - telegraf
