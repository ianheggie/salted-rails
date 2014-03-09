require 'spec_helper'

describe 'init.sh' do
  context 'when run', :slow => true do

    before(:all) do
      @output = `sh init.sh < /dev/null`
      @exit_status = $?
    end

    it 'should not exit with an error' do
      expect(@exit_status).to be == 0
    end

    it "should create ~/.vagrant.d directory" do
      expect(File.directory?("#{ENV['HOME']}/.vagrant.d")).to be == true 
    end

    context "output" do
      subject { @output }

      it { should =~ /VirtualBox/ }

      if system 'which vagrant > /dev/null'
        it { should =~ /Found vagrant/ }
        it { should =~ /Vagrant\s*\d+\.\d+\.\d+/ }
        # should mention plugins
        %w{deep_merge vagrant-digitalocean vagrant-vbguest salted-rails}.each do |plugin|
          it { should =~ /plugin #{plugin}/ }
        end
      else
        it { should =~ /Please install vagrant/ }
      end

      if system 'which VirtualBox > /dev/null'
        it { should =~ /Found VirtualBox/ }
        it { should =~ /VirtualBox\D+\d+\.\d+\.\d+/ }
      else
        it { should =~ /Plase install VirtualBox/ }
      end

    end
  end
end
