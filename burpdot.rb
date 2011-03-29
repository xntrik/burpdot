#!/usr/bin/ruby
require 'optparse'

#Version and licensing gumpft
verstring = "Version 0.1 - 19th March, 2011 - Created by Christian \"xntrik\" Frichot.\n\n"
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
        puts "If mode is set to \"csv\" then overlap is ignored"
        exit
      end

      opts.on("-i", "-i <burp log file>", "Input: The Burp Log File") do |i|
        options['input'] = i
      end

      opts.on("-l", "-l <overlap mode>", "Overlap: DOT file overlap mode. Defaults to 'orthoyx'") do |l|
        options['overlap'] = l
      end
      
      opts.on("-o", "-o <output file>", "Output: The output file") do |o|
        options['output'] = o
      end

      opts.on("-m", "-m <mode>", "Mode: either dot or csv. Defaults to dot") do |m|
        options['mode'] = m
      end

      opts.on("-v", "--version", "Show version") do |v|
        options['version'] = true
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
      
      options['overlap'] = "orthoyx" if options['overlap'].nil?
      options['mode'] = 'dot' if options['mode'].nil?

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

entry = {} #An entry hash, includes a host, url, and referer
entries = [] #An array of entrys (gah! Plural singular assplosion!)

#We open the file backwards, because this way we can build up the entry easier, in particular the referer
File.open(options['input'], 'r').readlines.reverse.each do |line|
  entry['ref'] = line.match(/^Referer: https?:\/\/([^? ]*)/i)[1].chomp if line =~ /^Referer:/i #Get the ref
  entry['host'] = line.match(/^Host: (.*)/i)[1].chomp if line =~ /^Host:/i #Get the host
  if line =~ /^GET /i #At this point, we're at the top of that log entry, so wrap it up and put it in the array
    entry['url'] = line.match(/^GET ([^? ]*)/i)[1]
    entry['url'] = entry['url'].scan(/.{1,50}/).join('\n') if options['mode'] == "dot" and not entry['url'].nil?
    entry['ref'] = entry['ref'].scan(/.{1,50}/).join('\n') if options['mode'] == "dot" and not entry['ref'].nil?
    entries << entry
    entry = {}
  end
end

#sort the entries by host, then url
entries = entries.sort_by {|a| [a['host'], a['url']]}

#get rid of duplicates
entries.uniq!

#output
oFile = File.new(options['output'],'w') if not options['output'].nil?
if options['mode'] == "dot"
  if oFile
    oFile.syswrite("digraph Burp {\nnode [shape=rect]\n")
  else
    print "digraph Burp {\nnode [shape=rect]\n"
  end
end
entries.each do |line|
  if oFile
    if options['mode'] == "dot"
      oFile.syswrite("\"" + line['ref'].to_s + "\"->") if not line['ref'].nil?
      oFile.syswrite("\"" + line['host'].to_s + line['url'].to_s + "\"\n")
    elsif options['mode'] == "csv"
      oFile.syswrite(line['ref'].to_s + "," + line['host'].to_s + line['url'].to_s + "\n") if not line['ref'].nil?
    end
  else
    if options['mode'] == "dot"
      print "\"" + line['ref'].to_s + "\"->" if not line['ref'].nil?
      print "\"" + line['host'].to_s + line['url'].to_s + "\"\n"
    elsif options['mode'] == "csv"
      print line['ref'].to_s + "," + line['host'].to_s + line['url'].to_s + "\n" if not line['ref'].nil?
    end
  end
end
if options['mode'] == "dot"
  if oFile
    oFile.syswrite("\noverlap=" + options['overlap'] + "\n}\n")
  else
    print "\noverlap=" + options['overlap'] + "\n}\n"
  end
end
