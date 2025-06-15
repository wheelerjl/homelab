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
        --help|-h) opt help true; shift;;
        *) shift;;
    esac
done

if [[ -n ${help-} ]]; then
    echoerr "Usage: $0"
    echoerr "    --help"
    exit 1
fi

if ! command -v kind &> /dev/null; then
    echo "kind cli must be installed"; exit 1;
fi

KUBECONFIG=~/.kube/config

kind create cluster --config local-cluster.yaml

cat ~/.kube/config | sed 's/kind-local/local/g' > /tmp/config
cp /tmp/config ~/.kube/config
