supervisor-logs:
  @ssh root@homeassistant.lan -C "ha supervisor logs --follow --lines 20"
