package "libaugeas-dev"
package "augeas-tools"

root_bind_password = node.inscitiv.ldap.root_bind_password
project = inscitiv_project
hostname, port = inscitiv_server_hostname.split(":")

host_string = hostname.split(".").collect{|dc| "dc=#{dc}"}
if port
	host_string << "port=#{port}"
end

def default_ldap_uri
	if node.inscitiv.environment == "development"
		# An SSH tunnel back to your local machine will be required to make this work
		"ldap://localhost:1389"
	elsif node.inscitiv.environment == "stage"
		"ldap://ldap.dev.inscitiv.com:1389"
	else
		"ldap://ldap.inscitiv.net:1389"
	end
end

ldap_uri = node.inscitiv.ldap['uri'] || default_ldap_uri

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

template "/etc/nslcd.conf" do
	source "nslcd.conf.erb"
	variables :hostname => host_string.join(","), :project => project, :root_bind_password => root_bind_password, :ldap_uri => ldap_uri
	notifies :restart, [ "service[nscd]", "service[nslcd]" ]
end

execute "pam-auth-update" do
	command "pam-auth-update --package"
	notifies :restart, [ "service[nscd]", "service[nslcd]" ]
end
