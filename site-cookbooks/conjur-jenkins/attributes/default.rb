normal['jenkins']['http_proxy']['variant'] = 'apache2'
normal['java']['install_flavor'] = 'oracle'
normal['java']['oracle']['accept_oracle_download_terms'] = true

default['jenkins']['password'] = 'jenkins'
default['jenkins']['http_proxy']['basic_auth_password'] = node['jenkins']['password']
