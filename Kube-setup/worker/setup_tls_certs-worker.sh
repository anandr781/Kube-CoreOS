read -p "Enter the Eth device on which ETCD cluster runs : " eth_device
echo "Entered Eth device : " $eth_device
ipAdd="$( ifconfig $eth_device | grep "inet " | cut -d"t" -f2 | cut -d " " -f2 )"
export WORKER_LOCALHOST_IP ="$(echo $ipAdd)"
echo "The IP Addr : " $ipAdd 
export WORKER_LOCALHOST_NAME=$(hostname)



mkdir -P Worker-Keys
cd Worker-Keys
 
 cat <<EOF > worker-openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = $ENV::WORKER_LOCALHOST_IP
EOF

openssl genrsa -out ${WORKER_LOCALHOST_NAME}-worker-key.pem 2048
WORKER_IP=${WORKER_LOCALHOST_IP} openssl req -new -key ${WORKER_LOCALHOST_NAME}-worker-key.pem -out ${WORKER_LOCALHOST_NAME}-worker.csr -subj "/CN=${WORKER_LOCALHOST_NAME}" -config worker-openssl.cnf
WORKER_IP=${WORKER_LOCALHOST_IP} openssl x509 -req -in ${WORKER_LOCALHOST_NAME}-worker.csr -CA ../master/CA-Keys/ca.pem -CAkey ../master/CA-Keys/ca-key.pem -CAcreateserial -out ${WORKER_LOCALHOST_NAME}-worker.pem -days 365 -extensions v3_req -extfile worker-openssl.cnf


cp * /etc/kubernetes/ssl
cp ../master/CA-Keys/* /etc/kubernetes/ssl