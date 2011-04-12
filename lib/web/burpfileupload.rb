require 'lib/import'
require 'pp'

module Burpdot
  
class WebBurpFileUpload < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(req, res)
    filedata = req.query["logfile"]
    
    #f = File.open("foo.out", "wb")
    #f.syswrite filedata
    #f.close

    options = {}
    options['depth'] = 2
    options['input'] = filedata.split("\n")
    output = Burpdot::Import.importburpbase(options)

    res.body = pp output
    raise WEBrick::HTTPStatus::OK    
    #res.set_redirect(WEBrick::HTTPStatus::Found,"/")
    
  end
end

end
