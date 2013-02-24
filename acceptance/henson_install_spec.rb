require 'acceptance_spec_helper'

describe 'henson install' do
  let(:project) do
    File.expand_path('../fixtures', __FILE__)
  end

  before(:all) do
    Dir.chdir(project) do
      system 'bundle', 'exec', File.expand_path('../../bin/henson'), 'install'
    end
  end

  after(:all) do
    FileUtils.rm_rf "#{project}/shared"
  end

  it "should have lvm module" do
    File.directory?("#{project}/shared/lvm").should be_true
  end

  it "should have openstack module" do
    File.directory?("#{project}/shared/openstack").should be_true
  end

  it "should have ssh module" do
    File.directory?("#{project}/shared/ssh").should be_true
  end

  it "should have stdlib module" do
    File.directory?("#{project}/shared/stdlib").should be_true
  end

  it "should have boxen module" do
    pending "github_tarball suppot"
    File.directory?("#{project}/shared/boxen").should be_true
  end
end
