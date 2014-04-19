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

      result = db.reduce([]) do |acc,el|
        case el.last
        when Hash
          if found = el.last.detect { |_,value| value.include?(fact) }
            break [el.first, found.first]
          end
        when Array
          break [el.first] if el.last.detect(&fact.method(:==))
        else
          raise Puppet::ParseError, "Given db is invalid YAML: path=#{path}"
        end
      end
 
      if result 
        result    
      else
        if default
          [default]
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
