require 'database_helper'
require 'multi_json'
require 'sinatra'
require 'savon'
require 'open-uri'
require 'chartkick'
require 'sinatra/contrib'

class CCApp < Sinatra::Base
  enable :sessions

  @chyba

  get '/' do
    if session[:username].nil?
      redirect '/login'
    else
      redirect '/vozidlo'
    end
  end

  get '/view' do
    @vozidlo = session[:vozidlo_spz]
    @uzivatel = session[:username]
    array = DB["SELECT strftime('%d.%m.%Y', vyjezd_datum) as datum, SUM(delka) as delka, MIN(vyjezd_datum) as vyjezd FROM jizdy where vozidlo_spz='#{@vozidlo}' group by datum order by vyjezd"]

    @data = array.collect{|i| [i[:datum],i[:delka]]}
    erb :view
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    session[:username] = params[:username]
    datum_od = (Date.today - 90).strftime('%d.%m.%Y')
    unless DatabaseHelper.get_last(uzivatel: 'TestStandard').nil?
      datum_od = Date.parse(DatabaseHelper.get_last(uzivatel: 'TestStandard')).strftime('%d.%m.%Y')
    end
    CCApp.update(params[:username], params[:password], datum_od)
    if @chyba.nil?
      redirect '/vozidlo'
    else
      erb :error
    end
  end

  get '/vozidlo' do
    if session[:username].nil?
      redirect '/login'
    else
      @uzivatel = session[:username]
      erb :vozidlo
    end
  end
  post '/vozidlo' do    
    session[:vozidlo_spz] = params[:vozidlo_spz]
    redirect '/view'
  end

  class << self
  def internet_connection?
    begin
    true if open('https://carcontrol.o2.cz/')
    rescue
    false
    end
  end

  def update(name, pass, od)
    unless internet_connection?
      @chyba = 'Zkontrolujte připojení k Internetu.'
      return
    end
    

    client = Savon.client(wsdl: 'https://carcontrol.o2.cz/ssl/Export.asmx?WSDL')

    params_keys = %w[datum_od datum_do vozidlo_id gps]
    params_values = [od, Date.today.strftime('%d.%m.%Y'), '0', '1']

    response = client.call(:generate_export, message: { 'login' => name, 'password' => pass, 'language' => 'cs', 'exportID' => 'export_kniha_jizd_zakladni_firma', 'paramKeys' => { 'string' => params_keys }, 'paramValues' => { 'string' => params_values } })

    doc = response.doc

    doc.xpath('//Table1').each do
      @chyba = doc.xpath('//Chyba')

      return
    end

    doc.xpath('//Radky').each do |row|
      begin
        DatabaseHelper.add_jizda(uzivatel: name, vozidlo_spz: row.xpath('vozidlo_spz').text, vyjezd_datum: row.xpath('vyjezd_datum').text, prijezd_datum: row.xpath('prijezd_datum').text, mista: row.xpath('mista').text, ucel: row.xpath('ucel').text, ridic: row.xpath('ridic').text, delka_osobni: row.xpath('delka_osobni').text, delka_firemni: row.xpath('delka_firemni').text, delka: row.xpath('delka').text, tachometr: row.xpath('tachometr').text, pocet_projetych_sekund: row.xpath('pocet_projetych_sekund').text)
      rescue
      end
    end
    return 'OK'
  end
  end
end
