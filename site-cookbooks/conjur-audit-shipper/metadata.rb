maintainer        "Inscitiv, Inc."
maintainer_email  "ops@inscitiv.com"
license           "Apache 2.0"
description       "Installs and configures the log shipper"
version           "0.1.0"

depends 'logstash'

%w{ ubuntu debian }.each do |os|
  supports os
end
