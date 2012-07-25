class Chef
	class Recipe
		def self.included(base)
			puts "inscitiv_credentials included by #{base}"
		end
		
		def inscitiv_env
			if node[:inscitiv] && env = node[:inscitiv][:environment]
				env
			else
				"production"
			end
		end

		def inscitiv_server_hostname
			if node[:inscitiv] && hostname = node[:inscitiv][:server_hostname]
				hostname
			else
				raise "No inscitiv.hostname configured for this node"
			end
		end

		def inscitiv_project
			if node[:inscitiv] && project = node[:inscitiv][:project]
				project
			else
				raise "No inscitiv.project configured for this node"
			end
		end
	end
end