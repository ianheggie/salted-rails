#require 'rspec'
require 'spec_helper'

require 'salted-rails/config'

describe 'SaltedRails::Config' do

  context '.new with empty project' do
    subject { SaltedRails::Config.new(File.expand_path('../examples/empty_project', File.dirname(__FILE__))) }

    context 'attributes' do
      %w{ admin_password box ca_path copy_from_home databases domain files forward_agent gems hostname
         logger machine machines mapped_ports memory mirror packages ports private_key_path project_root
         region roles salt_root staging_password sync_vagrant versions }.each do |attr|
          it { should respond_to(attr) }
          it { should respond_to("#{attr}=") }
      end
    end

    context '#sanitize_dns_name' do
      it 'should lowercase names' do
        expect(subject.sanitize_dns_name('FRED')).to be == 'fred'
      end
      
      it 'should replace one or more illegal chars with hyphen' do
        expect(subject.sanitize_dns_name('apple\'s')).to be == 'apple-s'
        expect(subject.sanitize_dns_name('what!_*&fruit')).to be == 'what-fruit'
      end
        
      it 'should not leave hyphens on the end' do
        expect(subject.sanitize_dns_name('one-')).to be == 'one'
        expect(subject.sanitize_dns_name('no!!!!')).to be == 'no'
      end
    end

    describe '.machines' do
      it { expect(subject.machines).to be == [ ] }
    end

    describe '.machine' do
      it { expect(subject.machine).to be == 'default' }
    end

    describe '.roles' do
      it { expect(subject.roles).to be == %w{ app web db } }
    end

    describe '.ports' do
      it { expect(subject.ports).to be == [ 80, 443, 880, 3000, 8808 ] }
    end

    describe '.files' do
      it { expect(subject.files).to be == [ ] }
    end

    describe '.gems' do
      it { expect(subject.gems).to be == { } }
    end

   end

  context '.new with project having Gemfile' do
    subject { SaltedRails::Config.new(File.expand_path('../examples/project_with_Gemfile', File.dirname(__FILE__))) }

    describe '.files' do
      it { expect(subject.files).to be == %w{ Gemfile } }
    end

    describe '.gems' do
      it { expect(subject.gems).to be == { 'mysql' => true } }
    end

    describe '.roles' do
      it { expect(subject.roles).to be == %w{ app web db mysql } }
    end
  end
end
