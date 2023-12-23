require 'rack/app'
class MyApp < Rack::App
  get '/' do
    'Hello, Rack-App!'
  end
end
run MyApp
