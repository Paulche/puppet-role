require 'yaml'
 
module Puppet::Parser::Functions
  newfunction(:ftemplate, :type => :rvalue) do |args|
    file_path = args.first 

    unless real_file_path = Puppet::Parser::Files.find_template(file_path, self.compiler.environment)
      raise Puppet::ParseError, "Could not find template '#{file_path}'"
    end

    footer = <<HERE
#
# This file managed by Puppet!
# Path to file on Master: #{real_file_path}
#

HERE
  
    [footer, function_template([file_path])].join('')
  end
end
