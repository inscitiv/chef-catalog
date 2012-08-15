package "ruby"
package "libaugeas-ruby"

# This recipe will only manage Conjur system groups
# Other groups that may be added to sudoers on the machine will
# be left alone.

# TODO: determine this list with an LDAP search
conjur_groups =      node[:inscitiv][:groups] || []
conjur_sudo_groups = node[:inscitiv][:admin_groups] || []
conjur_groups -= conjur_sudo_groups

ruby_block "sync root users" do
  block do
Conjur::Sudoers.sync conjur_groups, conjur_sudo_groups
  end
end
