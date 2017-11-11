require 'sinatra'
require 'yaml'

before do
  @config = YAML.load_file('config.yml')
  unless params["secret"] == @config["sharedsecret"]
    halt 401, {'Content-Type' => 'text/plain'}, 'Unauthorized'
  end
end

post '/photo' do
  IO.write(@config["photopath"], params[:image])
end

post '/link' do

end
