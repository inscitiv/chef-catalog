maintainer        "Inscitiv, Inc."
maintainer_email  "ops@inscitiv.com"
license           "Apache 2.0"
description       "Installs and configures RStudio Server"
version           "0.1.0"

%w{ ubuntu debian }.each do |os|
  supports os
end

depends "nginx"

attribute "server_alias",
  :display_name => "server alias",
  :description => "Additional hostname alias to apply to the server",
  :type => "string",
  :required => "optional"
