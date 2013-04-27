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
    expect(Pathname.new("#{project}/shared/lvm")).to be_directory
  end

  it "should have openstack module" do
    expect(Pathname.new("#{project}/shared/openstack")).to be_directory
  end

  it "should have ssh module" do
    expect(Pathname.new("#{project}/shared/ssh")).to be_directory
  end

  it "should have stdlib module" do
    expect(Pathname.new("#{project}/shared/stdlib")).to be_directory
  end

  it "should have boxen module" do
    pending "github_tarball support"
    expect(Pathname.new("#{project}/shared/boxen")).to be_directory
  end
end
