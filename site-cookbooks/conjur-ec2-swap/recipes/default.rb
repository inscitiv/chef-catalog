if node[:ec2]
  # TODO: determine swap size by looking at memory.total
  swap_file, swap_mb = if node.ec2.instance_type == "t1.micro"
    [ "/var/swap.1", 1000 ]
  else
    [ "/var/swap.1", 10000 ]
  end
  Chef::Log.info "Making #{swap_mb}mb swap file #{swap_file}"
  bash "Make swap space" do
    code <<-EOH
      sudo /bin/dd if=/dev/zero of=#{swap_file} bs=1M count=#{swap_mb}
      sudo /sbin/mkswap #{swap_file}
      sudo /sbin/swapon #{swap_file}
    EOH
    not_if { File.exists?("#{swap_file}") }
  end
end
