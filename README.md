# LTV Laravel projekts

## Šajā projektā

- [Servisi un to versijas](#heading-1)
- [Mapju struktūra](#heading-2)
  - [Instalacijas faili](#subheading-21)
  - [Pēcinstalacijas faili](#subheading-22)
- [Instalacija](#heading-3)

## Servisi un to versijas

* Larvel v11.2.0
* Nginx 1.25.4
* PHP 8.2.17
* Mysql 8.0.36

## Mapju struktūra

### Instalacijas faili ###
**Config** - Konfigurācijas faili, kuri tiks nolasīti laižot dokera konteinerus.
    
   * **mysql_my.cnf** - Mysql konfiguracijas fails kurš tiks sasaistīts ar datubāzes konteineru.
   * **nginx.conf** - Nginx konfiguracijas fails kurš tiks sasaistīts ar webservera konteineru.
   * **php_local.ini** - PHP konfiguracijas fails kurš tiks sasaistīts ar aplikācijas konteineru.

**useradd.sh** - Izveido jaunu ne root lietotāju un ievieto viņu sudo un docker grupā. Pēc skripta palaišanas tiek pārkopēti nepieciešamie faili uz jaunā lietotāja home direktoriju un tiek nomainīts jaunais lietotājs.

> useradd.sh nepieciešams izmantot, ja nav izveidots ne root linux lietotajs priekš aplikācijas izveides. Ja lietotajs jau ir izveidots tad šis skripts nav nepieciešams.

**laravel_instal.sh** - Šis skripts prasa ievadīt projekta nosaukumu, datubāzes paroli un webhook adresi. Pēc attiecīgo vērtību ievades tiek veiktas sekojošas darbības.

1. Tiek lejuplādēts laravel git projekts un linux lietotāja home mapē tiek izveidota projekta nosaukuma mape ar projekta failiem.
2. Nomainīts **.env.example** uz **.env** failu un automātiksi ievadīta nepieciešamā datubazes informācija.
3. Tiek izveidots jauns **docker-compose.yml** kurā tiek definēti 3 konteineri ar nepieciešamo informāciju. Webserveris, Datubaze un Laravel app konteineris kurš tiks izveidots izmantojot **Dockerfile**. Tiek izveidots arī bridge tīkls starp konteineriem un nepieciešamie diski.
4. Tiek izveidots jauns **Dockerfile** kurā norādīti nepieciešamie php paplašinājumi, pēdējā versija Composer, izveidots lietotājs kas varēs palaist Composer un Artisan komandas.
5. Tiek izveidots applikācijas konteiners un palaisti visi konteineri.
6. Pārbauda visus konteineri ir palaisti un attieciīgi izvada paziņojumu vai ir vai nav palaists.
7. Palaiž composer instalaciju jaunajā app containerī, ģenerē atslēgu un migrē datubāzi.
8. Kad viss ir pabeigts tad saņem informāciju par docker engine un ubuntu versiju un nosūta ziņojumu izmantojot webhook.
