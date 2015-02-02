{% import "makina-states/services/http/nginx/init.sls" as nginx %}
{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}
# override retention policy not to conflict with mastersalt
{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% for plugin in data.plugins %}
{% for i, d in plugin.items() %}
install-{{i}}-plugin:
  cmd.run:
    - name: bin/plugin -install "{{i}}"
    - user: {{cfg.user}}
    - cwd: {{data.prefix}}
    - onlyif: test ! -e "{{data.prefix}}/plugins/{{d}}"
    - use_vt: true
{% endfor %}
{% endfor %}
