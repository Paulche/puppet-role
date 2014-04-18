require 'spec_helper'
require 'puppetlabs_spec_helper/puppetlabs_spec/puppet_internals'
require 'tempfile'

describe "generate_role()" do
  let(:scope)           { PuppetlabsSpec::PuppetInternals.scope }
  let(:fqdn_included)   { 'balancer1.i' }
  let(:fqdn_excluded)   { 'balancer100.i' }
  let(:path)            { '/etc/puppet/db.yaml' }
  let(:role)            { 'balancer' }
  let(:role_default)    { 'frontend' }
  let(:db)              { { role => [fqdn_included] } }

  before(:each) do 
    YAML.expects(:load_file).with(path).returns(db) unless example.metadata[:skip_before] 
  end

  context 'Successful cases' do 
    it 'should return given role' do 
      expect(scope.function_generate_role([fqdn_included,path])).to eq(role)
    end

    it 'should return default role' do 
      expect(scope.function_generate_role([fqdn_excluded,path,role_default])).to eq(role_default)
    end
  end

  context 'Failures' do 
    it "should raise Puppet::ParseError when host isn't included in DB and no default value given" do 
      expect { scope.function_generate_role([fqdn_excluded,path]) }.to raise_error(Puppet::ParseError, /Given host isn't found/)
    end

    it "should raise Puppet::ParserError when path doesn't exist", :skip_before => true do 
      expect { scope.function_generate_role(['fake','/this_path_doesnt_exist']) }.to raise_error(Puppet::ParseError, /Given path to db doesn't exist/)
    end

    context 'YAML specific behavior', :skip_before => true do 
      before(:each) do 
        @tempfile = Tempfile.new('yaml_db')
        @tempfile.write('iamfake')
      end

      after(:each) do 
        @tempfile.unlink
      end

      it 'should raise Puppet::ParseError when when db is invalid YAML' do 
        expect { scope.function_generate_role(['dontcare', @tempfile.path]) }.to raise_error(Puppet::ParseError, /Given db is invalid YAML/)
      end

      it 'should raise Puppet::ParseError when when db is invalid YAML (BLOB)' do 
        expect { scope.function_generate_role(['dontcare', '/bin/bash']) }.to raise_error(Puppet::ParseError, /Given db is invalid YAML/)
      end
    end
  end
end
