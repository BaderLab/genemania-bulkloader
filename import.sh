#!/bin/bash

GENEMANIA_JAR=$1

mkdir temp
pushd temp

for f in ATTRIBUTES.txt ATTRIBUTE_GROUPS.txt ONTOLOGY_CATEGORIES.txt ONTOLOGIES.txt TAGS.txt NETWORK_TAG_ASSOC.txt INTERACTIONS.txt
do
    touch $f
done

cp ../Networks/* ./
cp ../batch.txt ../ids.txt  .

mkdir profiles
python ../process_networks.py batch.txt

popd

for PROFILE in temp/profiles/*.profile
do
    NETWORK_NAME="$(basename ${PROFILE} .profile)"
    ORGANISM="$(echo ${NETWORK_NAME} | cut -d . -f 1)"
    java -Xmx10G -cp ${GENEMANIA_JAR} org.genemania.engine.core.evaluation.ProfileToNetworkDriver -in "${PROFILE}" -out "temp/INTERACTIONS/${NETWORK_NAME}.txt" -proftype bin -cor PEARSON_BIN_LOG_NO_NORM -noHeader -syn temp/${ORGANISM}.synonyms -keepAllTies -limitTies -threshold off
done

mkdir dataset
pushd dataset

java -Xmx10G -cp ${GENEMANIA_JAR} org.genemania.mediator.lucene.exporter.Generic2LuceneExporter ../temp/db.cfg ../temp ../temp/colours.txt

mv lucene_index/* .
rmdir lucene_index

java -Xmx10G -cp ${GENEMANIA_JAR} org.genemania.engine.apps.CacheBuilder -cachedir cache -indexDir . -networkDir ../temp/INTERACTIONS

popd

cp genemania.xml dataset