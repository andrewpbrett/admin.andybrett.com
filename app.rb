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
  photo_filename = "#{DateTime.now.strftime("%Y%m%d%H%M%S")}.jpg"
  IO.write("#{@config["photopath"]}/#{photo_filename}", params[:image])
  markdown = <<EOF
---
type: photo
layout: main
caption: "#{params[:caption]}"
filename: "#{photo_filename}"
---
EOF
  markdown_filename = DateTime.now.strftime("%Y-%m-%d-")
  if params[:caption] && !params[:caption].empty?
    markdown_filename += params[:caption].gsub("\s", '-').downcase
  else
    markdown_filename += DateTime.now.strftime("%Y-%m-%d-%H")
    markdown_filename += "photo"
  end
  markdown_filename += ".md"

  IO.write("#{@config["photopostpath"]}/#{markdown_filename}", markdown)
  200
end

post '/link' do
  markdown = <<EOF
---
type: bookmark
layout: main
title: "#{params[:title]}"
external_link: "#{params[:external_link]}"
---
"#{params[:before] ? params[:comment] : ''}"
> #{params[:pullquote]}
"#{params[:before] ? '' : params[:comment]}"
EOF
  markdown_filename = DateTime.now.strftime("%Y-%m-%d-")
  if params[:title] && !params[:title].empty?
    markdown_filename += params[:caption].gsub("\s", '-').downcase
  else
    markdown_filename += DateTime.now.strftime("%Y-%m-%d-%H-%M-")
    markdown_filename += "bookmark"
  end
  markdown_filename += ".md"

  IO.write("#{@config["bookmarkpath"]}/#{markdown_filename}", markdown)
  200
end
