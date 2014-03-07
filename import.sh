#!/bin/bash

WORKING_DIR=$1
GENEMANIA_JAR=$2

cd ${WORKING_DIR}

mkdir temp
pushd temp

for f in ATTRIBUTES.txt ATTRIBUTE_GROUPS.txt ONTOLOGY_CATEGORIES.txt ONTOLOGIES.txt TAGS.txt NETWORK_TAG_ASSOC.txt INTERACTIONS.txt
do
    touch $f
done

cp ../Networks/* ./
cp ../batch.txt ../ids.txt  .

python ../process_networks.py batch.txt

popd

mkdir dataset
pushd dataset

java -Xmx10G -cp ${GENEMANIA_JAR} org.genemania.mediator.lucene.exporter.Generic2LuceneExporter ../temp/db.cfg ../temp ../temp/colours.txt

mv lucene_index/* .
rmdir lucene_index

java -Xmx10G -cp ${GENEMANIA_JAR} org.genemania.engine.apps.CacheBuilder -cachedir cache -indexDir . -networkDir ../temp/INTERACTIONS

popd

cp genemania.xml dataset