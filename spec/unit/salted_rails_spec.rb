require 'rspec'
require 'spec_helper'

require 'salted-rails'

describe 'SaltedRails' do

  context "::VESION" do
    subject { SaltedRails::VERSION }
    it { should =~ /^\d+\.\d+\.\d+/ }
  end

end
