##! /bin/bash
DEFAULT_MILLESIME=2020-04

MILLESIME=${1:-$DEFAULT_MILLESIME}
CQUEST_MILLESIME=$(echo $MILLESIME|sed 's/-//g')

CURRENTYEAR=$(date +'%Y')

mkdir -p data
cd data

# Téléchargement des fichiers DVF
for ANNEE in $(seq 2014 $CURRENTYEAR)
do
  if [ $ANNEE -ne 2014 ]
  then
    if wget -q --method=HEAD http://data.cquest.org/dgfip_dvf/$CQUEST_MILLESIME/valeursfoncieres-$ANNEE.txt.gz;
    then
      wget -N http://data.cquest.org/dgfip_dvf/$CQUEST_MILLESIME/valeursfoncieres-$ANNEE.txt.gz;
    else
      wget -N http://data.cquest.org/dgfip_dvf/$CQUEST_MILLESIME/valeursfoncieres-$ANNEE.txt;
fi
  fi
  wget -N https://cadastre.data.gouv.fr/data/etalab-dvf/$MILLESIME/csv/$ANNEE/full.csv.gz -O $ANNEE-full.csv.gz
done
