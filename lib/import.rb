module Burpdot

#
#This is pretty simple, I wrapped it as a class, but you don't *really* instantiate it.
#
# Simply run the 'importburplog' method with your input, eg:
# => entries = Burpdot::Import.importburplog(file,truncate)
# If the second option is anything except for nil, then we'll insert \n characters every 50 chars
#

class Import

  #The importburplog takes a burp log, reads it backwards, and spits out an array of entry hashes.
  #
  # The second parameter, truncate, is whether to insert new line characters into the mix
  # by default we are truncating, otherwise, the entries are really long.
  def self.importburplog(filename, truncate = nil)

    entry = {} #An entry hash, includes a host, url, and referer
    entries = [] #An array of entrys (gah! Plural singular assplosion!)
    
    #We open the file backwards, because this way we can build up the entry easier, in particular the referer
    begin
      File.open(filename, 'r').readlines.reverse.each do |line|
        entry['ref'] = line.match(/^Referer: https?:\/\/([^? ]*)/i)[1].chomp if line =~ /^Referer:/i #Get the ref
        entry['host'] = line.match(/^Host: (.*)/i)[1].chomp if line =~ /^Host:/i #Get the host
        if line =~ /^GET /i #At this point, we're at the top of that log entry, so wrap it up and put it in the array
          entry['url'] = line.match(/^GET ([^? ]*)/i)[1]
          entry['url'] = entry['url'].scan(/.{1,50}/).join('\n') if not truncate.nil? and not entry['url'].nil?
          entry['ref'] = entry['ref'].scan(/.{1,50}/).join('\n') if not truncate.nil? and not entry['ref'].nil?
          entries << entry
          entry = {}
        end
      end
    rescue SystemCallError
      puts "No such file as " + filename
      exit
    end

    entries
  end

end

end