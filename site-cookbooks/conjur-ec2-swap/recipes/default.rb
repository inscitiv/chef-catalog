if node[:ec2]
  # Create a swap file equal to 50% of system memory
  swap_file = '/var/swap.1'
  total_memory = node.memory.total
  swap_mb = if total_memory =~ /(.*)mb/i
    $1.to_i / 2
  elsif total_memory =~ /(.*)kb/i
    $1.to_i / 1000 / 2
  else
    raise "Cannot parse #{total_memory} into MB"
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
