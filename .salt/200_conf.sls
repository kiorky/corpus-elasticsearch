{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}
{% for cfgn, cfgdata in data.configs.items() %}
{% set cfgn = salt['mc_utils.format_resolve'](cfgn, data) %}
{% set cfgdata = salt['mc_utils.format_resolve'](cfgdata, data) %}
"{{cfgn}}-{{cfg.name}}":
  file.managed:
    - name: "{{cfgn}}"
    - source: "{{cfgdata.template}}"
    - makedirs: true
    - template: jinja
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - mode: "{{cfgdata.get('mode', '0770')}}"
    - context:
        project: "{{cfg.name}}"
{% endfor %}
