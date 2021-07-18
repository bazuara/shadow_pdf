#!/usr/bin/env ruby

require "prawn"

green = '00babc'
#TODO Accent color based on coalition
accent = 'FF0000'
white = 'ffffff'
gray = '4E5566'
clear_gray = 'E7E7E7'

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
  #TODO: Round picture
  pdf.image "./sources/user.png", at: [50, 687.5], width: 100, height: 100
 
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
  pdf.text_box 'USER_NAME', styles: :bold, size: 22, at: [20, 570]
  pdf.text_box 'Rank: Grade', styles: :normal, size: 16, at: [20, 543]

  #Image on gray rectangle
  pdf.image "./sources/Logo-42.png", at: [10, 100], width: 175

  #Text on green rectangle
  #
  #Address
  pdf.text_box 'Distrito Telefónica - Edificio Norte 3', size: 8, at: [10, 50]
  pdf.text_box 'Ronda de la Comunicación, s/n', size: 8, at: [10, 40]
  pdf.text_box '28050 Madrid', size: 8, at: [10, 30]
  pdf.text_box 'España', size: 8, at: [10, 20]

end


#render pdf
#pdf.render_file 'assignment.pdf'
