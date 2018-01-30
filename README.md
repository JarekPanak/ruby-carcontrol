cc.rb: Aplikace pro získání jízd z webové služby O2 Car Control, zpracování a výstup za zvolené období.
==============================================

Projekt do předmětu Ruby PV249.

CarControl
------

Aplikace získá přístup k webové službě O2 CarControl a stáhne jízdy dle zadaného období.

Na výstupu zobrazí sumáře vozidel a řidičů. Pro účtování práce o víkendu také firemní jízdy v nepracovní den.

Vstupní parametry:

# Datum od kterého bude program načítat jízdy
cc.rb -o 1.1.2018 

# Datum do kterého bude program načítat jízdy
cc.rb -d 31.1.2018 


Před prvním spuštěním nezapomeňte na `bundle install`

