server_event_config = conjur_server_event_config

case node[:platform]
when "ubuntu","debian"
  %w(libxml2-dev libxslt-dev)
when "centos","redhat","fedora"
  %w(libxml2-devel libxslt-devel)
else
  raise "Unable to install libxml2 and libxslt packages for platform #{node[:platform]}"
end.each do |p|
  package p do
  end.run_action(:install)
end

chef_gem 'aws-sdk'

service "rsyslog" do
  action :nothing
end

directory "/opt/inscitiv/bin" do
  recursive true
end

template "/opt/inscitiv/bin/authevent" do
  source "authevent.erb"
  mode "0500"
  owner "syslog"
  group "adm"
  variables :queue => server_event_config.queue, :access_key => server_event_config.identity_id, :secret_key => server_event_config.identity_secret
end

cookbook_file "/etc/rsyslog.d/75-authevent.conf" do
  source "authevent.conf"
  notifies :restart, resources(:service => "rsyslog")
end
