#!/usr/bin/env ruby

require 'yaml'
require 'oauth2'
require 'json'
require 'prawn'
require 'rqrcode'
require 'gruff'


# Load credentials
begin
  config = YAML.load_file("secret.credentials.yml")
  client_id = config["api"]["client_id"]
  client_secret = config["api"]["client_secret"]
rescue StandardError => err
  p "Rescue @Load_api_credentials #{err.inspect}"
  p "Wrong secret.credentials.yml file, are you sure it exist and is formated ok?"
end

# Protect arg input
unless (ARGV.first == nil || ARGV.length > 1)
  user = ARGV.first
else
  p "Usage: You need to pass a single valid login as argument"
  exit(1)
end

# Check credentials
begin
  client = OAuth2::Client.new(client_id, client_secret, site: "https://api.intra.42.fr")
  token = client.client_credentials.get_token
  response = token.get("/v2/users/#{user}")
  raw_coa = token.get("/v2/users/#{user}/coalitions")
rescue StandardError => err
  p "Rescue @Check_api_credentials #{err.inspect}"
  p "Wrong secret.credentials.yml content, please check your credentials"
end

#check response status
if response.status != 200
  p "Sorry, something went wrong with the API, try again later or report the problem"
  exit(2)
end
user_data = response.parsed
coa_data = raw_coa.parsed.first
p "Debug"
p response.status
p user_data['usual_full_name']
p user_data['image_url']


#API replacement variables
user_name = user_data['usual_full_name']
login = user_data['login'].capitalize
email = user_data['email']
rank = user_data['cursus_users'].last['grade']
current_level = user_data['cursus_users'].last['level'].to_i
percent_level = (((user_data['cursus_users'].last['level'].to_f) - current_level) * 100).to_i
url_pic = user_data['image_url']
coa_name = coa_data['name']
coa_color = coa_data['color'][1..-1]
piscine_month = user_data['pool_month']
piscine_year = user_data['pool_year']

#palceholder images
coa_image = './sources/metropolis_icon.png'

#Colors
green = coa_color#'00babc'
white = 'ffffff'
gray = '4E5566'
clear_gray = 'E7E7E7'
dark_grey = '000000'

#Generate skill image

max_scale = 5
graff = Gruff::Spider.new(max_scale)
graff.transparent_background = true
graff.title = "Skills"
graff.legend_font_size = 8
graff.font_color = '#' + gray
graff.marker_color = '#' + green

user_data['cursus_users'].last['skills'].each do |skill|
  graff.data skill['name'], skill['level'], '#' + coa_color
end
graff.write("spider_graph.png")

#Generate pdf
Prawn::Document.generate('assignment.pdf') do |pdf|

  #generate new rectangle [postition], w, h

  #main rectangle
  pdf.rectangle [0, 720], 200, 226
  pdf.fill_color green
  pdf.fill

  #gray rectangle
  pdf.rectangle [0, 495], 200, 495
  pdf.fill_color gray
  pdf.fill
 
  #clear_gray rectangle
  pdf.rectangle [200, 720], 345, 720
  pdf.fill_color clear_gray
  pdf.fill

  #Image on green rectangle 
  #TODO: replace get image and delete image with ruby methods
  puts `wget #{url_pic} -O temp_profile.jpg 2> /dev/null`
  puts `convert -scale 400 -gravity Center -crop 400x400+0+0 ./temp_profile.jpg ./circle_profile.png`
  puts `convert -size 400x400 xc:Black -fill White -draw 'circle 200 200 200 1' -alpha copy mask.png`
  puts `convert circle_profile.png -gravity Center mask.png -compose CopyOpacity -composite -trim circle_profile.png`
  pdf.image "./circle_profile.png", at: [12, 700], width: 175
 
  #Global text config
  pdf.font_families.update(
    'Futura' => {
      normal: "./sources/Futura.ttf",
      bold: "./sources/Futura_Bold.ttf"
    }
  )
  pdf.font('Futura')

  #Text on green rectangle
  pdf.fill_color white
  #pdf.stroke_color green
  #pdf.line_width = 1
  #pdf.cap_style :butt
  pdf.text_box user_name, styles: :bold, size: 22, at: [20, 570], width: 180 #mode: :fill_stroke
  pdf.text_box 'Rank: ' + rank, styles: :normal, size: 16, at: [20, 520]

  #Image on gray rectangle
  pdf.image "./sources/Logo-42.png", at: [10, 100], width: 175
  
  # Level bar
  pdf.text_box 'Current Level:', size: 10, at: [10, 480]
  pdf.rounded_rectangle [10, 460], 180, 20, 5
  pdf.fill_color dark_grey
  pdf.fill

  pdf.rounded_rectangle [10, 460], (180 * percent_level.to_i)/100 , 20, 5
  pdf.fill_color green
  pdf.fill

  pdf.fill_color white
  pdf.text_box "Level #{current_level} - #{percent_level}%", size: 10, at: [67, 456]
 

  #Piscine 
  pdf.fill_color white
  pdf.text_box "Student since: #{piscine_month}, #{piscine_year}", size: 10, at: [10, 427]


  #Coalition
  pdf.fill_color white
  pdf.text_box "Member of:", size: 10, at: [10, 405]
  pdf.rounded_rectangle [30, 385], 140, 50, 5 
  pdf.fill_color coa_color
  pdf.fill
  pdf.fill_color white
  pdf.text_box coa_name, at: [85, 369], size: 14, width: 70, overflow: :shrink_to_fit
  #TODO replace fix png with white rendered svg
  pdf.image './sources/metropolis_icon.png', at: [45, 378], height: 35

  #Contact
  pdf.fill_color white
  pdf.text_box "Contact #{login}:", size: 10, at: [10, 325] 
  pdf.text_box email, size: 10, at: [10, 310] 
  #TODO replace qr with user generated
  qrcode = RQRCode::QRCode.new("mailto:#{email}")
  png = qrcode.as_png(
    bit_depth: 1,
    border_modules: 1,
    color_mode: ChunkyPNG::COLOR_GRAYSCALE,
    color: "black",
    file: nil,
    fill: "white",
    module_px_size: 6,
    resize_exactly_to: false,
    resize_gte_to: false,
    size: 400
  )
  IO.binwrite("./qr_image.png", png.to_s)
  pdf.image "./qr_image.png", at: [20, 280], width: 160

  #Skills
  
  pdf.image "./spider_graph.png", at: [200, 270], width: 340
  


  #Address
  pdf.fill_color white
  pdf.text_box 'Distrito Telefónica - Edificio Norte 3', size: 8, at: [10, 50]
  pdf.text_box 'Ronda de la Comunicación, s/n', size: 8, at: [10, 40]
  pdf.text_box '28050 Madrid', size: 8, at: [10, 30]
  pdf.text_box 'España', size: 8, at: [10, 20]

  #Cleanup
  puts `rm ./temp_profile.jpg ./circle_profile*.png ./mask.png ./qr_image.png ./spider_graph.png`
end
