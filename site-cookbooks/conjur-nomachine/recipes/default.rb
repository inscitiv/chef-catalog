version = node.nomachine.version

arch = case node.kernel.machine
when /x86_64/
  'amd64'
else
  'i386'
end

service "nxserver" do
  action :nothing
end
 
for p in %w(nxclient nxnode nxserver)
  build_number = node.nomachine[p]['build_number']
  file_name = "#{p}_#{version}-#{build_number}_#{arch}.deb"
  temp_file = "/tmp/#{file_name}"
  path = node.nomachine[p]['linux_path'] || 'Linux'

  dpkg_package p do
    source temp_file
    action :nothing
  end

  remote_file temp_file do
    source "http://64.34.173.142/download/#{version}/#{path}/#{file_name}"
    action :create_if_missing
    notifies :install, resources(:dpkg_package => p)
  end
end
