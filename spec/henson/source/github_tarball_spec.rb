require 'spec_helper'

describe Henson::Source::GitHubTarball do
  subject(:it) { described_class.new('foo', '>= 0', 'bar/puppet-foo') }

  before(:each) do
    FakeWeb.clean_registry
  end

  it "can be instantiated" do
    expect(it).to_not be_nil
  end

  it "inherits Henson::Source::Generic" do
    expect(it).to be_a(Henson::Source::Generic)
  end

  describe "#name" do
    it "should return the name of the module" do
      expect(it.name).to eq('foo')
    end
  end

  describe "#repo" do
    it "should return the repository name for the module" do
      expect(it.repo).to eq('bar/puppet-foo')
    end
  end

  describe "#version" do
    it "should return the resolved version" do
      it.expects(:resolve_version_from_requirement).with('>= 0').once.returns('1.0.0')
      expect(it.version).to eq('1.0.0')
    end
  end

  describe "#fetched?" do
    it "should return true if the tarball exists on disk" do
      it.expects(:version).returns('1.0.0')
      it.send(:tarball_path).expects(:file?).returns(true)
      expect(it.fetched?).to be_true
    end

    it "should return false if the tarball doesn't exist on disk" do
      it.expects(:version).returns('1.0.0')
      it.send(:tarball_path).expects(:file?).returns(false)
      expect(it.fetched?).to be_false
    end
  end

  describe "#fetch!" do
    it "should download the tarball" do
      it.send(:cache_path).expects(:mkpath)
      it.expects(:clean_up_old_cached_versions)
      it.expects(:version).returns('1.0.0').twice
      it.expects(:download_file).with(
        'https://api.github.com/repos/bar/puppet-foo/tarball/1.0.0',
        it.send(:tarball_path).to_path)
      it.fetch!
    end

    it "should append ?access_token to the URL if GITHUB_API_TOKEN envvar set" do
      it.send(:cache_path).expects(:mkpath)
      it.expects(:clean_up_old_cached_versions)
      it.expects(:version).returns('1.0.0').twice
      it.expects(:download_file).with(
        'https://api.github.com/repos/bar/puppet-foo/tarball/1.0.0?access_token=foo',
        it.send(:tarball_path).to_path)
      ENV['GITHUB_API_TOKEN'] = 'foo'
      it.fetch!
      ENV.delete('GITHUB_API_TOKEN')
    end
  end

  describe "#installed?" do
    it "should always return false" do
      expect(it.installed?).to be_false
    end
  end

  describe "#install!" do
    it "should extract the tarball into the install path" do
      it.expects(:version).at_least_once.returns('1.0.0')
      it.send(:install_path).expects(:exist?).returns(true)
      it.send(:install_path).expects(:rmtree)
      it.send(:install_path).expects(:mkpath)
      it.expects(:extract_tarball).with(it.send(:tarball_path).to_path, it.send(:install_path).to_path)
      it.install!
    end
  end

  describe "#versions" do
    it "should make a single call to the API" do
      it.expects(:fetch_versions_from_api).returns(['1.0.0']).once
      expect(it.versions).to eq(['1.0.0'])
      expect(it.versions).to eq(['1.0.0'])
    end
  end

  describe "#api_call" do
    it "should return a parsed JSON document on success" do
      FakeWeb.register_uri(
        :get,    "https://api.github.com/test",
        :body => {:foo => 'bar'}.to_json,
      )

      expect(it.send(:api_call, '/test')).to eq({'foo' => 'bar'})
    end

    it "should append ?access_token if GITHUB_API_TOKEN envvar set" do
      FakeWeb.register_uri(
        :get,    "https://api.github.com/test?access_token=foo",
        :body => {:token => 'set'}.to_json,
      )
      FakeWeb.register_uri(
        :get,    "https://api.github.com/test",
        :body => {:token => 'unset'}.to_json,
      )

      ENV['GITHUB_API_TOKEN'] = "foo"
      expect(it.send(:api_call, '/test')).to eq({'token' => 'set'})
      ENV.delete('GITHUB_API_TOKEN')
    end

    it "should return nil if the JSON is malformed" do
      FakeWeb.register_uri(
        :get,    "https://api.github.com/test",
        :body => "{]",
      )

      expect(it.send(:api_call, '/test')).to be_nil
    end

    it "should raise an error on 404" do
      FakeWeb.register_uri(
        :get,      "https://api.github.com/repos/bar/puppet-foo/tags",
        :status => ["404", "Not Found"],
      )

      expect { it.send(:api_call, '/repos/bar/puppet-foo/tags') }.to raise_error(
        Henson::GitHubTarballNotFound, "Unable to find bar/puppet-foo on GitHub")
    end

    it "should raise an error on all other failures" do
      FakeWeb.register_uri(
        :get, "https://api.github.com/repos/bar/puppet-foo/tags",
        :status => ["418", "I'm A Teapot"],
      )

      expect { it.send(:api_call, '/repos/bar/puppet-foo/tags') }.to raise_error(
        Henson::GitHubAPIError,
        "GitHub API returned 418 for https://api.github.com/repos/bar/puppet-foo/tags",
      )
    end
  end

  describe "#fetch_versions_from_api" do
    before(:each) do
      FakeWeb.register_uri(
        :get, "https://api.github.com/repos/bar/puppet-foo/tags",
        :body => [
          {'name' => '1.0.0'},
          {'name' => '0.9.9-rc1'},
          {'name' => 'v2.1.0'},
        ].to_json,
      )
    end

    it "should return a list of version numbers" do
      expect(it.send(:fetch_versions_from_api)).to be_a(Array)
      expect(it.send(:fetch_versions_from_api)).to have(3).items
    end

    it "should strip leading v from version numbers" do
      expect(it.send(:fetch_versions_from_api)).to include('2.1.0')
      expect(it.send(:fetch_versions_from_api)).to_not include('v2.1.0')
    end

    it "should raise an error if no data is returned from the api" do
      FakeWeb.register_uri(
        :get,    "https://api.github.com/repos/bar/puppet-foo/tags",
        :body => nil,
      )
      expect { it.send(:fetch_versions_from_api) }.to raise_error(
        Henson::GitHubAPIError,
        "No data returned from https://api.github.com/repos/bar/puppet-foo/tags"
      )
    end
  end

  describe "#download_file" do
    it "should download the file" do
      FakeWeb.register_uri(
        :get,    "https://test.com/test/file",
        :body => 'Yay1',
      )

      File.expects(:open).with('/tmp/test', 'wb').returns(StringIO.new)
      it.send(:download_file, 'https://test.com/test/file', '/tmp/test')
      File.unstub(:open)
    end

    it "should follow redirects" do
      FakeWeb.register_uri(
        :get,        "https://test.com/test/file",
        :status   => ["301", "Moved Permanently"],
        :location => "https://test.com/test/file2",
      )
      FakeWeb.register_uri(
        :get,    "https://test.com/test/file2",
        :body => "Yay2",
      )

      File.expects(:open).with('/tmp/test', 'wb').returns(StringIO.new)
      it.send(:download_file, 'https://test.com/test/file', '/tmp/test')
      File.unstub(:open)
    end

    it "should raise an error on failure" do
      FakeWeb.register_uri(
        :get,      "https://test.com/test/file",
        :status => ["404", "Not Found"],
      )

      expect { it.send(:download_file, 'https://test.com/test/file', '/tmp/test') }.to raise_error(
        Henson::GitHubDownloadError,
        "GitHub returned 404 for https://test.com/test/file"
      )
    end
  end

  describe "#extract_tarball" do
    it "should be able to extract files" do
      stubbed_file = stub(
        :file?     => true,
        :full_name => 'bar-puppet-foo-124351ab/manifests/test.pp',
        :read      => 'file contents',
      )
      Zlib::GzipReader.expects(:open).with('/tmp/tarball.tar.gz').returns(nil)
      Gem::Package::TarReader.expects(:new).with(nil).returns([stubbed_file])
      File.expects(:open).with('/tmp/manifests/test.pp', 'wb').returns(StringIO.new)

      it.send(:extract_tarball, '/tmp/tarball.tar.gz', '/tmp')

      File.unstub(:open)
      Gem::Package::TarReader.unstub(:new)
      Zlib::GzipReader.unstub(:open)
    end

    it "should be able to create directories" do
      stubbed_dir = stub(
        :file?      => false,
        :directory? => true,
        :full_name  => 'bar-puppet-foo-125234a/manifests/foo',
      )
      Zlib::GzipReader.expects(:open).with('/tmp/tarball.tar.gz').returns(nil)
      Gem::Package::TarReader.expects(:new).with(nil).returns([stubbed_dir])
      FileUtils.expects(:mkdir_p).with('/tmp/manifests/foo')

      it.send(:extract_tarball, '/tmp/tarball.tar.gz', '/tmp')

      FileUtils.unstub(:mkdir_p)
      Gem::Package::TarReader.unstub(:new)
      Zlib::GzipReader.unstub(:open)
    end
  end

  describe "#cache_path" do
    it "should return a Pathname object" do
      expect(it.send(:cache_path)).to be_a(Pathname)
    end

    it "should return the path on disk to the tarball directory" do
      path = Pathname.new(Henson.settings[:cache_path]) + 'github_tarball'

      expect(it.send(:cache_path)).to eq(path)
    end
  end

  describe "#tarball_path" do
    it "should return a Pathname object" do
      it.expects(:version).once.returns('1.2.3')
      expect(it.send(:tarball_path)).to be_a(Pathname)
    end

    it "should return the path on disk to the tarball for this module" do
      path = Pathname.new(Henson.settings[:cache_path]) + 'github_tarball'
      path = path + 'bar-puppet-foo-1.2.3.tar.gz'

      it.expects(:version).once.returns('1.2.3')
      expect(it.send(:tarball_path)).to eq(path)
    end
  end

  describe "#clean_up_old_cached_versions" do
    stub_files = [
      "#{Henson.settings[:cache_path]}/github_tarball/bar-puppet-foo-0.0.1.tar.gz",
    ]

    it "should remove tarballs for this module only" do
      Dir.expects(:[]).with("#{Henson.settings[:cache_path]}/github_tarball/bar-puppet-foo-*.tar.gz").returns(stub_files)
      FileUtils.expects(:rm).with(stub_files.first).once
      it.send(:clean_up_old_cached_versions)
      Dir.unstub(:[])
    end
  end

  describe "#install_path" do
    it "should return a Pathname object" do
      expect(it.send(:install_path)).to be_a(Pathname)
    end

    it "should return the path that the module will be installed into" do
      path = Pathname.new(Henson.settings[:path]) + 'foo'

      expect(it.send(:install_path)).to eq(path)
    end
  end
end
