# LTV Laravel uzdevums

## Servisi un to versijas

* Larvel v11.2.0
* Nginx 1.25.4
* PHP 8.2.17
* Mysql 8.0.36

## Pirms instalācijas prasības
Šīs ir prasības kas nepieciešamas lai skripts nostrādātu un sistēma tiktu uzstādīta.
1. Uzinstalēts **Git** lai var lejuplādēt skriptu un nepieciešamos konfigurācijas failus.
2. Uzstādīta konteineru vide **Docker** un **Docker-compose**

**Optimālais**
1. Linux lietotājs ( Ne root ), kurš ielikts docker un sudo grupās.

>Svarīgi ! Ja skriptu laiž root lietotājs tad nepieciešams izmantot useradd.sh skriptu lai izveidotu lietotāju un veiktu atlikušas darbības ar ne root lietotāju. Ja skriptu laiž ne root lietotājs tad useradd.sh nav nepieciešams un var laist install_lavarel.sh skriptu.



## Mapju struktūra

### Instalacijas faili ###
**Config** - Konfigurācijas faili, kuri tiks nolasīti laižot dokera konteinerus.
    
   * **mysql_my.cnf** - Mysql konfiguracijas fails kurš tiks sasaistīts ar datubāzes konteineru.
   * **nginx.conf** - Nginx konfiguracijas fails kurš tiks sasaistīts ar webservera konteineru.
   * **php_local.ini** - PHP konfiguracijas fails kurš tiks sasaistīts ar aplikācijas konteineru.

**useradd.sh** - Izveido jaunu ne root lietotāju un ievieto viņu sudo un docker grupā. Pēc skripta palaišanas tiek pārkopēti nepieciešamie faili uz jaunā lietotāja home direktoriju un notiek pieslēgšanās ar jauno lietotāju.

> useradd.sh nepieciešams izmantot, ja nav izveidots ne root linux lietotajs priekš aplikācijas izveides. Ja lietotajs jau ir izveidots tad šis skripts nav nepieciešams.

**changesitename.sh** - Skripts kas nomaina nginx konfigurācijā sitename. default = localhost

**laravel_instal.sh** - Šis skripts prasa ievadīt projekta nosaukumu, datubāzes paroli un webhook adresi. Pēc attiecīgo vērtību ievades tiek veiktas sekojošas darbības.

1. Tiek lejuplādēts laravel git projekts un linux lietotāja home mapē tiek izveidota projekta nosaukuma mape ar projekta failiem.
2. Nomainīts **.env.example** uz **.env** failu un automātiksi ievadīta nepieciešamā datubazes informācija.
3. Tiek izveidots jauns **docker-compose.yml** kurā tiek definēti 3 konteineri ar nepieciešamo informāciju. Webserveris, Datubaze un Laravel app konteineris kurš tiks izveidots izmantojot **Dockerfile**. Tiek izveidots arī bridge tīkls starp konteineriem un nepieciešamie diski.
4. Tiek izveidots jauns **Dockerfile** kurā norādīti nepieciešamie php paplašinājumi, pēdējā versija Composer, izveidots lietotājs kas varēs palaist Composer un Artisan komandas.
5. Tiek izveidots applikācijas konteiners un palaisti visi konteineri.
6. Pārbauda visus konteineri ir palaisti un attieciīgi izvada paziņojumu vai ir vai nav palaists.
7. Palaiž composer instalaciju jaunajā app containerī, ģenerē atslēgu un migrē datubāzi.
8. Kad viss ir pabeigts tad saņem informāciju par docker engine un ubuntu versiju un nosūta ziņojumu izmantojot webhook.

## Instalacija

### **Ja tiek izmantots root lietotājs**
1. Lejuplādē projektu no git repozitorija
```
git clone https://github.com/OviiWorks/ltv.git 
```
2. Ieiet mapē ltv
```
 cd ltv 
```
3. Palaiž useradd.sh skriptu lai izveidotu ne root lietotāju. 
```
./seradd.sh 
```
4. Palaiž changesitename.sh lai nomainītu sitename. ( **Ja grib testēt lokāli tad šis nav jālaiž jo default sitename ir localhost**).
```
./changesitename.sh
```
5. Sāk instalāciju izmantojot laravel_instal.sh failu. Ievada aplikacijas nosaukumu, mysql paroli un webhook adresi un sistēma tiks uzstādīta pāris minūšu laikā.
```
./laravel_instal.sh
 ```

### **Ja tiek izmantots jau esošais ne root lietotājs**

1.Pārbauda vai esošais lietotājs ir sudo un docker grupās.
```
groups
```
sistēmai būtu jaizvada šādi
``` 
sudo docker
``` 
Ja lietotajs nav šajās grupās tad ar **root** lietotāju japiešķir ne root lietotajam tiesības.
```console
sudo usermod -aG sudo lietotajvards
sudo usermod -aG docker lietotajvards
```

2. Lejuplādē projektu no git repozitorija
```
git clone https://github.com/OviiWorks/ltv.git 
```
2. Ieiet mapē ltv
```
 cd ltv 
```
4. Palaiž changesitename.sh lai nomainītu sitename. ( **Ja grib testēt lokāli tad šis nav jālaiž jo default sitename ir localhost**).
```
./changesitename.sh
```
5. Sāk instalāciju izmantojot laravel_instal.sh failu. Ievada aplikacijas nosaukumu, mysql paroli un webhook adresi un sistēma tiks uzstādīta pāris minūšu laikā.
```
./laravel_instal.sh
 ```

 ### Vēlamais rezultāts
Ja instalacija notikursi veiksmīgi tad atverot adresi http://localhost vai ja izmantots 4. punkts tad atver adresi http://noraditamajaslapasadrese un būtu jāatveras Lavarel welcome page.
Kā arī būtu jāsaņem caur webhook ubuntu un docker engine versijas.

## Papildus informācija
### Webhook
Priekš testa var izmantot šo webhook adresi 
```
https://webhook.site/d2a5c559-914a-46e5-a3e8-c6eae2e0537f
```

un rezultātu redzēt 


https://webhook.site/#!/view/d2a5c559-914a-46e5-a3e8-c6eae2e0537f/07e27748-e273-4745-a463-d2844270bcb7/1
