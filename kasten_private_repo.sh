#!/bin/bash
newrepo=$2
ver=$1

n=`jq 'length' k10_$ver.json`
repo=(`jq '.[].repository' k10_$ver.json | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`)
image=(`jq '.[].image' k10_$ver.json | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`)
tag=(`jq '.[].tag' k10_$ver.json | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`)
for((i=0;i<$n;i++));do
	if [ ${repo[i]} == gcr.io/kasten-images ];
	then
		docker tag ${repo[i]}/${image[i]}:${tag[i]} $newrepo/${image[i]}:${tag[i]}
		docker push $newrepo/${image[i]}:${tag[i]}
	else
		docker tag ${repo[i]}/${image[i]}:${tag[i]} $newrepo/${image[i]}:k10-${tag[i]}
		docker push $newrepo/${image[i]}:k10-${tag[i]}
	fi
done
