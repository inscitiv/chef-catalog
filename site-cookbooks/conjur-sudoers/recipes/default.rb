include_recipe "build-essential"

for p in %w(pkg-config libaugeas-dev libldap2-dev libsasl2-dev)
  package p do
  end.run_action(:install)
end

chef_gem 'ruby-augeas'
chef_gem 'ruby-ldap'

# This recipe will only manage Conjur system groups
# Other groups that may be added to sudoers on the machine will
# be left alone.

conjur_groups = []

ldap_config = conjur_ldap_config

require 'ldap'
conn = LDAP::Conn.new(ldap_config.uri.host, ldap_config.uri.port)
conn.bind("prj=#{ldap_config.project},#{ldap_config.hostname},o=root", ldap_config.root_bind_password)
conn.search("prj=#{ldap_config.project},#{ldap_config.hostname},o=members", LDAP::LDAP_SCOPE_SUBTREE, '(objectclass=group)') do |entry|
  group = entry.dn.split(", ")[0].split("=")[1]
  conjur_groups << group
end

conjur_sudo_groups = conjur_admin_groups
conjur_groups -= conjur_sudo_groups
owner = conjur_owner

if Conjur::Sudoers.parseable?
  conjur_sudoers_poke "sudoers" do
    include_groups conjur_sudo_groups
    exclude_groups conjur_groups
    owner owner
  end
else
  Chef::Log.warn "Unable to parse /etc/sudoers. Installing new /etc/sudoers"
  template "/etc/sudoers" do
    source "sudoers.erb"
    mode "0440"
    variables :sudo_groups => conjur_sudo_groups, :owner => owner
  end
end

