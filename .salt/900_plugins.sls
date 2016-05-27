{% import "makina-states/services/http/nginx/init.sls" as nginx %}
{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}
{% set selector = data.get('plugins_selector', data.version[0]|int) %}
{% set plugins = data.plugins.get(selector, {}) %}
{% for plugin in plugins %}
{% for i, d in plugin.items() %}
install-{{i}}-plugin:
{% if data.version[0] > '1' %}
  cmd.run:
    - name: bin/plugin install --batch "{{i}}"
    - user: {{cfg.user}}
    - cwd: {{data.prefix}}
    - onlyif: test ! -e "{{data.prefix}}/plugins/{{d}}"
    - use_vt: true
{% else %}
  cmd.run:
    - name: bin/plugin -install "{{i}}"
    - user: {{cfg.user}}
    - cwd: {{data.prefix}}
    - onlyif: test ! -e "{{data.prefix}}/plugins/{{d}}"
    - use_vt: true
{%endif%}
{% endfor %}
{% endfor %}
