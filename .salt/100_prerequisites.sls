{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}
include:
  - makina-states.localsettings.jdk

{% set version = data.version %}
{% set fv = data.fv %}

{{cfg.name}}-{{ version }}:
  file.directory:
    - names:
      - {{ data.sroot }}
      - {{ data.prefix }}/config
      - {{ data.prefix }}/tmp
      - {{ data.prefix }}/logs
      - {{ data.prefix }}/data
      - {{ data.prefix }}/plugins
{% for core_data in data.indexes %}
{% for core_name, core_conf in core_data.items() %}
      - {{ data.sdata }}/{{core_name}}/conf
      - {{ data.sdata }}/{{core_name}}/data
{% endfor %}
{% endfor %}
    - makedirs: true
    - user: {{cfg.user}}
  cmd.run:
    - user: {{cfg.user}}
    - watch:
      - file: {{cfg.name}}-{{version}}
    - cwd: {{ data.sroot}}
    - onlyif: test ! -e '{{ data.sroot}}/{{cfg.name}}-{{ fv }}-download'
    - name: >
            wget -c "{{data.es_url}}" && tar xzf "{{data.es_tb}}" && touch {{cfg.name}}-{{ fv }}-download

{#

{% for i in data.bundle_sync %}
{{cfg.name}}-jetty-bundle-{{i}}:
  cmd.run:
    - require:
      - cmd: {{cfg.name}}-{{ version }}
    - name: |
            rsync -Aa \
              "{{ data.sroot}}/{{cfg.name}}-{{fv}}/example/{{i}}" \
               "{{data.jetty}}/{{i}}"
    - user: {{cfg.user}}
{% endfor %}

#}
{% for i in data.bundle_top_sync %}
{{cfg.name}}-dist-top-conf-{{i}}:
  file.symlink:
    - name: "{{data.prefix}}/{{i}}"
    - require:
      - cmd: "{{cfg.name}}-{{ version }}"
    - target: "{{ data.sroot}}/{{data.es_bn}}/{{i}}"
    - require_in:
      - mc_proxy: {{cfg.name}}-links
{% endfor %}


{{cfg.name}}-links:
  mc_proxy.hook: []


{{cfg.name}}-logs-link:
  file.symlink:
    - name: "/var/log/elasticsearch-{{cfg.name}}"
    - target: "{{data.prefix}}/logs"
    - require:
      - mc_proxy: "{{cfg.name}}-links"
