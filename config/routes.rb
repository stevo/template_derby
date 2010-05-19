ActionController::Routing::Routes.draw do |map|
  map.connect 'rcss/:rcssfile.css', :controller => 'rcss', :action => 'rcss'
end