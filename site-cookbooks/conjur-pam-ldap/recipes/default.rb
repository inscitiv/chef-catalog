package "libaugeas-dev"
package "augeas-tools"

# Answer the installer questions about LDAP server location, root name, etc
template "/tmp/ldap.seed" do
	source "ldap.seed.erb"
end

# Answer the installer questions about LDAP server location, root name, etc
template "/usr/share/pam-configs/my_mkhomedir" do
	source "my_mkhomedir.erb"
end

execute "debconf-set-selections /tmp/ldap.seed"

for pkg in %w(debconf nss-updatedb nscd libpam-mkhomedir auth-client-config ldap-utils ldap-client libpam-ldapd libnss-ldapd)
	package pkg do
		options "-qq"
	end
end

for s in %w(nscd nslcd ssh)
	service s do
		supports :restart => true
	end
end

cookbook_file "/tmp/augtool_enable_password_authentication"
execute "allow PasswordAuthentication" do
	command "cat /tmp/augtool_enable_password_authentication | augtool"
	notifies :restart, "service[ssh]"
end

ldap_config = conjur_ldap_config

template "/etc/nslcd.conf" do
	source "nslcd.conf.erb"
	variables :hostname => ldap_config.hostname, :project => ldap_config.project, :root_bind_password => ldap_config.root_bind_password, :uri => ldap_config.uri.to_s
	notifies :restart, [ "service[nscd]", "service[nslcd]" ]
end

execute "pam-auth-update" do
	command "pam-auth-update --package"
	notifies :restart, [ "service[nscd]", "service[nslcd]" ]
end
