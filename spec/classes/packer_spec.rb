require "spec_helper"

describe "packer" do
  let(:facts) { default_test_facts }

  context "ensure => absent" do
    let(:params) { { :ensure => "absent" } }

    it do
      should contain_file("/test/boxen/packer").with_ensure("absent")
    end
  end
end
