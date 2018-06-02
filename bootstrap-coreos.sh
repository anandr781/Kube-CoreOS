#!/bin/bash

#################  MY VARIABLES (Don't proceed without changing this )#########################################
ETCD_NAME="etcd-kube-coreos" 
ETCD_CLUSTER_TOKEN="kube-cluster"
ETCD_INITIAL_CLUSTER="$ETCD_NAME=http://10.0.1.8:2380,$ETCD_NAME-2=http://10.0.1.9:2380,$ETCD_NAME-3=http://10.0.1.10:2380"

#################  MY CONSTANTS (Don't change this unless you know what you're doing) ###########################


BOOTSTRAP_SCRIPT_PATH = "/opt/bootstrap-coreos.sh"
FLANNEL_IP_NETWORK_RANGE = "10.10.0.0/16"
BOOTSTRAP_URL="https://raw.githubusercontent.com/anandr781/Kube-CoreOS/master/bootstrap-coreos.sh" 


#################  MY FUNCTIONS  #########################################
construct_kube-coreos-cluster-init_env () {
   if [ -x "$BOOTSTRAP_SCRIPT_PATH" ];
   mkdir -p "/etc/systemd/system/kube-coreos-cluster-init.service.d"
   cd "/etc/systemd/system/kube-coreos-cluster-init.service.d"
   cat << EOF > kube-coreos-cluster-init-env.env
BOOTSTRAP_SCRIPT=$BOOTSTRAP_SCRIPT_PATH
EOF
}
construct_flannel_env () {
  mkdir -p "/etc/systemd/system/flanneld.service.d"
  cd "/etc/systemd/system/flanneld.service.d"
  CAT << EOF > flanneld-env.env
FLANNEL_IP_RANGE=$FLANNEL_IP_NETWORK_RANGE
EOF
}

construct_etcd-member_env () {
   mkdir -p "/etc/systemd/system/etcd-member.service.d"
   cd "/etc/systemd/system/etcd-member.service.d"	
   CAT << EOF > etcd-member-env.env
ETCD_OPTS = --name=$ETCD_NAME  \
  --listen-peer-urls="http://0.0.0.0:2380"  \
  --listen-client-urls="http://10.0.1.8:2379,http://127.0.0.1:2379"  \
  --advertise-client-urls="http://10.0.1.8:2379,http://127.0.0.1:2379"  \
  --initial-advertise-peer-urls="http://10.0.1.8:2380"  \
  --initial-cluster="$ETCD_INITIAL_CLUSTER" \ 
  --initial-cluster-state="new"  \
  --initial-cluster-token=$ETCD_CLUSTER_TOKEN
EOF
}


begin_execution () {

  # construct flanneld env file
  construct_kube-coreos-cluster-init_env
  
  # construct flanneld env file
  construct_flannel_env

  # construct etcd-member env file 
  construct_etcd-member_env

}

download_bootstrap_script_and_retry () {
 
   curl -O $BOOTSTRAP_SCRIPT_PATH -L $BOOTSTRAP_URL
   if [ -x $BOOTSTRAP_SCRIPT_PATH ];
      chmod +x $BOOTSTRAP_SCRIPT_PATH
   fi
   begin_execution
}
##########################################################

# check if exists with executable permission -x switch
if [ -x "$BOOTSTRAP_SCRIPT_PATH" ];
 then
   echo 'About to start execution since found '$BOOTSTRAP_SCRIPT_PATH
   begin_execution
 else
   echo 'Script '$BOOTSTRAP_SCRIPT_PATH ' not found'
   download_bootstrap_script_and_retry
fi
