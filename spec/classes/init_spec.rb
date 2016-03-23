require 'spec_helper'
describe 'rubygems_mirror' do

  context 'with default values for all parameters' do
    it { should contain_class('rubygems_mirror') }
  end
end
