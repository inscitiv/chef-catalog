
server_event_config = conjur_server_event_config
template "/opt/inscitiv/bin/authevent" do
  source "authevent.erb"
  mode "0755"
  variables :queue => server_event_config[:queue], :access_key => server_event_config[:access_key_id], :secret_key => server_event_config[:secret_access_key]
end

cookbook_file "/etc/rsyslog.d/75-authevent.conf" do
  source "authevent.conf"
end
