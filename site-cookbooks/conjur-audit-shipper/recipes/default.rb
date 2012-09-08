server_event_config = conjur_server_event_config

package 'libxml2-dev' do
end.run_action(:install)
package 'libxslt-dev' do
end.run_action(:install)

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
  variables :queue => server_event_config[:queue], :access_key => server_event_config[:access_key_id], :secret_key => server_event_config[:secret_access_key]
end

cookbook_file "/etc/rsyslog.d/75-authevent.conf" do
  source "authevent.conf"
  notifies :restart, resources(:service => "rsyslog")
end
