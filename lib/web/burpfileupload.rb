module Burpdot
  
class WebBurpFileUpload < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(req, res)
    filedata = req.query["logfile"]
    
    options = {}
    options['depth'] = 2
    options['input'] = filedata.split("\n")
    options['output'] = $config.get_value('burpdbfile')
    output = Burpdot::Import.importburpbase(options)

    output = output.sort_by {|a| [a['host'], a['url']]}

    output.uniq!
    
    out = Burpdot::Output::Sqliteout.new(output,options)
    out.run

    res.set_redirect(WEBrick::HTTPStatus::Found,"/go/")
    
  end
end

end
