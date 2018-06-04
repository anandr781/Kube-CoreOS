#! /bin/bash
 openssl genrsa -out CoreOS-2-worker-key.pem 2048
 WORKER_IP=10.0.1.9 openssl req -new -key CoreOS-2-worker-key.pem -out CoreOS-2-worker.csr -subj "/CN=CoreOS-2" -config worker-openssl.cnf
 WORKER_IP=10.0.1.9 openssl x509 -req -in CoreOS-2-worker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out CoreOS-2-worker.pem -days 365 -extensions v3_req -extfile worker-openssl.cnf
