package "r-base"

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

dpkg_package "rstudio-server" do
  source "/tmp/rstudio-server-#{version}.deb"
  action :nothing
end

remote_file "/tmp/rstudio-server-#{version}.deb" do
  source "http://download2.rstudio.org/rstudio-server-#{version}-#{package}.deb"
  action :create_if_missing
  notifies :install, resources(:dpkg_package => 'rstudio-server')
end

