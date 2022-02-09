update_telegraf:
  salt.state:
    - tgt: 'not (G@role:so-manager or G@role:so-managersearch or G@role:so-standalone or G@role:so-eval or G@role:so-import)'
    - tgt_type: compound
    - sls:
      - telegraf
