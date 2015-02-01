{% import "makina-states/services/http/nginx/init.sls" as nginx %}
{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}
include:
  - makina-states.services.http.nginx

echo restart:
  cmd.run:
    - watch_in:
      - mc_proxy: nginx-pre-restart-hook

{{ nginx.virtualhost(domain=data.domain,
                     cfg=cfg,
                     loglevel=data.get('nginx_loglevel', 'crit'),
                     vh_top_source=data.nginx_upstream,
                     vh_content_source=data.nginx_vhost) }}
