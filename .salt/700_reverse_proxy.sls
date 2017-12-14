{% import "makina-states/services/http/nginx/init.sls" as nginx %}
{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}

{% if data.get('use_http_proxy', False) %}
include:
  - makina-states.services.http.nginx

{% if data.get('http_proxy_passthrough', False) %}
{% set nginx_top = data.nginx_proxy_upstream %}
{% set nginx_vhost = data.nginx_proxy_vhost %}
{% else %}
{% set nginx_top = data.nginx_fw_upstream %}
{% set nginx_vhost = data.nginx_fw_vhost %}
{% endif %}
{{ nginx.virtualhost(domain=data.domain,
                     server_aliases=data.server_aliases,
                     redirect_aliases=data.get('redirect_aliases', False),
                     cfg=cfg,
                     force_reload=True,
                     vhost_basename="corpus-{0}".format(cfg.name),
                     loglevel=data.get('nginx_loglevel', 'crit'),
                     vh_top_source=nginx_top,
                     vh_content_source=nginx_vhost) }}
{% else %}
skipped:
  mc_proxy.hook: []
{% endif %}
