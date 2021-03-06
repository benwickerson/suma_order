require 'csv'
require 'open-uri'
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
  input = ''
  STDOUT.puts "User password please:"
  input = STDIN.gets.chomp

  def id_find(class_name, to_find)
    thing = (class_name.camelize.constantize).find_by_name(to_find)
    if thing != nil
      return thing.id
    else
      return nil
    end
  end

# category_name[0], brand[1], code[2], description[3], details[4], size[5], price[6], vat[7], rrp[8], b[9], f[10], g[11], o[12], s[13], v[14] 
  STDOUT.puts "Creating base data from CurrentSumaPrices.csv. . . "
  suma_csv = open('http://www.suma.coop/downloads/CurrentSumaPrices.csv')
  CSV.foreach(suma_csv, headers: true, quote_char: "\x00") do |row|
    row = BaseData.create({
      category_name:  row[0].titleize,
      brand:          row[1] != nil ? row[1].titleize : "No brand",
      code:           row[2].upcase,
      description:    row[3],
      details:        row[4],
      size:           row[5].downcase,
      price:          row[6].to_d,
      vat:            row[7],
      rrp:            row[8] != nil ? row[8].to_d : 0,
      b:              row[9] != nil ? true : false,
      f:              row[10] != nil ? true : false,
      g:              row[11] != nil ? true : false,
      o:              row[12] != nil ? true : false,
      s:              row[13] != nil ? true : false,
      v:              row[14] != nil ? true : false
      })
  end

  STDOUT.puts "Populating Category table. . ."
  BaseData.select("DISTINCT category_name").where("category_name IS NOT NULL").map(&:category_name).sort.each do |x|
    Category.create!(name: x)
  end

  STDOUT.puts "Populating Brand table. . ."
  BaseData.select("DISTINCT brand").where("brand IS NOT NULL").map(&:brand).sort.each do |x|
    Brand.create!(name: x)
  end

  STDOUT.puts "Populating Items table. . ."
  BaseData.all.each do |x|
    Item.create!(
              id: x.id, 
              code: x.code, 
              description: x.description,
              details: x.details, 
              size: x.size, 
              rrp: x.rrp, 
              price: x.price,
              category_id: id_find("category", x.category_name), 
              brand_id: id_find("brand", x.brand), 
              unit_price: x.size.match(/^\d+\sx?\s/) ? (x.price / x.size.to_i) : x.price,
              vat: case x.vat 
                when 1
                  0.2
                when 5
                  0.05
                else
                  0
              end
              )
  end

  STDOUT.puts "Calculating VAT prices . . ."
  Item.all.each do |i|
    i.price_inc_vat = i.price + ( i.price * i.vat )
    i.save
  end

  STDOUT.puts "Creating users . . ."
  User.create!( 
              name: "Ben Wickerson", 
              email: "ben.wickerson@gmail.com", 
              house_number: 30,
              street: "Bond Street",
              password: input, 
              password_confirmation: input, 
              admin: true,
              )
  User.create!( 
              name: "Flo Harrison", 
              email: "flo.harrison@uea.ac.uk", 
              house_number: 30,
              street: "Bond Street",
              password: input, 
              password_confirmation: input, 
              admin: false
              )

  STDOUT.puts "Creating an Order. . ."
  Order.create!(orderopen: Date.yesterday, deadline: Date.today, delivery: Date.tomorrow, order_sent: false, active_order: true)
  Order.create!(orderopen: 2.weeks.ago, deadline: 1.week.ago, delivery: 3.days.ago, order_sent: true)
