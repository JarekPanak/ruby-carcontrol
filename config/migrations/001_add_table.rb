Sequel.migration do
  change do
    create_table(:jizdy) do
      primary_key :id
      String :uzivatel, null: false
      String :vozidlo_spz, null: false
      Datetime :vyjezd_datum, null: false
      Datetime :prijezd_datum, null: false
      String :mista, null: false
      String :ucel, null: false
      String :ridic, null: false
      Double :delka_osobni, null: false
      Double :delka_firemni, null: false
      Double :delka, null: false
      Double :tachometr, null: false
      Integer :pocet_projetych_sekund, null: false
      unique [:uzivatel, :vozidlo_spz, :vyjezd_datum, :prijezd_datum]
    end
  end
end
