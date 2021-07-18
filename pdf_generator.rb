#!/usr/bin/env ruby

require "prawn"

green = '00babc'
#TODO Accent color based on coalition
accent = 'FF0000'
white = 'ffffff'
gray = '4E5566'
clear_gray = 'E7E7E7'
dark_grey = '000000'

#API replacement variables
user_name = 'user_name'.upcase
rank = 'Cadet'
current_level = '5'
percent_level = '45'
url_pic = "https://cdn.intra.42.fr/users/bazuara.jpg"


Prawn::Document.generate('assignment.pdf') do |pdf|
#generate new rectangle [postition], w, h

  #green rectangle
  pdf.rectangle [0, 720], 200, 225
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
  #TODO: Round centered picture
  puts `wget #{url_pic} -O temp_profile.jpg`
  pdf.image "./temp_profile.jpg", at: [50, 687.5], width: 100
  puts `rm ./temp_profile.jpg`
  #TODO: replace get image and delete image with ruby methods
 
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
  pdf.text_box user_name, styles: :bold, size: 22, at: [20, 570]
  pdf.text_box 'Rank: ' + rank, styles: :normal, size: 16, at: [20, 543]

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

  #Address
  pdf.fill_color white
  pdf.text_box 'Distrito Telefónica - Edificio Norte 3', size: 8, at: [10, 50]
  pdf.text_box 'Ronda de la Comunicación, s/n', size: 8, at: [10, 40]
  pdf.text_box '28050 Madrid', size: 8, at: [10, 30]
  pdf.text_box 'España', size: 8, at: [10, 20]

end
