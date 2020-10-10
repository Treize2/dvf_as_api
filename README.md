# micro-API DVF

Ce projet implémente une API minimale pour requêter les données DVF de la DGFiP stockées dans une base locale postgresql.

## Installation des dépendances

Pour Debian/Ubuntu :

`sudo apt install -y postgis gcc`

Selon la version de Postgresql installée (9.6 sur Debian stretch, 11 sur Debian buster, ...) :

`sudo apt install -y postgresql-server-dev-<version>`

Pour trouver la version de Postgresql installée :

`ls /etc/postgresql`

Selon la version de Python installée :

`sudo apt install -y python<version>-dev`

(Optionnel) Installation de virtualenv pour isoler l'installation du sytème :

```
sudo apt install -y virtualenvwrapper
source /etc/bash_completion.d/virtualenvwrapper
mkvirtualenv -p $(which python3) dvf_as_api
workon dvf_as_api
setvirtualenvproject
```

Installation des dépendances Python :

`pip install -r requirements.txt`

## Configuration de la base de données

Création d'un role et de la base de données :

```
export PASSWORD=$(apg -a 1 -M n -n 1 -m 8)
export DBNAME=dvf_as_api_db
export DBUSER=dvf_as_api_user

echo "127.0.0.1:5432:$DBNAME:$DBUSER:$PASSWORD" >> ~/.pgpass
chmod 0600 ~/.pgpass
sudo -u postgres psql -c "CREATE ROLE $DBUSER WITH PASSWORD '$PASSWORD' LOGIN;"
sudo -u postgres psql -c "CREATE DATABASE $DBNAME WITH OWNER $DBUSER;"
sudo -u postgres psql $DBNAME -c "CREATE EXTENSION postgis;"
```
Pour effacer les données et repartir à 0 :

```
export DBNAME=dvf_as_api_db
export DBUSER=dvf_as_api_user

sudo -u postgres psql -c "DROP DATABASE $DBNAME;"
sudo -u postgres psql -c "CREATE DATABASE $DBNAME WITH OWNER $DBUSER;"
sudo -u postgres psql $DBNAME -c "CREATE EXTENSION postgis;"
```

## Chargement des données

Téléchargement des données :

`./dvf_download.sh`

Import des données dans postgresql :

`DBNAME=dvf_as_api_db DBUSER=dvf_as_api_user ./dvf_import.sh MILLESIME`

Exemple:  `DBNAME=dvf_as_api_db DBUSER=dvf_as_api_user ./dvf_import.sh 201910`

## Lancement du serveur

`gunicorn dvf_as_api:app -b 0.0.0.0:8888`

(Optionnel) Si l'installation a été faite dans un virtualenv :

`~/.virtualenvs/dvf_as_api/bin/gunicorn dvf_as_api:app -b 0.0.0.0:8888`

## Paramètres reconnus par l'API

*(les liens interrogent une version publique de l'API sur **api.cquest.org**, sans garantie de disponibilité)*

Sélection des transactions par commune, section, parcelle:
- code_commune: http://api.cquest.org/dvf?code_commune=89304
- section: http://api.cquest.org/dvf?section=89304000ZB
- numero_plan: http://api.cquest.org/dvf?section=89304000ZB0134

Le résultat est au format JSON.

Sélection par proximité géographique:
- distance de 100m: http://api.cquest.org/dvf?lat=48.85&lon=2.35&dist=100
- distance par défaut de 500m: http://api.cquest.org/dvf?lat=48.85&lon=2.35

Filtres possibles:
- nature_mutation: Vente, Expropriation, etc...
- type_local: Maison, Appartement, Local, Dépendance

Exemple de ventes de maisons sur une commune:

http://api.cquest.org/dvf?code_commune=89304&nature_mutation=Vente&type_local=Maison

