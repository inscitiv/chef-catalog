require File.dirname(__FILE__) + '/../spec_helper'

require 'libraries/sudoers'

describe "conjur-sudoers" do
#  let(:log_level) { :debug }
  let(:json_attributes) { 
    $ohai.data.merge(conjur_attributes).tap do |attrs|
      attrs[:inscitiv][:admin_groups] = [ "Manager" ]
    end
  }
  let(:ldap) { mock(:ldap) }
  let(:entry1) { mock(:entry1, :dn => "cn=Manager") }
  let(:entry2) { mock(:entry2, :dn => "cn=Contributor") }
  before(:each) do
    require 'ldap'
    LDAP::Conn.should_receive(:new).with("ldap.inscitiv.net", 1389).and_return ldap
    ldap.should_receive(:bind)
    ldap.should_receive(:search).and_yield(entry1).and_yield(entry2)
  end
  before(:each) do
    # Tame build-essential
    provider = mock(:provider).as_null_object
    Chef::Provider::Execute.stub(:new).and_return provider
    Chef::Provider::Package.stub(:new).and_return provider
  end
  context "parseable sudoers" do
    before(:each) do
      Conjur::Sudoers.should_receive(:parseable?).and_return true
    end
    it { should contain_chef_gem("ruby-augeas") }
    it do
      should RSpec::Chef::Matchers::ContainResource.new("contain_conjur-sudoers_poke", "sudoers").
        with(:exclude_groups, [ "Contributor" ]).
        with(:include_groups, [ "Manager" ]).
        with(:owner, "kgilpin") 
    end
  end
  context "non-parseable sudoers" do
    before(:each) do
      Conjur::Sudoers.should_receive(:parseable?).and_return false
    end
    it { should contain_chef_gem("ruby-augeas") }
    it do
      should contain_template("/etc/sudoers").
        with(:variables, :sudo_groups => [ "Manager" ], :owner => "kgilpin") 
    end
  end
end
