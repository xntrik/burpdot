require 'singleton'

module Burpdot

class Configuration < ParseConfig
  include Singleton
  def initialize(configuration_file="burpweb.cfg")
    super("#{$root_dir}/#{configuration_file}")
  end
  
end

end
