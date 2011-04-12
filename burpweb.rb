#!/usr/bin/ruby
require 'rubygems'
require 'webrick'
require 'dm-core'
require 'dm-migrations'
require 'optparse'
require 'parseconfig'

require 'lib/web/burpfileupload'

Socket.do_not_reverse_lookup = true

class OptsConsole
  def self.parse(args)
    options = {}
    
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: ./burpweb.rb [options]"
      
      opts.separator ""
      opts.separator "Specific Options:"
      
      opts.on("-h", "--help", "Show help") do |v|
        puts opts
        puts
        puts "todo"
        exit
      end

      opts.on("-i", "-i <burp log file>", "Input: The Burp Log File") do |i|
        options['input'] = i
      end

    end
      
    begin
      opts.parse!(args)
#      if options['input'].nil? and options['version'].nil?
#        puts
#        puts "**Please specify an input file with the -i option**"
#        puts
#        puts opts
#        exit
#      end
      
#      options['overlap'] = "vpsc" if options['overlap'].nil? #Default overlap is orthoyx
#      options['mode'] = 'dot' if options['mode'].nil? #Default output mode is dot
#      options['truncate'] = 1 if options['mode'] == "dot" #Therefore, default mode is to truncate. i.e. incl \ns every 50 chars.
#      options['depth'] = 2 if options['depth'].nil? #Defaults to 2

    rescue OptionParser::InvalidOption
      puts "Invalid option, try -h for usage"
      exit
    end
      
    options
  end
end

options = OptsConsole.parse(ARGV)

#Load the configuration file
config = ParseConfig.new("burpweb.cfg")

if options['version']
  print verstring
  exit
end

#Starting up the web interface
httpconfig = {}
httpconfig[:BindAddress] = "127.0.0.1"
httpconfig[:Port] = "8015"
httpconfig[:Logger] = WEBrick::Log.new($stdout, WEBrick::Log::DEBUG)
httpconfig[:ServerName] = "BurpDot"
httpconfig[:ServerSoftware] = "BurpDot"

http_server = WEBrick::HTTPServer.new(httpconfig)

#Mount public content
http_server.mount("/",WEBrick::HTTPServlet::FileHandler,"lib/web/static")

#Mount the "burp log" file upload handler
http_server.mount("/logfile",Burpdot::WebBurpFileUpload)

trap("INT") {
  puts "Quitting..."
  http_server.stop
}

#Kick off the web server NOW! boom!
http_server.start