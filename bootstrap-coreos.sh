#!/bin/bash

#################  MY VARIABLES (Don't proceed without changing this )#########################################
ETCD_CLUSTER_TOKEN="kube-cluster"
HOST_IP=$1
HOST_ETCD_NAME=$2
HOST_IP2=$3
HOST2_ETCD_NAME=$4
HOST_IP3=$5
HOST3_ETCD_NAME=$6
HOST_NAME=$7
ETCD_INITIAL_CLUSTER="$HOST_ETCD_NAME=http://$HOST_IP:2380,$HOST2_ETCD_NAME=http://$HOST_IP2:2380,$HOST3_ETCD_NAME=http://$HOST_IP3:2380"

#################  MY CONSTANTS (Don't change this unless you know what you're doing) ###########################


BOOTSTRAP_SCRIPT_PATH="/opt/bootstrap-coreos.sh"
BOOTSTRAP_URL="https://raw.githubusercontent.com/anandr781/Kube-CoreOS/master/bootstrap-coreos.sh" 


#################  MY FUNCTIONS  #########################################
# construct_kube-coreos-cluster-init_env () {
   # echo ''
   # mkdir -p "/etc/systemd/system/kube-coreos-cluster-init.service.d"
   # cd "/etc/systemd/system/kube-coreos-cluster-init.service.d"
   # cat << EOF > kube-coreos-cluster-init-env.env
# BOOTSTRAP_SCRIPT=$BOOTSTRAP_SCRIPT_PATH
# EOF
  
# }
# construct_flannel_env () {
  # echo 'setting env file for flannel -' $FLANNEL_IP_NETWORK_RANGE
  # mkdir -p "/etc/systemd/system/flanneld.service.d"
  # cd "/etc/systemd/system/flanneld.service.d"
  # cat << EOF > flanneld-env.env
# FLANNEL_IP_RANGE=$FLANNEL_IP_NETWORK_RANGE
# EOF

# }

construct_etcd-member_env () {
   echo 'setting env file for etcd -' $ETCD_INITIAL_CLUSTER
   mkdir -p "/etc/systemd/system/etcd-member.service.d"
   cd "/etc/systemd/system/etcd-member.service.d"	
   cat << EOF > etcd-member-env.env
ETCD_OPTS = --name=$HOST_ETCD_NAME  \
  --listen-peer-urls="http://0.0.0.0:2380"  \
  --listen-client-urls="http://$HOST_IP:2379,http://127.0.0.1:2379"  \
  --advertise-client-urls="http://$HOST_IP:2379"  \
  --initial-cluster="$ETCD_INITIAL_CLUSTER"  \
  --initial-cluster-state="new"  \
  --initial-cluster-token=$ETCD_CLUSTER_TOKEN
EOF
}

start_services () { 
  echo "Setting hostname = "$HOST_NAME 
  
  hostnamectl set-hostname $HOST_NAME
  echo "Restarting Daemon and services one by one"
  systemctl daemon-reload 
  systemctl restart etcd-member.service
  systemctl restart flanneld.service
  systemctl restart docker.service
  systemctl restart docker-tcp.socket 
}

begin_execution () {

  # construct flanneld env file
  # construct_kube-coreos-cluster-init_env
  
  # construct flanneld env file
  # construct_flannel_env

  # construct etcd-member env file 
  construct_etcd-member_env
  
  # start services
  echo "Do you wish to start the services from minimal config?"
  select yn in "Yes" "No"; do
    case $yn in
        Yes ) start_services ; break;;
        No ) exit;;
    esac
  done
     
}

download_bootstrap_script_and_retry () {
 
   curl -O $BOOTSTRAP_SCRIPT_PATH -L $BOOTSTRAP_URL
   if [ -x $BOOTSTRAP_SCRIPT_PATH ]; then
      chmod +x $BOOTSTRAP_SCRIPT_PATH
   fi
   begin_execution
}
##########################################################

# check if exists with executable permission -x switch

if [ -x "$BOOTSTRAP_SCRIPT_PATH" ];  then
   echo 'About to start execution since found '$BOOTSTRAP_SCRIPT_PATH
   begin_execution
 else
   echo 'Script '$BOOTSTRAP_SCRIPT_PATH ' not found'
   download_bootstrap_script_and_retry
fi
