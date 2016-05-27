{% import "makina-states/services/http/nginx/init.sls" as nginx %}
{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}

{% if data.get('use_http_proxy', False) %}
include:
  - makina-states.services.http.nginx

echo restart:
  cmd.run:
    - watch_in:
      - mc_proxy: nginx-pre-restart-hook

{{ nginx.virtualhost(domain=data.domain,
                     cfg=cfg,
                     vhost_basename="corpus-{0}".format(cfg.name),
                     loglevel=data.get('nginx_loglevel', 'crit'),
                     vh_top_source=data.nginx_upstream,
                     vh_content_source=data.nginx_vhost) }}
{% else %}
skipped:
  mc_proxy.hook: []
{% endif %}
