{% import "makina-states/services/monitoring/circus/macros.jinja" as circus  with context %}
{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}
include:
  - makina-states.services.monitoring.circus

echo restart:
  cmd.run:
    - watch_in:
      - mc_proxy: circus-pre-restart

{% set circus_data = {
     'cmd': data.start_cmd.format(*data.start_args),
     'uid': cfg.user,
     'environment': data.start_es_env,
     'gid': cfg.group,
     'copy_env': True,
     'working_dir': data.prefix,
     'warmup_delay': "30",
     'max_age': 24*60*60} %}
{{ circus.circusAddWatcher(cfg.name, **circus_data) }}
