require 'puppet/parser/functions'
require 'fileutils'

module Puppet::Parser::Functions
  newfunction(:mkdir_p, :type => :rvalue) do |args|
    if (args.size != 1) then
      raise(Puppet::ParseError, "mkdir_p(): Wrong number of arguments given #{args.size} for 1")
    end
    dir_name = args[0]
    begin
      FileUtils.mkdir_p(dir_name)
    rescue
      return false
    end
    return true
  end
end
