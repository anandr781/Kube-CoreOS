#! /bin/bash

# Create a Cluster Root CA - https://github.com/coreos/coreos-kubernetes/blob/master/Documentation/openssl.md#create-a-cluster-root-ca
mkdir -p CA-Keys
openssl genrsa -out CA-Keys/ca-key.pem 2048
openssl req -x509 -new -nodes -key CA-Keys/ca-key.pem -days 10000 -out CA-Keys/ca.pem -subj "/CN=kube-ca"

# Kubernetes API Server Key Pair - https://github.com/coreos/coreos-kubernetes/blob/master/Documentation/openssl.md#kubernetes-api-server-keypair
mkdir -p API-Server-Keys
cd API-Server-Keys 

cat <<EOF > openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
DNS.5 = k8s
DNS.6 = k8s.default
IP.1 = ${K8S_SERVICE_IP}
IP.2 = ${MASTER_HOST} 
EOF


