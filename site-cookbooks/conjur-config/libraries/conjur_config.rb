module Inscitiv
	module Config
    LDAPConfig = Struct.new(:hostname, :project, :root_bind_password, :uri)
    EventConfig = Struct.new(:queue, :access_key_id, :secret_access_key)

		def conjur_env
			if env = node.inscitiv['environment']
				env
			else
				"production"
			end
		end
		
		def conjur_server_event_config
		  EventConfig.new(node.inscitiv.aws_users.server_events['queue_url'], node.inscitiv.aws_users.server_events['access_key_id'], node.inscitiv.aws_users.server_events['secret_access_key'])
		end
    
		def conjur_owner
		  node.inscitiv['owner']
		end
		
		def conjur_admin_groups
		  node.inscitiv['admin_groups'] || []
		end
		
		def conjur_ldap_config
		  uri = node.inscitiv.ldap['uri'] ||
        case conjur_env
        when 'development'
          # An SSH tunnel back to your local machine will be required to make this work
          "ldap://localhost:1389"
        when 'stage'
          "ldap://ldap.dev.inscitiv.com:1389"
        else
          "ldap://ldap.inscitiv.net:1389"
        end
      root_bind_password = node.inscitiv.ldap.root_bind_password
      project = conjur_project
      hostname, port = conjur_workspace_hostname.split(":")
      
      host_string = hostname.split(".").collect{|dc| "dc=#{dc}"}
      if port
        host_string << "port=#{port}"
      end
      
      hostname = host_string.join(",")
      
      require 'uri'
      return LDAPConfig.new(hostname, project, root_bind_password, URI.parse(uri))
		end

		def conjur_workspace_hostname
			if hostname = node.inscitiv['workspace_hostname']
				hostname
			else
				raise "No Conjur workspace_hostname configured for this node"
			end
		end

		def conjur_project
			if project = node.inscitiv['project']
				project
			else
				raise "No Conjur project configured for this node"
			end
		end
	end
end

class Chef::Recipe
  include Inscitiv::Config
end
