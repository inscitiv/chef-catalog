require File.dirname(__FILE__) + '/../spec_helper'

require 'libraries/sudoers'

describe "conjur-audit-shipper" do
  let(:json_attributes) { 
    $ohai.data.merge(conjur_attributes).tap do |attrs|
    end
  }
  let(:attrs) { conjur_attributes[:inscitiv][:aws_users][:server_events] }
  before(:each) do
    # Tame package installations
    provider = mock(:provider).as_null_object
    Chef::Provider::Package.stub(:new).and_return provider
  end
  it { should contain_chef_gem('aws-sdk') }
  it { 
    should contain_template("/opt/inscitiv/bin/authevent").
      with(:mode, "0500").
      with(:owner, 'syslog').
      with(:variables, :queue => attrs[:queue_url], :access_key => attrs[:access_key_id], :secret_key => attrs[:secret_access_key])
  }
  it { should contain_cookbook_file("/etc/rsyslog.d/75-authevent.conf") }
end