#!/usr/bin/env bash
set -e
curDir="$(pwd)"
ctxDir="$1"
kubeCtx=""
while [[ !("$ctxDir" -ef "$curDir") ]]; do
  if [ -f "${ctxDir}/.ctx" ];
  then
    kubeCtx="$(cat "${ctxDir}/.ctx")"
    ctxDir=$curDir
  else
    ctxDir="$(dirname $ctxDir)";
  fi
done
if [[ "$kubeCtx" != "$(kubectl config current-context)" && "$kubeCtx" != "" ]]; then
  kubectl config use-context "$kubeCtx"
fi
