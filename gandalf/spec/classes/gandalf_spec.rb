require 'rspec-puppet' 
require 'spec_helper'
# require 'fileutils'

describe 'gandalf'  do

  before (:each) do
     FileUtils.stubs(:mkdir_p).returns(true)
  end

  let :facts do
    { :osfamily => 'Debian', :operatingsystem => 'Ubuntu', :lsbdistid => 'Ubuntu', :lsbdistcodename => 'precise', :hostname => 'foo.bar' }
  end

  let :params do
    {
      :gandalf_host => 'foo.bar',
      :gandalf_ipbind_port => '0.0.0.0:9000',
      :gandalf_db_url => 'foobar:27017',
      :gandalf_db_name => 'gandalf_db',
      :gandalf_repositories_path =>  '/foo/bar/repos',
      :gandalf_bare_template_path => '/foo/bar/bare',
      :gandalf_create_repositories => true,
      :gandalf_create_bare_template => true,
      :gandalf_user => 'gand_user',
      :gandalf_group => 'gand_group',
      :gandalf_version => '0.1.0',
      :tsuru_api_host  => 'api_host',
      :tsuru_api_token => 'api_token'
    }
  end

  it 'requires class base' do
    should contain_class('base')
  end

  it 'install gandalf-server package' do
    should contain_package('gandalf-server').with({
      :ensure => '0.1.0'
    })
  end

  it 'creates file /etc/gandalf.conf' do
    should contain_file('/etc/gandalf.conf').with({
      :content => /url: foobar:27017.+name: gandalf_db.+location: \/foo\/bar\/repos.+template: \/foo\/bar\/bare.+host: foo.bar.+bind: 0.0.0.0:9000.+uid: gand_user\n/m,
      :notify => 'Service[gandalf-server]'
    })
  end

  it 'creates file /etc/init/gandalf-server.conf' do
    should contain_file('/etc/init/gandalf-server.conf').with({
      :content => /setuid gand_user\nsetgid gand_group\nexec \/usr\/bin\/gandalf-server/,
      :notify => 'Service[gandalf-server]'
    })
  end



  it 'runs gandalf-server service' do
    should contain_service('gandalf-server').with({
      :ensure => 'running',
      :subscribe => 'File[/etc/init/gandalf-server.conf]'
    })
  end

  it 'fix git repositories base dir permission' do
    should contain_file('/foo/bar/repos').with({
       :ensure  => 'directory',
       :recurse => 'true',
       :owner   => 'gand_user',
       :group   => 'gand_group',
    })
  end

  it 'fix bare template dir permission' do
    should contain_file('/foo/bar/bare').with({
       :ensure  => 'directory',
       :recurse => 'true',
       :owner   => 'gand_user',
       :group   => 'gand_group',
    })
  end

  context 'enabling git-daemon' do
    before {  params.merge!( :gandalf_git_daemon => true ) }

    it 'runs git-daemon service' do
      should contain_service('git-daemon').with({
        :ensure => 'running',
        :subscribe => 'File[/etc/init/git-daemon.conf]'
      })
    end

    it 'creates file /etc/init/git-daemon.conf' do
      should contain_file('/etc/init/git-daemon.conf').with ({
        :content => /setuid gand_user\nsetgid gand_group\nexec .+git daemon --base-path=\/foo\/bar\/repos/,
        :notify => 'Service[git-daemon]'
      })
    end
  end

  context 'using s3 storage' do

    before { params.merge!( :gandalf_storage_type => 's3', :gandalf_storage_bucket => 'foobar' ) }

    it { should contain_class('python') }
    it { should contain_python__virtualenv('/var/lib/gandalf/virtualenv') }
    it { should contain_python__pip('s3cmd') }
    it { should contain_file('/foo/bar/bare/hooks/pre-receive').with_content(/.+s3cmd.+/) }
    it "generate .profile " do
      should contain_file('/var/lib/gandalf/.profile').with_content(%r{^export[  ]TSURU_HOST=api_host\n
                                                                       ^export[  ]TSURU_TOKEN=api_token\n
                                                                       ^export[  ]BUCKET_NAME=foobar\n
                                                                       ^export[  ]CONTAINER_NAME=foobar}mx)
    end

  end

  context 'using swift storage' do

    before { params.merge!( :gandalf_storage_type => 'swift', :gandalf_storage_bucket => 'foobar',
                            :gandalf_cdn_url => 'http://foobar', :gandalf_auth_params => '-x foo -y bar') }

    it { should contain_class('python') }
    it { should contain_python__virtualenv('/var/lib/gandalf/virtualenv') }
    it { should contain_python__pip('swift') }
    it { should contain_file('/foo/bar/bare/hooks/pre-receive').with_content(/.+swift.+/) }
    it "generate .profile " do
      should contain_file('/var/lib/gandalf/.profile').with_content(%r{^export[  ]TSURU_HOST=api_host\n
                                                                       ^export[  ]TSURU_TOKEN=api_token\n
                                                                       ^export[  ]BUCKET_NAME=foobar\n
                                                                       ^export[  ]CONTAINER_NAME=foobar\n
                                                                       ^export[  ]CDN_URL="http://foobar"\n
                                                                       ^export[  ]AUTH_PARAMS="-x[  ]foo[  ]-y[  ]bar"}mx)
    end

  end 

end
