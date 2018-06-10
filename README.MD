Kube-CoreOS 

This project attempts to automate the deployment of a Kubernetes cluster by overriding the generic multinode scripts provided by  CoreOS and makes the execution interactive for setting up a K8s 1.5.4 cluster

CoreOS Reference : https://coreos.com/kubernetes/docs/1.5.4/getting-started.html

Folders:
1. master - This is the controller node setup  scripts . There will be setup where CA certs are committed back into GIT (need to change it to Vault based)
2. worker - This is the worker node setup scripts
3. kubectl - Setup of Kubectl tool on master node (preferrable , else some overrides might be needed to handle the availability of CA - TLS assets)
4. docs - Some documents
