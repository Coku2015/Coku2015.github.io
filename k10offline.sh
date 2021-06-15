#!/bin/bash
k10version=$1
newrepo=$2
sourcerepo=ccr.ccs.tencentyun.com/kasten

docker run --rm -it $sourcerepo/k10offline:$k10version list-images --json > k10.json
n=`jq 'length' k10.json`
repo=(`jq '.[].repository' k10.json | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`)
image=(`jq '.[].image' k10.json | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`)
tag=(`jq '.[].tag' k10.json | sed 's/.\(.*\)/\1/' | sed 's/\(.*\)./\1/'`)
for((i=0;i<$n;i++));do
        if [ ${repo[i]} == gcr.io/kasten-images ];
        then
                docker pull $sourcerepo/${image[i]}:${tag[i]}
                docker tag $sourcerepo/${image[i]}:${tag[i]} $newrepo/${image[i]}:${tag[i]}
                docker push $newrepo/${image[i]}:${tag[i]}
        else
                docker pull $sourcerepo/${image[i]}:k10-${tag[i]}
                docker tag $sourcerepo/${image[i]}:k10-${tag[i]} $newrepo/${image[i]}:k10-${tag[i]}
                docker push $newrepo/${image[i]}:k10-${tag[i]}
        fi
done

docker pull $sourcerepo/restorectl:$1
docker tag $sourcerepo/restorectl:$1 $newrepo/restorectl:$1
docker push $newrepo/restorectl:$1

