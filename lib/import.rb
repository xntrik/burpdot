module Burpdot

#
#This is pretty simple, I wrapped it as a class, but you don't *really* instantiate it.
#
# Simply run the 'importburplog' method with your input, eg:
# => entries = Burpdot::Import.importburplog(file,truncate)
# If the second option is anything except for nil, then we'll insert \n characters every 50 chars
#

class Import

  #
  #The importburplog takes a burp log, and throws it into importburpbase for processing
  #
  def self.importburplog(options)

    tmpfile = [] #We need an array for importburpbase

    begin
      tmpfile = File.open(options['input'], 'r').readlines
    rescue SystemCallError
      puts "No such file as " + options['input']
      exit
    end

    options['input'] = tmpfile #Cludge it back into the options hash

    self.importburpbase(options) #go!
  
  end

  #The importburpbase takes an array of burp log lines, reads it backwards, and spits out an array of entry hashes.
  #
  # All the parameters are included in the options hash
  # - input - the input array
  # - depth - the depth of the search, either 1, 2 or 3
  # - truncate - if not nil, then we truncate
  #
  # by default we are truncating, otherwise, the entries are really long.
  def self.importburpbase(options)

    entry = {} #An entry hash, includes a host, url, and referer
    entries = [] #An array of entrys (gah! Plural singular assplosion!)
    
    #We open the file backwards, because this way we can build up the entry easier, in particular the referer
    options['input'].reverse.each do |line|
      entry['ref'] = line.match(/^Referer: https?:\/\/([^ ]*)/i)[1].chomp if line =~ /^Referer:/i #Get the ref
      entry['host'] = line.match(/^Host: (.*)/i)[1].chomp if line =~ /^Host:/i #Get the host
      if line =~ /^(GET|POST) /i #At this point, we're at the top of that log entry, so wrap it up and put it in the array

        #Get the URL
        entry['url'] = line.match(/^(GET|POST) ([^ ]*)/i)[2]
          
        #Get the Verb
        entry['verb'] = line.match(/^(GET|POST)/i)[1] #For ver 0.4 we now get the VERB and store separately
          
        #Truncate the URL to just the domain, if depth is 1
        entry['url'] = "" if options['depth'].to_i == 1 and not entry['url'].nil?
        
        #How about truncate the URL to exclude the parameters if depth is 2
        entry['url'] = entry['url'].match(/^([^?]*)/i)[1] if options['depth'].to_i == 2 and not entry['url'].nil?
          
        #Truncate the URL if truncate is enabled, i.e., in dot mode
        entry['url'] = entry['url'].scan(/.{1,50}/).join('\n') if not options['truncate'].nil? and not entry['url'].nil?
          
        #Truncate the REF URL to just the domain, if depth is 1
        entry['ref'] = entry['ref'].match(/^([^\/]*)/i)[1] if options['depth'].to_i == 1 and not entry['ref'].nil?
          
        #Truncate the REF URL to exclude the parameters if depth is 2
        entry['ref'] = entry['ref'].match(/^([^?]*)/i)[1] if options['depth'].to_i == 2 and not entry['ref'].nil?
          
        #Now we truncate REF ref URL, if truncate is enabled, i.e., in dot mode
        entry['ref'] = entry['ref'].scan(/.{1,50}/).join('\n') if not options['truncate'].nil? and not entry['ref'].nil?
          
        #Push the entry into the entries thingo
        entries << entry
          
        #Blank the hash again
        entry = {}
      end
    end

    entries #Return all the entries
  end

end

end
