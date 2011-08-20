#!/usr/bin/ruby

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '.'))

$root_dir = File.expand_path('..', __FILE__)

require 'optparse'
require 'uri'
require 'lib/import'
require 'lib/output'

#Version and licensing gumpft
verstring = "Version 0.5.2 - 20th of August, 2011 - Created by Christian \"xntrik\" Frichot.\n\n"
verstring += "Copyright 2011 Christian Frichot\n\n"
verstring += "Licensed under the Apache License, Version 2.0 (the \"License\");\n"
verstring += "you may not use this file except in compliance with the License.\n"
verstring += "You may obtain a copy of the License at\n\n"
verstring += "\thttp://www.apache.org/licenses/LICENSE-2.0\n\n"
verstring += "Unless required by applicable law or agreed to in writing, software\n"
verstring += "distributed under the License is distributed on an \"AS IS\" BASIS,\n"
verstring += "WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n"
verstring += "See the License for the specific language governing permissions and\n"
verstring += "limitations under the License.\n"

class OptsConsole
  def self.parse(args)
    options = {}
    
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: ./burpdot.rb [options]"
      
      opts.separator ""
      opts.separator "Specific Options:"
      
      opts.on("-h", "--help", "Show help") do |v|
        puts opts
        puts
        puts "Example Overlap modes: 'scale', 'prism', 'vpsc', 'orthoyx'"
        puts "See http://www.graphviz.org/doc/info/attrs.html#d:overlap for more information"
        puts
        puts "Overlap is only used in \"dot\" mode."
        exit
      end

      opts.on("-i", "-i <burp log file>", "Input: The Burp Log File") do |i|
        options['input'] = i
      end

      opts.on("-l", "-l <overlap mode>", "Overlap: DOT file overlap mode. Defaults to 'vpsc'") do |l|
        options['overlap'] = l
      end
      
      opts.on("-o", "-o <output file>", "Output: The output file") do |o|
        options['output'] = o
      end

      opts.on("-m", "-m <mode>", "Mode: either dot, csv or sqlite. Defaults to dot") do |m|
        options['mode'] = m
      end

      opts.on("-v", "--version", "Show version") do |v|
        options['version'] = true
      end
      
      opts.on("-d", "-d <depth>", "Depth: 0, 1, 2 or 3. Defaults to 2") do |d|
        options['depth'] = d
      end

    end
      
    begin
      opts.parse!(args)
      if options['input'].nil? and options['version'].nil?
        puts
        puts "**Please specify an input file with the -i option**"
        puts
        puts opts
        exit
      end
      
      options['overlap'] = "vpsc" if options['overlap'].nil? #Default overlap is orthoyx
      options['mode'] = 'dot' if options['mode'].nil? #Default output mode is dot
      options['truncate'] = 1 if options['mode'] == "dot" #Therefore, default mode is to truncate. i.e. incl \ns every 50 chars.
      options['depth'] = 2 if options['depth'].nil? #Defaults to 2

    rescue OptionParser::InvalidOption
      puts "Invalid option, try -h for usage"
      exit
    end
      
    options
  end
end

options = OptsConsole.parse(ARGV)

if options['version']
  print verstring
  exit
end

entries = Burpdot::Import.importburplog(options)

#sort the entries by host, then url
entries = entries.sort_by {|a| [a['host'], a['url']]}

#get rid of duplicates
entries.uniq!

#Depending on the mode, we'll use a different output class
if options['mode'] == "dot"
  out = Burpdot::Output::Dotout.new(entries,options)
elsif options['mode'] == "csv"
  out = Burpdot::Output::Csvout.new(entries,options)
elsif options['mode'] == "sqlite"
  out = Burpdot::Output::Sqliteout.new(entries,options)
end

out.run #Run the output (d'uh)
