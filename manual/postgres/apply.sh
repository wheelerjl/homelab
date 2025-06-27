#!/usr/bin/env bash
set -euo pipefail

echoerr() { echo "$@" 1>&2; }
fatal() { echoerr "$@"; exit 1; }
badopt() { echoerr "$@"; help='true'; }
opt() { if [[ -z ${2-} ]]; then badopt "$1 flag must be followed by an argument"; fi; export $1="$2"; }
required_args() { for arg in $@; do if [[ -z "${!arg-}" ]]; then badopt "$arg is a required argument"; fi; done; }

while [[ $# -gt 0 ]]; do
    arg="$1"
    case $arg in
        --cluster|-c) shift; opt cluster $1; shift;;
        --help|-h) opt help true; shift;;
        *) shift;;
    esac
done

if [[ -z ${help-} ]]; then
    required_args cluster
fi

if [[ -n ${help-} ]]; then
    echoerr "Usage: $0"
    echoerr "    -c, --cluster      The cluster name to apply the Rook Ceph helm chart to"
    echoerr "    -h, --help         Show this help message"
    exit 1
fi

# If cluster isn't set throw error
if [[ -z ${cluster-} ]]; then
    fatal "Cluster name is required. Use --cluster or -c to specify the cluster name."
fi

export KUBECONFIG=$(mktemp) && cp ~/.kube/config $KUBECONFIG && kubectl config set current-context $cluster

if ! helm repo list | grep -q 'https://charts.bitnami.com/bitnami'; then
    helm repo add bitnami https://charts.bitnami.com/bitnami
fi

helm upgrade --install --create-namespace --namespace postgres \
    --version 16.7.13 \
    --wait postgres bitnami/postgresql \
    --values values.yaml \
    --set "global.postgresql.auth.password=IZi6uL5rNzHwct" \
    --set "global.postgresql.auth.postgresPassword=M5GWlESwVdY6wD"
