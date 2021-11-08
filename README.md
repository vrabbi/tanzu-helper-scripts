# Carvel Packaging Scripts
In this folder you can find some helpful useful scripts to help with carvel packaging
## get-package-default-values.sh
this script utilizes yamlpath (pip3 install yamlpath), jq (apt install jq) and tanzu CLI to generate a default values.yaml for a specified package + version
### Example Usage
``` bash
./get-package-default-values.sh --package-name contour.community.tanzu.vmware.com --package-version 1.18.1 --values-file contour-default-values.yaml
```  

## get-tanzu-kubeconfigs.sh
This script utilizes The Tanzu CLI and jq to automate the extraction of all kubeconfigs in 3 modes:
1. admin kubeconfig
2. regular pinniped kubeconfig
3. browserless pinniped kubeconfig - useful in jumpbox scenarios
  
all kubeconfigs are generated as seperate files as well as a centeralized kubeconfig for each mode with all managed cluster within it.  
this allows for both sharing singular kubeconfigs with dedicated teams as well as sharing central kubeconfigs with your cluster admins.
  
### Example Usage
``` bash
./get-tanzu-kubeconfigs.sh -o /tmp/kubeconfigs
```
