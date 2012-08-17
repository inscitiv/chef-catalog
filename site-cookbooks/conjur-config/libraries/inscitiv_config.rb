module Inscitiv
	module Config
    LDAPConfig = Struct.new(:hostname, :project, :root_bind_password, :uri)

		def inscitiv_env
			if env = node.inscitiv[:environment]
				env
			else
				"production"
			end
		end
		
		def inscitiv_owner
		  node.inscitiv[:owner]
		end
		
		def inscitiv_admin_groups
		  node.inscitiv[:admin_groups] || []
		end
		
		def inscitiv_ldap_config
		  uri = node.inscitiv.ldap['uri'] ||
        case inscitiv_env
        when 'development'
          # An SSH tunnel back to your local machine will be required to make this work
          "ldap://localhost:1389"
        when 'stage'
          "ldap://ldap.dev.inscitiv.com:1389"
        else
          "ldap://ldap.inscitiv.net:1389"
        end
      root_bind_password = node.inscitiv.ldap.root_bind_password
      project = inscitiv_project
      hostname, port = inscitiv_server_hostname.split(":")
      
      host_string = hostname.split(".").collect{|dc| "dc=#{dc}"}
      if port
        host_string << "port=#{port}"
      end
      
      hostname = host_string.join(",")
      
      require 'uri'
      return LDAPConfig.new(hostname, project, root_bind_password, URI.parse(uri))
		end

		def inscitiv_server_hostname
			if hostname = node.inscitiv[:server_hostname]
				hostname
			else
				raise "No inscitiv.hostname configured for this node"
			end
		end

		def inscitiv_project
			if project = node.inscitiv[:project]
				project
			else
				raise "No inscitiv.project configured for this node"
			end
		end
	end
end

class Chef::Recipe
  include Inscitiv::Config
end
