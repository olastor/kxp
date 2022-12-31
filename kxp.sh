#!/bin/bash

function traverse () {
  tree="$1"
  IFS=$'\n'

  path="."
  for line in $tree; do
    name="$(echo "${line}" | xargs | cut -d' ' -f1)"
    space_count=$(echo "${line}" | grep -oP '^\s+' | wc -c)
    indent=$(( (space_count - 1) / 3 ))
    path="$(echo "${path}"| cut -d'.' -f"1-${indent}")"
    path="${path}.${name}"
    echo "${path:1}"
  done
}

resources="$(kubectl api-resources --no-headers=false -o name --sort-by='name')"
selected_resource="$(echo "${resources}" | fzf --preview='kubectl explain {}')"
kctl_explain_recursive="$(kubectl explain "${selected_resource}" --recursive=true)"
tree="$(echo "${kctl_explain_recursive}" | sed -n '/FIELDS:/,$p' | tail -n+2)"
path="$(traverse "${tree}" | fzf --preview="kubectl explain '${selected_resource}.{}'")"

if [[ -n "${path}" ]]; then
  kubectl explain "${selected_resource}.${path}"
fi
