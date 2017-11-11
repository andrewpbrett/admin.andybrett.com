require 'sinatra'
require 'yaml'
require 'time'

before do
  @config = YAML.load_file('config.yml')
  unless params["secret"] == @config["sharedsecret"]
    halt 401, {'Content-Type' => 'text/plain'}, 'Unauthorized'
  end
end

post '/photo' do
  IO.write("#{@config["photopath"]}/#{DateTime.now.strftime("%Y%m%d%H%M%S")}.jpg", params[:image])
end

post '/link' do

end

get '/' do
  'Hello world!'
end
