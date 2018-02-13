require 'config/database'
# Sequel cheat sheet:
# http://sequel.jeremyevans.net/rdoc/files/doc/cheat_sheet_rdoc.html
class DatabaseHelper
  class << self
    def all_jizdy
      DB[:jizdy].all
    end

    def get(id:)
      DB[:jizdy].where(id: id)
    end

    def get_vozidla(uzivatel:)
      DB[:jizdy].where(:uzivatel => uzivatel).select(:vozidlo_spz).distinct
    end

    def get_last(uzivatel:)
      DB[:jizdy].where(:uzivatel => uzivatel).max(:vyjezd_datum)
    end

    def get_jizdy(vozidlo_spz:)
      DB[:jizdy].where(:vozidlo_spz => vozidlo_spz)
    end

    def add_jizda(uzivatel:, vozidlo_spz:, vyjezd_datum:, prijezd_datum:, mista:, ucel:, ridic:, delka_osobni:, delka_firemni:, delka:, tachometr:, pocet_projetych_sekund:)
      DB[:jizdy].insert(:uzivatel => uzivatel, :vozidlo_spz => vozidlo_spz, :vyjezd_datum => vyjezd_datum, :prijezd_datum => prijezd_datum, :mista => mista, 
:ucel => ucel, :ridic => ridic, :delka_osobni => delka_osobni, :delka_firemni => delka_firemni, :delka => delka, :tachometr => tachometr, :pocet_projetych_sekund => pocet_projetych_sekund)
    end

  end
end
