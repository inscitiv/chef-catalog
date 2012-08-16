require File.dirname(__FILE__) + '/../spec_helper'

require 'libraries/sudoers'

shared_examples_for "with sample input" do
  before(:all) do
    require 'fileutils'
    outdir = etc_dir
    FileUtils.mkdir_p outdir
    FileUtils.cp File.expand_path(sudoers_file, File.dirname(__FILE__)), File.expand_path('sudoers', outdir)
  end
end

shared_examples_for "synced" do
  before(:all) do
    Conjur::Sudoers.sync [ 'admin' ], [ 'Developers' ], 'kgilpin', File.expand_path('..', etc_dir)
  end
  let(:file_body) { File.read(File.expand_path('sudoers', etc_dir)) }
  it "should not contain %admin" do
    file_body.should_not include("%admin")
  end
  it "should contain %Developers" do
    file_body.should include("%Developers")
  end
  it "should contain %kgilpin" do
    file_body.should match(/\bkgilpin\b/)
  end
end

describe Conjur::Sudoers do
  let(:etc_dir) { File.expand_path('../data/tmp/etc', File.dirname(__FILE__)) }
  
  # Create some sample sudoers files and manipulate them
  context "empty sudoers" do
    let(:sudoers_file) { "empty" }
    
    it_should_behave_like "with sample input" do
      it "the file should exist" do
        File.exists?(File.expand_path('../data/tmp/etc/sudoers', File.dirname(__FILE__))).should be_true
      end
      it_should_behave_like "synced"
    end
  end
  
  context "typical sudoers" do
    let(:sudoers_file) { "typical" }
    
    it_should_behave_like "with sample input" do
      it_should_behave_like "synced"
    end
  end
end
