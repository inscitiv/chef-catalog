case node[:platform]
when "ubuntu","debian"
  include_recipe "conjur-pam-ldap:ubuntu"
when "centos","redhat","fedora"
  include_recipe "conjur-pam-ldap:centosr"
else
  raise "No recipe for platform #{node[:platform]}"
end
