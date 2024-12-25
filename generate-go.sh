#!/usr/bin/env bash

usage(){
>&2 cat << EOF
Usage: $0 -p|--package NAME [-o|--out] PATH
Generate Go bindings for Aeon proto files.

Options:
  --package NAME: Go package name.
  --out PATH: Path to the output directory.
EOF
exit 1
}

VALID_ARGS=$(getopt -o p:o: --long package:,out: -- "$@")
if [[ $? -ne 0 ]]; then
    usage
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -p | --package)
        package=$2
        shift 2
        ;;
    -o | --out)
        out=$2
        shift 2
        ;;
    --) shift;
        break
        ;;
  esac
done

if [[ -z $package ]]
then
  usage
fi

if [[ -z $out ]]
then
  out=.
else
  mkdir -p $out
fi

proto_path=$(dirname $(readlink -f $0))
cmd="protoc --proto_path=$proto_path --go_out=$out --go-grpc_out=$out"
for file in ${proto_path}/*
do
  name=$(basename $file)
  if [[ $name = *.proto ]]
  then
    cmd="$cmd --go_opt=M${name}=$package --go-grpc_opt=M${name}=$package $name"
  fi
done

eval $cmd
