require 'spec_helper'
require 'app'
require 'database_helper'

require 'multi_json'

describe CCApp do
  include Rack::Test::Methods
  def app
    CCApp
  end

  def google_connection?
    begin
    true if open('https://google.com/')
    rescue
    false
    end
  end


  describe 'jízdy' do
    it 'měl by přidat jízdu' do
      pred = DatabaseHelper.all_jizdy.count
      jizda = DatabaseHelper.add_jizda(uzivatel: Time.now.getutc, vozidlo_spz: '1Y23456', vyjezd_datum: '22.1.2018 1:20:00', prijezd_datum: '22.1.2018 1:30:00', mista: 'Nikde', ucel: 'Služebka', ridic: '395927', delka_osobni: '0', delka_firemni: '50', delka: '50', tachometr: '60', pocet_projetych_sekund: '1800')
      po = DatabaseHelper.all_jizdy.count
      expect(po).to be > pred
    end

    it 'měl by ppřipojit k O2, pokud jede Internet' do
      expect(app.internet_connection?).to equal(google_connection?)
    end    
  end
end

