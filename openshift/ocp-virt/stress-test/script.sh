#!/bin/bash
START_ID=41
END_ID=60

for ID in $(seq $START_ID $END_ID)
do
	echo $ID
	cp vm-template.yaml vm-template-$ID.yaml
	sed -i "s/ID/$ID/g" vm-template-$ID.yaml
	oc apply -f vm-template-$ID.yaml
	rm vm-template-$ID.yaml
done