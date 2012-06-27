maintainer        "Inscitiv, Inc."
maintainer_email  "ops@inscitiv.com"
license           "Apache 2.0"
description       "Installs and configures postgresql server"
version           "0.1.0"

%w{ ubuntu debian fedora suse }.each do |os|
  supports os
end

%w{redhat centos scientific}.each do |el|
  supports el, ">= 6.0"
end

depends "postgresql", "= 0.99.4"

attribute "postgresql/password/postgres",
  :display_name => "postgres user password",
  :type => "string",
  :required => "required"
  
attribute "postgresql/version",
  :display_name => "postgresql database version",
  :type => "string",
  :required => "optional"
  
