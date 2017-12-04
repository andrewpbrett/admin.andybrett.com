require 'sinatra'
require 'yaml'
require 'time'
require 'logger'
require 'exifr/jpeg'

before do
  @config = YAML.load_file('config.yml')
  unless params["secret"] == @config["sharedsecret"]
    halt 401, {'Content-Type' => 'text/plain'}, 'Unauthorized'
  end
end

post '/photo' do
  return 422 unless params[:image]
  photo_filename = "#{DateTime.now.strftime("%Y%m%d%H%M%S")}.jpg"
  photo_path = "#{@config["photopath"]}/#{photo_filename}"
  IO.write(photo_path, params[:image])
  exif = EXIFR::JPEG.new(photo_path)
  markdown = <<EOF
---
caption: "#{params[:caption]}"
filename: "#{photo_filename}"
fstop: "#{exif.respond_to?(:f_number) ? "f/#{exif.f_number.to_f.to_s}" : "Unknown"}"
exposure: "#{exif.respond_to?(:exposure_time) ? "#{exif.exposure_time.to_s}" : "Unknown"}"
---
EOF
  if params[:postdatenow]
    post_date = Time.now
  else
    post_date = exif.date_time_digitized
  end
  markdown_filename = post_date.strftime("%Y-%m-%d-")
  if params[:caption] && !params[:caption].empty?
    markdown_filename += params[:caption].gsub(/[^A-Za-z0-9\-\s]/, '').strip.gsub("\s", '-').downcase
  else
    markdown_filename += post_date.strftime("%Y-%m-%d-%H")
    markdown_filename += "-photo"
  end
  markdown_filename += ".md"

  IO.write("#{@config["photopostpath"]}/#{markdown_filename}", markdown)
  200
end

post '/link' do
  return 422 unless params[:url]
  markdown = <<EOF
---
external_link: "#{params[:url]}"
---
#{params[:before] ? params[:comment] : ''}
#{params[:quote] && !params[:quote].empty? ? "> " + params[:quote].gsub(/[\n\r]{2,}/, "\n\n\>\s") : ""}

#{params[:before] ? '' : params[:comment]}
EOF
  markdown_filename = DateTime.now.strftime("%Y-%m-%d-")
  if params[:title] && !params[:title].empty?
    markdown_filename += params[:title].gsub("\s", '-').downcase
  else
    markdown_filename += DateTime.now.strftime("%Y-%m-%d-%H-%M-")
    markdown_filename += "bookmark"
  end
  markdown_filename += ".md"

  IO.write("#{@config["bookmarkpath"]}/#{markdown_filename}", markdown)
  200
end
