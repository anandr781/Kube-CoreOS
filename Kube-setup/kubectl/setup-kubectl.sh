#Reference URL : https://coreos.com/kubernetes/docs/1.5.4/configure-kubectl.html

# First Download the Kubectl binary
curl -O https://storage.googleapis.com/kubernetes-release/release/v1.5.4/bin/linux/amd64/kubectl

# do your duty
chmod +x kubectl

# mv it into your PATH
mv kubectl /opt/bin/kubectl

read -p "Please provide the MASTER_HOSTIP"  master_ipAddr
export MASTER_HOST=$master_ipAddr

export CA_CERT='/etc/kubernetes/ssl/ca.pem'

mkdir -p Admin-Keys
cd Admin-Keys

openssl genrsa -out admin-key.pem 2048
openssl req -new -key admin-key.pem -out admin.csr -subj "/CN=kube-admin"
openssl x509 -req -in admin.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out admin.pem -days 365

mv * /etc/kubernetes/ssl

cd ..
rm -rf  Admin-Keys

export ADMIN_KEY='/etc/kubernetes/ssl/admin-key.pem'

export ADMIN_CERT='/etc/kubernetes/ssl/admin.pem'


kubectl config set-cluster default-cluster --server=https://${MASTER_HOST} --certificate-authority=${CA_CERT}
kubectl config set-credentials default-admin --certificate-authority=${CA_CERT} --client-key=${ADMIN_KEY} --client-certificate=${ADMIN_CERT}
kubectl config set-context default-system --cluster=default-cluster --user=default-admin
kubectl config use-context default-system