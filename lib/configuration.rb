module Burpdot

class Configuration < ParseConfig
  def initialize(configuration_file="burpweb.cfg")
    super("#{$root_dir}/#{configuration_file}")
  end
  
end

end
