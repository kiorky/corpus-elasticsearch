{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}
include:
  - makina-states.localsettings.jdk

{% set version = data.version %}
{% set fv = data.fv %}

{# Layout is as follow
data/es/elasticsearch-1.4.2: current elasticsearch release
data/es/data: persistant data & linked folders
data/es/root-{curver}:
    bin/      -> $data/es/elasticsearch-1.4.2/bin
    lib/      -> $data/es/elasticsearch-1.4.2/lib
    config/   -> $data/es/data/config-{curver}
    plugins/  -> $data/es/data/plugins
    data/     -> $data/es/data/data
    logs/     -> $data/es/data/logs
    tmp/      -> $data/es/data/tmp

#}

{{cfg.name}}-prerequisites:
  pkg.installed:
    - pkgs:
      - apache2-utils

{{cfg.name}}-{{ version }}:
  file.directory:
    - names:
      - {{ data.sroot }}
      - {{ data.prefix }}
      {% for i in data.bundle_data_sync%}
      - {{ data.sdata }}/{{i}}
      {% endfor %}
      {% for i in data.bundle_data_ver_sync%}
      - {{ data.sdata }}/{{i}}-{{fv}}
      {% endfor%}
    - makedirs: true
    - user: {{cfg.user}}
  cmd.run:
    - user: {{cfg.user}}
    - watch:
      - file: {{cfg.name}}-{{version}}
    - cwd: {{ data.sroot}}
    - onlyif: test ! -e '{{ data.sroot}}/{{cfg.name}}-{{ fv }}-download'
    - name: |
            set -e
            wget -c "{{data.es_url}}"
            tar xzf "{{data.es_tb}}"
            touch {{cfg.name}}-{{ fv }}-download

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

{% for i in data.bundle_data_sync %}
{{cfg.name}}-dist-top-config-{{i}}:
  file.symlink:
    - target: "{{data.sdata}}/{{i}}"
    - name: "{{data.prefix}}/{{i}}"
    - require:
      - cmd: "{{cfg.name}}-{{ version }}"
    - require_in:
      - mc_proxy: {{cfg.name}}-links
{% endfor %}

{% for i in data.bundle_data_ver_sync%}
{{cfg.name}}-dist-top-ver-config-{{i}}:
  file.symlink:
    - target: "{{data.sdata}}/{{i}}-{{fv}}"
    - name: "{{data.prefix}}/{{i}}"
    - require:
      - cmd: "{{cfg.name}}-{{ version }}"
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

{{cfg.name}}-cfg-link:
  file.symlink:
    - name: "/etc/elasticsearch/elasticsearch-{{cfg.name}}-{{data.fv}}"
    - target: "{{data.prefix}}/config"
    - makedirs: true
    - target: "{{data.prefix}}/logs"
    - require:
      - mc_proxy: "{{cfg.name}}-links"

{{cfg.name}}-su-wrapper:
  file.managed:
    - name: {{data.prefix}}/bin/elasticsearch_suwrapper
    - contents: |
                #!/usr/bin/env bash
                ulimit -l unlimited
                ulimit -n 65535
                exec su "{{cfg.user}}" -c "{{data.prefix}}/bin/elasticsearch_wrapper"
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - mode: 0750
    - require:
      - mc_proxy: "{{cfg.name}}-links"

{{cfg.name}}-bin-wrapper:
  file.managed:
    - name: {{data.prefix}}/bin/elasticsearch_wrapper
    - contents: |
                #!/usr/bin/env bash
                cd "$(dirname ${0})"
                {% for i, v in data.start_es_env.items() %}
                {{i}}={{v}}
                export {{i}}
                {% endfor %}
                exec {{data.start_cmd.format(*data.start_args)}}
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - mode: 0750
    - require:
      - mc_proxy: "{{cfg.name}}-links"

