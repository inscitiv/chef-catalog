maintainer        "Inscitiv, Inc."
maintainer_email  "ops@inscitiv.com"
license           "Apache 2.0"
description       "Installs Jenkins with the apache2 proxy using Oracle Java"
version           "0.1.0"

%w{ ubuntu debian }.each do |os|
  supports os
end
