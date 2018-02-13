cc.rb: Aplikace pro získání jízd z webové služby O2 Car Control, zpracování a výstup za vozidlo.
==============================================

Projekt do předmětu Ruby PV249.

CarControl
------

Aplikace získá přístup k webové službě O2 CarControl a stáhne jízdy které chybí do aktuálního data.


Před prvním spuštěním nezapomeňte na `bundle install`

Aplikaci spustíte příkazem `bundle exec thin start`
Ve webovém prohlížečí je aplikace dostupná na adrese http://localhost:3000

Vložte přihlašovací údaje (defaultní jsou předvyplněny). Poté dojde k dohrání jízd.

Vyberte vozidlo ze seznamu a stiskněte vybrat. Poté se zobrazí graf délky jízd za dny pro vybrané vozidlo.