class CoreERR_CSSFileNotFound < StandardError
end

class RcssController < ActionController::Base
  layout nil
  session :off
  # serve dynamic stylesheet with name defined
  # by filename on incoming URL parameter :rcss
  def rcss
    # :rcssfile is defined in routes.rb
    if @stylefile = params[:rcssfile]
      #prep stylefile with relative path and correct extension
      @stylefile.gsub!(/.css$/, '')
      @stylefile = File.join("vendor", "plugins", "template_derby", "app", "views", "rcss", @stylefile + ".rcss")

      #check for existence of @stylefile on filesystem - raise system error if not found
      if not(File.exists?(@stylefile))
        raise CoreERR_CSSFileNotFound
      end

      # set caching because we have a good css file to ship
      expires_in 4.hours unless (($prevent_layout_caching==true) rescue true)
      render(:file => @stylefile, :use_full_path => false, :content_type => "text/css")
    else #no method/action specified
      render(:nothing => true, :status => 404)
    end #if @stylefile..
  end #rcss
end