require File.dirname(__FILE__) + '/../spec_helper'

require 'chef/node'
require 'libraries/inscitiv_config'
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
    let(:attributes) { inscitiv_attributes }
    subject { recipe }
    its(:inscitiv_project) { should == "test" }
    its(:inscitiv_admin_groups) { should == [] }
    context "ldap" do
      subject { recipe.inscitiv_ldap_config }
      its("uri") { should == URI.parse("ldap://ldap.inscitiv.net:1389") }
      its("project") { should == recipe.inscitiv_project }
      its("root_bind_password") { should == "secret" }
      its("hostname") { should == "dc=localhost,dc=localdomain" }
    end
    context "default values" do
      its(:inscitiv_env) { should == "production" }
    end
  end
end