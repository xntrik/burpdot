require 'singleton'

module Burpdot

class Configuration < ParseConfig
  include Singleton
  def initialize(configuration_file="#{$root_dir}/burpweb.cfg")
    super(configuration_file)
  end
  
end

end