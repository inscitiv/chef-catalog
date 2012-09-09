maintainer        "Inscitiv, Inc."
maintainer_email  "ops@inscitiv.com"
license           "Apache 2.0"
description       "Installs the Unity shell interface"
version           "0.1.0"

%w{ ubuntu debian }.each do |os|
  supports os
end
