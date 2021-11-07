# Set input flags
declare -A arguments=();  
declare -A variables=();
declare -i index=1;
variables["-o"]="output_folder";  
variables["--output-folder"]="output_foler";  
variables["--include-pinniped-kubeconfigs"]="include_pinniped_kubeconfigs";
variables["--include-admin-kubeconfigs"]="include_admin_kubeconfigs";
variables["-h"]="help";
variables["--help"]="help";
for i in "$@"  
do  
  arguments[$index]=$i;
  prev_index="$(expr $index - 1)";
  if [[ $i == *"="* ]]
    then argument_label=${i%=*} 
    else argument_label=${arguments[$prev_index]}
  fi
  if [[ $i == "--help" ]]; then
    # print Help Menu and exit
    cat << EOF
Usage: get-tanzu-kubeconfigs.sh [OPTIONS]

Options:

[Mandatory Flags]
  -o / --output-folder : the folder path in which to place the generated kubeconfigs

[Optional Flags]
  --include-pinniped-kubeconfigs : Generate Pinniped Based Kubeconfigs (default: true)
  --include-admin-kubeconfigs : Generate the admin kubeconfigs (default: true)
  -h / --help : Show this help menu

EOF
    exit 1
  else
    if [[ -n $argument_label ]] ; then
      if [[ -n ${variables[$argument_label]} ]]
        then
            if [[ $i == *"="* ]]
                then declare ${variables[$argument_label]}=${i#$argument_label=}
              else declare ${variables[$argument_label]}=${arguments[$index]}
            fi
      fi
    fi
  fi
  index=index+1;
done;
# Validate Mandatory Flags were supplied
if ! [[ $output_folder ]]; then
  echo "Mandatory flags were not passed. use --help for usage information"
  exit 1
fi

# actual script
mkdir -p  $output_folder/per-cluster
mkdir -p  $output_folder/all-clusters
if [[ $include_pinniped_kubeconfigs ]]; then
  if [[ $include_pinniped_kubeconfigs == "false" || $include_pinniped_kubeconfigs == "no" ]]; then
    echo "Skipping Pinniped Kubeconfig Generation"
  else
    echo "Creating output directory for pinniped based kubeconfigs"
    mkdir -p $output_folder/per-cluster/no-browser
    mkdir -p $output_folder/per-cluster/with-browser
    pinniped="yes"
  fi
else
  echo "Creating output directory for pinniped based kubeconfigs"
  mkdir -p $output_folder/per-cluster/no-browser
  mkdir -p $output_folder/per-cluster/with-browser
  pinniped="yes"
fi

if [[ $include_admin_kubeconfigs ]]; then
  if [[ $include_admin_kubeconfigs == "false" || $include_admin_kubeconfigs == "no" ]]; then
    echo "Skipping Admin Kubeconfig Generation"
  else
    echo "Creating output directory for admin kubeconfigs"
    mkdir -p $output_folder/per-cluster/admin
    admin="yes"
  fi
else
  echo "Creating output directory for admin kubeconfigs"
  mkdir -p $output_folder/per-cluster/admin
  admin="yes"
fi

if [[ $admin == "yes" ]]; then
  tanzu cluster list -o json | jq -r .[].name | while read i; do tanzu cluster kubeconfig get --admin $i --export-file $output_folder/per-cluster/admin/$i-admin-kubeconfig 1>/dev/null 2>/dev/null; done
  tanzu cluster list -o json | jq -r .[].name | while read i; do tanzu cluster kubeconfig get --admin $i --export-file $output_folder/all-clusters/all-clusters-admin-kubeconfig 1>/dev/null 2>/dev/null; done
fi

if [[ $pinniped="yes" ]]; then
  tanzu cluster list -o json | jq -r .[].name | while read i; do TANZU_CLI_PINNIPED_AUTH_LOGIN_SKIP_BROWSER=false tanzu cluster kubeconfig get $i --export-file $output_folder/per-cluster/with-browser/$i-with-browser-kubeconfig 1>/dev/null; done 
  tanzu cluster list -o json | jq -r .[].name | while read i; do TANZU_CLI_PINNIPED_AUTH_LOGIN_SKIP_BROWSER=false tanzu cluster kubeconfig get $i --export-file $output_folder/all-clusters/all-clusters-with-browser-kubeconfig 1>/dev/null; done
  tanzu cluster list -o json | jq -r .[].name | while read i; do TANZU_CLI_PINNIPED_AUTH_LOGIN_SKIP_BROWSER=true tanzu cluster kubeconfig get $i --export-file $output_folder/per-cluster/no-browser/$i-no-browser-kubeconfig 1>/dev/null; done
  tanzu cluster list -o json | jq -r .[].name | while read i; do TANZU_CLI_PINNIPED_AUTH_LOGIN_SKIP_BROWSER=true tanzu cluster kubeconfig get $i --export-file $output_folder/all-clusters/all-clusters-no-browser-kubeconfig 1>/dev/null; done
fi

echo "All Kubeconfigs have been generated and can be found under the folder $output_folder. Happy Tanzuing!!!"
