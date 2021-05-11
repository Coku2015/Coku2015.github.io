#!/usr/bin/env bash

# COLOR CONSTANTS
GREEN='\033[0;32m'
LIGHT_BLUE='\033[1;34m'
RED='\033[0;31m'
NC='\033[0m'

readonly -a REQUIRED_TOOLS=(
    kubectl
    helm
)

MIN_HELM_VERSION="3.0.0"
MIN_K8S_VERSION="1.12.0"
MIN_K10_VERSION="2.5.12"
HELM_VERSION_3="3.0.0"

helpFunction()
{
   echo ""
   echo "This scripts runs the K10Primer image as a Job the cluster"
   echo "Usage: $0 -i image -n namespace -s storageclass -c command"
   echo -e "\t-i The K10Primer image"
   echo -e "\t-n The kubernetes namespace where the job will run"
   echo -e "\t-s The storage class to use when running the K10Primer CSI checker tool"
   echo -e "\t-c The command to use when running the K10Primer CSI checker tool. Will overide (-s) option"
   echo -e "\t-d The docker config secret name to pull docker images from a private repository"
   exit 1 # Exit script after printing help
}

while getopts "i:n:s:c:d:" opt
do
   case "$opt" in
      i ) image="$OPTARG" ;;
      n ) namespace="$OPTARG" ;;
      s ) storageclass="$OPTARG" ;;
      c ) commandin="$OPTARG" ;;
      d ) secretName="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

if [ -z "$namespace" ]
then
   echo "Namespace option not provided, using default namespace";
   namespace=default
fi

if [ -z "$storageclass" ]
then
   command=""
else
   command="storage csi-checker -s ${storageclass}"
fi

if [ -n "$commandin" ]
then
   command="${commandin}"
fi

if [ -z "$secretName" ]
then
   imagePullSecret=""
else
   imagePullSecret="imagePullSecrets:
- name: ${secretName}"
fi

print_heading() {
    printf "${LIGHT_BLUE}$1${NC}\n"
}

print_error(){
    printf "${RED}$1${NC}\n"
}

print_success(){
    printf "${GREEN}$1${NC}\n"
}

check_tools() {
  print_heading "Checking for tools"
  for tool in "${REQUIRED_TOOLS[@]}"
  do
    if ! command -v "${tool}" > /dev/null 2>&1
    then
      print_error " --> Unable to find ${tool}"
      failed=1
    else
      print_success " --> Found ${tool}"
    fi
  done
}

version_gt_eq() {
  local sorted_version=$(printf '%s\n' "$@" | sort -V | head -n 1)
  if [[ "${sorted_version}" != "$1" || "${sorted_version}" = "$2" ]]; then
    return 0
  fi
  return 1
}

check_kubectl_access() {
  print_heading "Checking access to the Kubernetes context $(kubectl config current-context)"
  if [[ $(kubectl get ns ${namespace}) ]]; then
    print_success " --> Able to access the ${namespace} Kubernetes namespace"
  else
    print_error " --> Unable to access the ${namespace} Kubernetes namespace"
    failed=1
  fi
}

check_helm_repo() {
  print_heading "Checking if the Kasten Helm repo is present"
  # The below shellcheck conflicts with pipefail
  # shellcheck disable=SC2143
  if [[ $(helm repo list | grep charts.kasten.io) ]]; then
    print_success " --> The Kasten Helm repo was found"
  else
    print_error " --> The Kasten Helm repo was not found"
    failed=1
  fi
}

check_helm_version() {
  print_heading "Checking for required Helm version (>= v${MIN_HELM_VERSION})"
  # Let's abort if this is Helm 3
  # run helm version command
  helm_version=$(helm version)
  if [ $? -ne 0 ]; then
    print_error " --> Error when running 'helm version'"
    failed=1
    return ${failed}
  fi

  helm_version=$(helm version --template "{{ .Version }}")
  if [[ ${helm_version} != "<no value>" ]]; then
      print_success " --> No Tiller needed with Helm ${helm_version}"
      return ${failed}
  fi
}

check_image() {
  print_heading "K10Primer image"
  if [ -z "$image" ]
  then
    if version_gt_eq ${helm_version:1} ${HELM_VERSION_3}; then
      k10ver=$(helm search repo kasten/k10 -o yaml | head -1 | awk '{print $3}')
    fi
    if version_gt_eq ${k10ver} ${MIN_K10_VERSION}; then
      image=ccr.ccs.tencentyun.com/kasten/k10tools:${k10ver}
    else
      print_error " --> K10 version derived from the Helm repo (${k10ver}) does not meet the minimum requirements (${MIN_K10_VERSION})"
      failed=1
    fi
  fi
  if [[ ${failed} -ne 1 ]]; then
    print_success " --> Using Image (${image}) to run test"
  fi
}

failed=0
helm_version=""
check_tools && check_helm_repo && check_helm_version && check_image && check_kubectl_access
if [[ ${failed} != 0 ]]; then
    print_error "Preflight checks failed"
    exit 1
fi

printf "\n"
print_heading "Running K10Primer Job in cluster with command- "
print_success "     ./k10tools primer ${command}"
cat > k10primer.yaml << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: k10-primer
  namespace: ${namespace}
${imagePullSecret}
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: k10-primer
subjects:
  - kind: ServiceAccount
    name: k10-primer
    namespace: ${namespace}
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: batch/v1
kind: Job
metadata:
  name: k10primer
  namespace: ${namespace}
spec:
  template:
    spec:
      containers:
      - image: ${image}
        imagePullPolicy: IfNotPresent
        name: k10primer
        command: [ "/bin/bash", "-c", "--" ]
        args: [ "./k10tools primer ${command}; sleep 2" ]
        env:
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
      restartPolicy: Never
      serviceAccount: k10-primer
  backoffLimit: 4
EOF

kubectl apply -f k10primer.yaml

trap "kubectl delete -f k10primer.yaml" EXIT

while [[ $(kubectl -n ${namespace} get pods --selector=job-name=k10primer -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]];
do echo "Waiting for pod $(kubectl -n ${namespace} get pods --selector=job-name=k10primer --output=jsonpath='{.items[*].metadata.name}') to be ready - $(kubectl -n ${namespace} get pods --selector=job-name=k10primer -o 'jsonpath={..status.containerStatuses[0].state.waiting.reason}')" && sleep 1;
done
echo "Pod Ready!"
echo ""
pod=$(kubectl -n ${namespace} get pods --selector=job-name=k10primer --output=jsonpath='{.items[*].metadata.name}')
kubectl logs -n ${namespace} ${pod} -f
echo ""
