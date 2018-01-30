#!/usr/bin/ruby

require 'optparse'
require 'savon'
require 'sqlite3'
require 'io/console'
require 'open-uri'

def internet_connection?
  begin
    true if open('https://carcontrol.o2.cz/')
  rescue
    false
  end
end

def format_time(time)
  seconds = time % 60
  minutes = (time / 60) % 60
  hours = (time / 3600)
  hours.to_s + ':' + format('%02d', minutes.to_s) + ':' + format('%02d', seconds.to_s)
end

unless internet_connection?
  puts 'Zkontrolujte připojení k Internetu.'
  exit
end

options = { name: 'AA', pass: nil, from: (Date.today - 30).strftime('%d.%m.%Y'), to: Date.today.strftime('%d.%m.%Y') }
parser = OptionParser.new do |opts|
  opts.banner = 'použití cc.rb [možnosti]:'
  opts.on('-o', '--od od', 'Datum od (dd.mm.rrrr)') do |from|
    options[:from] = from
  end
  opts.on('-d', '--do do', 'Datum do (dd.mm.rrrr)') do |to|
    options[:to] = to
  end
  opts.on('-h', '--help', 'Zobrazit nápovědu') do
    puts 'Při nevyplnění uživatelského jména se použije testovací účet.'
    puts 'Službu lze volat 1x za 5 minut.'
    puts opts
    exit
  end
end
parser.parse!

print 'Uživatelské jméno: '
options[:name] = STDIN.gets.chomp
print 'Heslo: '
options[:pass] = STDIN.noecho(&:gets).chomp
if options[:name].empty?
  options[:name] = 'TestStandard'
  options[:pass] = 'Test.123'
end

client = Savon.client(wsdl: 'https://carcontrol.o2.cz/ssl/Export.asmx?WSDL')
db = SQLite3::Database.new 'cc.db'
db.results_as_hash = true

db.execute('drop table if exists Jizdy')
db.execute <<-SQL
  create table Jizdy (
    vozidlo_spz varchar(20),
    vyjezd_datum datetime,
    prijezd_datum datetime,
    mista varchar(300),
    ucel varchar(300),
    ridic varchar(50),
    delka_osobni double,
    delka_firemni double,
    delka double,
    tachometr double,
    pocet_projetych_sekund int
  );
SQL

params_keys = %w[datum_od datum_do vozidlo_id gps]
params_values = [options[:from], options[:to], '0', '1']

response = client.call(:generate_export, message: { 'login' => options[:name], 'password' => options[:pass], 'language' => 'cs', 'exportID' => 'export_kniha_jizd_zakladni_firma', 'paramKeys' => { 'string' => params_keys }, 'paramValues' => { 'string' => params_values } })

doc = response.doc
# doc = File.open('jizdy.xml') { |f| Nokogiri::XML(f) }

doc.xpath('//Table1').each do
  chyba = doc.xpath('//Chyba')
  puts "\n"
  puts chyba.text
  exit
end

doc.xpath('//Radky').each do |row|
  db.execute 'insert into Jizdy values ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )', [row.xpath('vozidlo_spz').text, row.xpath('vyjezd_datum').text, row.xpath('prijezd_datum').text, row.xpath('mista').text, row.xpath('ucel').text, row.xpath('ridic').text, row.xpath('delka_osobni').text, row.xpath('delka_firemni').text, row.xpath('delka').text, row.xpath('tachometr').text, row.xpath('pocet_projetych_sekund').text]
end

puts "\n\nVozidla:"
printf "%18s %15s %12s %12s %15s\n", 'SPZ', 'celkem km', 'firemní', 'osobní', 'tachometr'
db.execute('select SUM(delka) as delka, SUM(delka_osobni) as delka_osobni, SUM(delka_firemni) as delka_firemni, MAX(tachometr) as tachometr, vozidlo_spz from Jizdy group by vozidlo_spz').each do |row|
  printf "%18s %15.2f %12.2f %12.2f %15.0f\n", row['vozidlo_spz'].strip, row['delka'], row['delka_firemni'], row['delka_osobni'], row['tachometr']
end
puts "\n\nŘidiči:"
printf "%18s %15s %12s %12s %15s\n", 'řidič', 'celkem km', 'firemní', 'osobní', 'čas'
db.execute('select SUM(delka) as delka, SUM(delka_osobni) as delka_osobni, SUM(delka_firemni) as delka_firemni, MAX(tachometr) as tachometr, SUM(pocet_projetych_sekund) as cas, ridic from Jizdy group by ridic').each do |row|
  printf "%18s %15.2f %12.2f %12.2f %15s\n", row['ridic'].strip, row['delka'], row['delka_firemni'], row['delka_osobni'], format_time(row['cas'])
end

puts "\n\nSlužební jízdy v nepracovní den:"
db.execute("select delka_firemni, ridic, vozidlo_spz, vyjezd_datum, mista, pocet_projetych_sekund from Jizdy where strftime('%w', vyjezd_datum) in ('6','7') and delka_firemni>0").each do |row|
  vyjezd = Date.parse(row['vyjezd_datum'])
  printf "%s, %.2f km, %s, %s\n", row['ridic'].strip, row['delka_firemni'], vyjezd.strftime('%d.%m.%Y'), Time.at(row['pocet_projetych_sekund']).utc.strftime('%H:%M:%S')
  printf " - %s\n", row['mista'].strip
end
