require 'spec_helper_acceptance'

describe 'basic nova' do

  context 'default parameters' do

	it 'should work with no errors' do
      pp= <<-EOS
        file { '/data':
            ensure => directory,
        }
        package { 'cronie':
            ensure => installed,
        }
		class { 'rubygems_mirror': }
	  EOS
	  apply_manifest(pp, :catch_failures => true)
	  apply_manifest(pp, :catch_changes => true)
	end

    describe cron do
	  it { is_expected.to have_entry("*/10 * * * * pgrep -f 'gem mirror' || gem mirror").with_user('root') }
    end
    describe package('rubygems-mirror') do
      it { is_expected.to be_installed.by('gem') }
    end
    
    describe file('/data/mirror') do
      it { should be_directory }
    end

    describe file('/root/.gem/.mirrorrc') do
      it { should be_file }
      its(:content) { should match(/^- from: http:\/\/rubygems.org$/) }
      its(:content) { should match(/^  to: \/data\/mirror$/) }
      its(:content) { should match(/^  parallelism: 10$/) }
      its(:content) { should match(/^  delete: true$/) }
    end
  end
end
