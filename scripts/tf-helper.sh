#!/bin/bash

function usage() {
  echo "Usage $(basename $0) [-n NAME] [-r REFERENCES] [-d]" 2>&1
  echo "Run a backup or cleanup of a set of data."
  echo "    -d                Dry run. Do not execute the Terraform import commands."
  echo "    -n NAME           The name of the repository you wish to import into Terraform."
  echo "    -r REFERENCES     A semicolon (;) delimited list of autolink references for the repository."
  echo "                          A reference needs to include its ID and should have the following format: <name>:<id>."
  echo "                          Example:"
  echo "                              KCORE:99588;KOPS:99581;SE:99586"
  exit 1
}

function print_error() {
  RED='\033[0;31m'
  RESET='\033[0m'
  echo -e "${RED}$@\n${RESET}"
  usage
}

function token_quote {
  local quoted=()
  for token; do
    quoted+=( "$(printf '%q' "$token")" )
  done
  printf '%s\n' "${quoted[*]}"
}

function execute() {
  echo -e "$@"

  if [ -z $dry_run ];
  then
    IFS=$OLDIFS
    eval "$(token_quote $@)"
  fi
}

OLDIFS=$IFS
IFS=';'

optstring="dn:r:"
while getopts ${optstring} opt; do
  case ${opt} in
    d)
      dry_run=1
      ;;
    n)
      repo_name="${OPTARG}"
      normalized_repo_name=$(echo $repo_name | tr '_' '-')
      ;;
    r)
      autolink_references="${OPTARG}"
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

base_import_command="terraform import module.${normalized_repo_name}"

repo_import_command="${base_import_command}.github_repository.repo ${repo_name}"
execute $repo_import_command

branch_import_command="${base_import_command}.github_branch.master ${repo_name}:master"
execute $branch_import_command

default_branch_import_command="${base_import_command}.github_branch_default.default ${repo_name}"
execute $default_branch_import_command

protection_import_command="${base_import_command}.github_branch_protection.branch-protection-master ${repo_name}:master"
execute $protection_import_command

for reference in $autolink_references
do
    # We could probably build up an array of commands, then iterate over that array
    # an execute those commands to avoid resetting IFS each iteration
    IFS=';'
    reference_parts=(`echo $reference | tr ':' ';'`)
    autolink_import_command="${base_import_command}.github_repository_autolink_reference.autolink_reference[\"${reference_parts[0]}\"] ${repo_name}/${reference_parts[1]}"
    execute $autolink_import_command
done
