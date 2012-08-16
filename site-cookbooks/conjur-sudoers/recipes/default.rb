package 'pkg-config'
package 'libaugeas-dev'
chef_gem 'ruby-augeas'

package 'libldap2-dev'
package 'libsasl2-dev'
chef_gem 'ruby-ldap'

# This recipe will only manage Conjur system groups
# Other groups that may be added to sudoers on the machine will
# be left alone.

conjur_groups = []

ldap_config = inscitiv_ldap_config

conn = LDAP::Conn.new(host=ldap_config.uri.hostname, port=ldap_config.uri.port)
conn.bind("prj=#{ldap_config.project},#{ldap_config.hostname},o=root", ldap_config.root_bind_password)
conn.search("prj=#{ldap_config.project},#{ldap_config.hostname},o=members", LDAP::LDAP_SCOPE_SUBTREE, '(objectclass=group)') do |entry|
  group = entry.dn.split(", ")[0].split("=")[1]
  conjur_groups << group
end

conjur_sudo_groups = inscitiv_admin_groups
conjur_groups -= conjur_sudo_groups

if `augtool "match /augeas/files/etc/sudoers/error"`.match("/augeas/files/etc/sudoers/error") == 0
  ruby_block "sync root users" do
    block do
Conjur::Sudoers.sync conjur_groups, conjur_sudo_groups
    end
  end
else
  Chef::Log.warn "Unable to parse /etc/sudoers. Installing new /etc/sudoers"
  cookbook_file "/etc/sudoers" do
    source "sudoers"
    mode "0440"
  end
end

