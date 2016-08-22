node.default['haproxy']['proxies'] = %w( HTTP servers-http http admin )
node.default['haproxy']['config'] = [
  'log 127.0.0.1 local0',
  'log 127.0.0.1 local1 notice',
  'user haproxy',
  'group haproxy'
]
node.default['haproxy']['tuning'] = [
  'maxconn 4096'
]

haproxy_defaults 'HTTP' do
  mode 'http'
  balance 'roundrobin'
  config [
    'log global',
    "retries #{node['testcbk']['config']['default']['retries']}",
    "timeout client #{node['testcbk']['config']['default']['timeout']['client']}",
    "timeout connect #{node['testcbk']['config']['default']['timeout']['connect']}",
    "timeout server #{node['testcbk']['config']['default']['timeout']['server']}",
    'option dontlognull',
    'option httplog',
    'option redispatch'
  ]
end

haproxy_backend 'servers-http' do
  servers node['testcbk']['proxies']
end

haproxy_frontend 'http' do
  mode 'http'
  bind '0.0.0.0:80'
  config [
    'maxconn 2000'
  ]
  default_backend 'servers-http'
end

haproxy_listen 'admin' do
  mode 'http'
  bind '127.0.0.1:22002'
  config [
    'stats uri /'
  ]
end

# *** Recipes ***
include_recipe 'haproxy-ng'

