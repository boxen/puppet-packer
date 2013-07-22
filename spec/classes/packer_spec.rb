require "spec_helper"

describe "packer" do
  let(:facts) { default_test_facts }
  let(:default_params) do
    {
      :ensure  => "present",
      :version => "0.2.0"
    }
  end

  context "ensure => present" do
    let(:params)  { default_params }
    let(:command) {
      [
        "rm -rf /tmp/packer* /tmp/0",
        # download the zip to tmp
        "curl http://dl.bintray.com/mitchellh/packer/0.2.0_darwin_amd64.zip?direct > /tmp/packer-v0.2.0.zip",
        # extract the zip to tmp spot
        "mkdir /tmp/packer",
        "unzip -o /tmp/packer-v0.2.0.zip -d /tmp/packer",
        # blow away an existing version if there is one
        "rm -rf /test/boxen/packer",
        # move the directory to the root
        "mv /tmp/packer /test/boxen/packer",
        # chown it
        "chown -R testuser /test/boxen/packer"
      ].join(" && ")
    }

    it do
      should contain_exec("install packer v0.2.0").with({
        :command => command,
        :unless  => "test -x /test/boxen/packer/packer && /test/boxen/packer/packer -v | grep '\\bv0.2.0\\b'",
        :user    => "testuser",

      })

      should contain_file("/test/boxen/env.d/packer.sh")
    end

    context "linux" do
      let(:facts) { default_test_facts.merge(:operatingsystem => "Debian") }

      it do
        should_not contain_file("/test/boxen/env.d/packer.sh")
      end
    end
  end

  context "ensure => absent" do
    let(:params) { default_params.merge(:ensure => "absent") }

    it do
      should contain_file("/test/boxen/packer").with_ensure("absent")
    end
  end

  context "ensure => whatever" do
    let(:params) { default_params.merge(:ensure => "whatever") }

    it do
      expect {
        should contain_file("/test/boxen/packer")
      }.to raise_error(Puppet::Error, /Ensure must be present or absent/)
    end
  end
end
