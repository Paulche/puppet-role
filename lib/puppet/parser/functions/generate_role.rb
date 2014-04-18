require 'yaml'
 
module Puppet::Parser::Functions
  newfunction(:generate_role, :type => :rvalue) do |args|
    fact      = args[0]
    path      = args[1]
    default   = args[2]   

    yaml_error_class = if RUBY_VERSION == '1.8.7'
                         YAML::Error
                       else
                         YAML::SyntaxError
                       end


    begin
      db = YAML.load_file(path)

      raise Puppet::ParseError, "Given db is invalid YAML: path=#{path}" unless db.kind_of?(Hash)

      found = db.detect { |key,value| value.include?(fact) }
 
      if found 
        found.first    
      else
        if default
          default 
        else
          raise Puppet::ParseError, "Given host isn't found: host=#{fact}, path=#{path}"     
        end
      end

    rescue Errno::ENOENT 
      raise Puppet::ParseError, "Given path to db doesn't exist: path=#{path}" 

    rescue yaml_error_class => e
      raise Puppet::ParseError, "Given db is invalid YAML: path=#{path}"

    rescue StandardError => e
      raise Puppet::ParseError, "UnknownError: #{e.class} - #{e.message} - #{e.backtrace}"
    end
  end
end
