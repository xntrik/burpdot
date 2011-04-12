module Burpdot
  
class WebBurpFileUpload < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(req, res)
    filedata = req.query["logfile"]
    
    f = File.open("foo.out", "wb")
    f.syswrite filedata
    f.close
    
    res.set_redirect(WEBrick::HTTPStatus::Found,"/")
  end
end

end