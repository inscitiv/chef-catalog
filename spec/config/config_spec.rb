require File.dirname(__FILE__) + '/../spec_helper'

require 'chef/node'
require 'libraries/conjur_config'
require 'uri'

PseudoRecipe = Struct.new(:node) do
  include Inscitiv::Config
end

describe Inscitiv::Config do
  let(:chef_node) {
    Chef::Node.new.tap do |node|
      node.consume_attributes attributes
    end
  }
  let(:recipe) { PseudoRecipe::new(chef_node) }
  context "with some standard attributes" do
    let(:attributes) { conjur_attributes }
    subject { recipe }
    its(:conjur_project) { should == "test" }
    its(:conjur_admin_groups) { should == [] }
    context "ldap" do
      subject { recipe.conjur_ldap_config }
      its("uri") { should == URI.parse("ldap://ldap.inscitiv.net:1389") }
      its("project") { should == recipe.conjur_project }
      its("root_bind_password") { should == "secret" }
      its("hostname") { should == "dc=localhost,dc=localdomain" }
    end
    context "server_event" do
      subject { recipe.conjur_server_event_config }
      let(:attrs) { conjur_attributes[:inscitiv][:aws_users][:server_events] }
      its("queue") { should == attrs[:queue_url] }
      its("access_key_id") { should == attrs[:access_key_id] }
      its("secret_access_key") { should == attrs[:secret_access_key] }
    end
    context "default values" do
      its(:conjur_env) { should == "production" }
    end
  end
end