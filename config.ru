# This file is used by Rack-based servers to start the application.
require 'toto'
require ::File.expand_path('../config/environment',  __FILE__)

#point to your rails apps /public directory
use Rack::Static, :urls => ['/stylesheets', '/javascripts', '/images', '/favicon.ico'], :root => 'public'

use Rack::ShowExceptions
use Rack::CommonLogger

#run the toto application
toto = Toto::Server.new do

  #override the default location for the toto directories
  Toto::Paths = {
    :templates => "blog/templates",
    :pages => "blog/templates/pages",
    :articles => "blog/articles"
  }

  # set your config variables here
  set :title, 'Localcar.co blog'
  set :date, lambda {|now| now.strftime("%B #{now.day.ordinal} %Y") }
  set :summary,   :max => 500
  set :root, 'index'
  set :prefix, 'blog'

  if RAILS_ENV != 'production'
    set :url, "http://localhost:3000/blog/"
  else
    set :url, "http://toto-bongo.heroku.com/blog/" #EDIT THIS TO ADD YOUR OWN URL
  end
end 

#create a rack app
app = Rack::Builder.new do
  use Rack::CommonLogger

  #map requests to /blog to toto
  map '/blog' do
    run toto
  end
  
  #map all the other requests to rails
  map '/' do
    if Rails.version.to_f >= 3.0
      ActionDispatch::Static
      run TotoBongoBlog::Application  #Map your application
    else # Rails 2
      use Rails::Rack::Static
      run ActionController::Dispatcher.new
    end
  end
end.to_app

run app



