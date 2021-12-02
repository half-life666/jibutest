#!/bin/bash

NAME_SPACE=backup-saas-system

if [ $# -lt 1 ]; then
    echo "need to input tenant ID"
    exit 1
fi

tenantID=$1

curl_request () {
    method=$1
    url=$2
    data=$3

    echo "executes: $1 $2 $3"

    if [ $1 == "GET" ] || [ $1 == "DELETE" ];then
        cmd="curl -X${method} $url --write-out '%{http_code}' --silent --output /dev/null"
    elif [ $1 == "POST" ] || [ $1 == "PUT" ];then
        cmd="curl -o /dev/null -s -w '%{http_code}\n' -H "Content-Type:application/json"  -X ${method} ${url} --data '${data}' "
    else
        echo "no supported method $1 yet."
        exit
    fi

    code=`eval $cmd`
    rc=$?
    if [ $rc -ne 0 ];then 
        echo "failed to execute $cmd, rc=$rc"
        exit 1
    fi

    if [ "${code}" -ne "200" ];then
        echo "failure, return code is $code for $1 $2 ..."
        exit 1
    fi 

    echo "completes(http code: ${code}): $1 $2 ..."
}

# 1. check ns
kubectl get ns ${NAME_SPACE}
if [ $? -ne 0 ];then
    kubectl create ns ${NAME_SPACE}
    if [ $? -ne 0 ];then
        echo "failed to create ns ${NAME_SPACE}"
        exit 1
    fi
fi

Host="http://127.0.0.1:31800"
APIRoot="/jibuapis/ys.jibudata.com/v1alpha1/tenants"

kubeconfig=`cat $HOME/.kube/qke.config | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\\\n/g'`
kubeconfig=`echo "${kubeconfig}" | sed -E 's/  /\\\\t/g'`

#echo $kubeconfig
clusterData=$(cat << EOF
{
   "apiVersion": "ys.jibudata.com/v1alpha1",
   "kind": "Cluster",
   "metadata": {
      "name": "${tenantID}-cluster"
   },
   "spec": {
        "tenant": "${tenantID}",
        "kubeconfig": "${kubeconfig}",
        "apiEndpoint": "https://139.198.168.5:6443"
   }
}
EOF
)

curl_request POST "${Host}${APIRoot}/${tenantID}/clusters" "${clusterData}"

exit 0
