#!/bin/bash

GENEMANIA_JAR=$1


mkdir temp
pushd temp

for f in ATTRIBUTES.txt ATTRIBUTE_GROUPS.txt ONTOLOGY_CATEGORIES.txt ONTOLOGIES.txt TAGS.txt NETWORK_TAG_ASSOC.txt INTERACTIONS.txt
do
    touch $f
done

cp ../Networks/* ./
cp ../batch_snp.txt ../ids.txt  .
python ../process_networks.py batch_snp.txt

popd

mkdir dataset
pushd dataset

java -Xmx10G -cp ${GENEMANIA_JAR} org.genemania.mediator.lucene.exporter.Generic2LuceneExporter ../temp/db.cfg ../temp ../temp/colours.txt

mv lucene_index/* .
rmdir lucene_index

java -Xmx10G -cp ${GENEMANIA_JAR} org.genemania.engine.apps.CacheBuilder -cachedir cache -indexDir . -networkDir ../temp/INTERACTIONS

popd

cp genemania.xml dataset
