require 'spec_helper'

describe 'mkdir_p' do

  before (:all) do
    FileUtils.stubs(:mkdir_p).returns(true).then.raises(Errno::EACCES)
  end

  it { should run.with_params('/foo/bar').and_return(true) }

  it { should run.with_params('/var/lib/bar').and_return(false) }

  it { should run.with_params().and_raise_error(Puppet::ParseError, /number of arguments/) }

  it { should run.with_params('/foo/bar','/foo/bar/bla').and_raise_error(Puppet::ParseError, /number of arguments/) }

end
