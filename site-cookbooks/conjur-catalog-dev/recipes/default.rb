user = (node['cookbook-dev']||{})['user'] || node.inscitiv.owner
group_line = `getent group | grep '\b#{user}\b'`
raise "Can't find group for user #{user}" unless group_line
group = group_line.split(':')[0]

solo_rb = File.read('/etc/inscitiv/chef/solo.rb').split("\n").collect{|l| l =~ /([^\s]+)\s+(.*)/; [ $1, $2 ]}.reduce({}){|memo,v| memo[v[0]] = v[1]; memo}

require 'json'
cookbook_path = JSON.parse(solo_rb['cookbook_path'])
cookbook_entry = "/home/#{user}/chef-catalog/site-cookbooks"

ruby_block "add #{user} chef-catalog to cookbook path" do
  block do
cookbook_path.insert 0, cookbook_entry
solo_rb['cookbook_path'] = cookbook_path.to_json
solo_rb = solo_rb.reduce([]) do |memo,line|
  memo << [ line[0], line[1] ].join("\t")
end.join("\n")
File.write('/etc/inscitiv/chef/solo.rb', solo_rb)
  end
  not_if { cookbook_path.member?(cookbook_entry) }
end

execute "copy chef-catalog" do
  command <<-CMD
cp -r /var/lib/inscitiv/chef-catalog /home/#{user}
chown -R #{user}.#{group} /home/#{user}/chef-catalog
  CMD

  creates "/home/#{user}/chef-catalog"
end
