{% import "makina-states/services/http/nginx/init.sls" as nginx %}
{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}
include:
  - makina-states.services.backup.dbsmartbackup
# override retention policy not to conflict with mastersalt
{% set cfg = opts.ms_project %}
{% set settings = salt['mc_dbsmartbackup.settings']() %}
{% set data = cfg.data %}
{% for i in settings.types %}
/etc/dbsmartbackup/{{i}}.conf.local:
  file.managed:
    - contents: |
                KEEP_LASTS="{{data.keep_lasts}}"
                KEEP_DAYS="{{data.keep_days}}"
                KEEP_WEEKS="{{data.keep_weeks}}"
                KEEP_MONTHES="{{data.keep_monthes}}"
                KEEP_LOGS="{{data.keep_logs}}"
    - mode: 644
    - user: root
    - group: root
{% endfor %}
