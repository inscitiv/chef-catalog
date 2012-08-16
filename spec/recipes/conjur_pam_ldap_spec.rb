require File.dirname(__FILE__) + '/../spec_helper'

require 'rspec-chef'

describe "conjur-pam-ldap::default", :type => :recipe do
#  let(:log_level) { :debug }
  let(:json_attributes) { 
    $ohai.data.merge(inscitiv_attributes).merge(
      :foo => :bar
    )
  }
  it { should contain_package("nss-updatedb") }
  it { should contain_template("/etc/nslcd.conf").with(:variables, { :project => "test", :root_bind_password => "secret", :hostname => "dc=localhost,dc=localdomain", :uri => "ldap://ldap.inscitiv.net:1389" }) }
end
