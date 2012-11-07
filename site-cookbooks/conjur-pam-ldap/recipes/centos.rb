package "augeas"


for pkg in %w(nscd openldap openldap-clients nss-pam-ldapd authconfig)
	package pkg do
		options "-y"
	end
end

for s in %w(nscd nslcd sshd)
	service s do
		supports :restart => true
	end
end

cookbook_file "/tmp/augtool_enable_password_authentication"
execute "allow PasswordAuthentication" do
	command "cat /tmp/augtool_enable_password_authentication | augtool"
	notifies :restart, "service[sshd]"
end

ldap_config = conjur_ldap_config

template "/etc/nslcd.conf" do
	source "nslcd.conf.erb"
	variables :hostname => ldap_config.hostname, :project => ldap_config.project, :root_bind_password => ldap_config.root_bind_password, :uri => ldap_config.uri.to_s
	notifies :restart, [ "service[nscd]", "service[nslcd]" ]
end

template "/etc/pam_ldap.conf" do
	source "pam_ldap.conf.erb"
	variables :hostname => ldap_config.hostname, :project => ldap_config.project, :root_bind_password => ldap_config.root_bind_password, :uri => ldap_config.uri.to_s
end

#execute "authconfig" do
#	command "authconfig --updateall"
#	notifies :restart, [ "service[nscd]", "service[nslcd]" ]
#end
