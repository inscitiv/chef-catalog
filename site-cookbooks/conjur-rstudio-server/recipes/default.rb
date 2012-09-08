package "r-base"
include_recipe "nginx"

# http://rstudio.org/download/server

version = node.rstudio_server.version

case node.platform
when "ubuntu","debian"
  %w(libssl0.9.8 libapparmor1 apparmor-utils).each do |pkg|
    package pkg do
      action :install
    end
  end
end

arch = node.kernel.machine =~ /x86_64/ ? 64 : 32
package = case arch
when 64
  "amd64"
else
  "i386"
end

service "rstudio-server" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true
  action :nothing
end

dpkg_package "rstudio-server" do
  source "/tmp/rstudio-server-#{version}.deb"
  action :nothing
end

remote_file "/tmp/rstudio-server-#{version}.deb" do
  source "http://download2.rstudio.org/rstudio-server-#{version}-#{package}.deb"
  action :create_if_missing
  notifies :install, resources(:dpkg_package => 'rstudio-server')
end

directory "/etc/rstudio"

cookbook_file "/etc/rstudio/rserver.conf" do
  source "rserver.conf"
  notifies :restart, resources(:service => 'rstudio-server')
end

template "#{node[:nginx][:dir]}/sites-available/rstudio-server" do
  source "rstudio-server-site.erb"
  owner "root"
  group "root"
  mode 0644
end

nginx_site "default" do
  enable false
end

nginx_site "rstudio-server" do
  enable true
end
