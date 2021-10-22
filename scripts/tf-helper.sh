#!/bin/bash

set -eu

function usage() {
  echo "Usage $(basename $0) [-n NAME] [-r REFERENCES] [-d]" 2>&1
  echo "Run a backup or cleanup of a set of data."
  echo "    -d                Dry run. Do not execute the Terraform import commands."
  echo "    -n NAME           The name of the repository you wish to import into Terraform."
  echo "    -r REFERENCES     An autolink reference for the repository. Can be set multiple times."
  echo "                          A reference needs to include its ID and should have the following format: <name>:<id>."
  echo "                          Example:"
  echo "                              -r KCORE:99588 -r KOPS:99581 -r SE:99586"
  exit 1
}

function print_error() {
  RED='\033[0;31m'
  RESET='\033[0m'
  echo -e "${RED}$@\n${RESET}"
  usage
}

function execute() {
  echo -e "terraform import $@"

  if [ -z $dry_run ];
  then
    terraform import "$@"
  fi
}

dry_run=
autolink_references=()
optstring="dn:r:"
while getopts ${optstring} opt; do
  case ${opt} in
    d)
      dry_run=1
      ;;
    n)
      repo_name="${OPTARG}"
      normalized_repo_name=${repo_name/_/-}
      ;;
    r)
      autolink_references+=("${OPTARG}")
      ;;
    :)
      echo "Error: -${OPTARG} requires an argument."
      usage
      ;;
    \?)
      echo "Invalid option -$OPTARG" >&2
      usage
      ;;
    *)
      usage
      ;;
  esac
done

if [ -z $repo_name ]; then
    print_error "A repository name must be specified."
fi

module_name="module.${normalized_repo_name}"

execute "${module_name}".github_repository.repo "${repo_name}"

execute "${module_name}".github_branch.master "${repo_name}":master

execute "${module_name}".github_branch_default.default "${repo_name}"

execute "${module_name}".github_branch_protection.branch-protection-master "${repo_name}":master

for reference in ${autolink_references[@]}
do
    reference_parts=($(echo "${reference/:/ }"))
    execute "${module_name}".github_repository_autolink_reference.autolink_reference"[\"${reference_parts[0]}\"]" "${repo_name}"/"${reference_parts[1]}"
done
