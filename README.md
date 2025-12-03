# Introduction
This project aims to provide a real-time chat experience that's both scalable and secure. With a focus on modern technologies, we're building an application that's easy to use and maintain

## Detailed Workflow Description
<img width="2686" height="1807" alt="fullstackchatapp" src="https://github.com/user-attachments/assets/02a4bb08-f433-4bf8-8d3d-b9466f00aa89" />

`User Interaction`:
Users interact with the frontend application running in their browser. This includes actions like logging in, sending messages, and navigating through the chat interface.Frontend (React App):The frontend is responsible for rendering the user interface and handling user inputs.It communicates with the backend via HTTP requests (for RESTful APIs) and WebSocket connections (for real-time interactions).

`Backend (Node.js/Express + Socket.io)`:
The backend handles all the server-side logic.It processes API requests from the frontend to perform actions such as user authentication, message retrieval, and message storage.Socket.io is used to manage real-time bi-directional communication between the frontend and the backend. This allows for instant messaging features, such as showing when users are typing or when new messages are sent.

`MongoDB (Database)`:
MongoDB stores all persistent data for the application, including user profiles, chat messages, and any other relevant data.The backend interacts with MongoDB to retrieve, add, update, or delete data based on the requests it receives from the frontend.

## ✨ Features:
- Real-time Messaging: Send and receive messages instantly using Socket.io
- User Authentication & Authorization: Securely manage user access with JWT
- Scalable & Secure Architecture: Built to handle large volumes of traffic and data
- Modern UI Design: A user-friendly interface crafted with React and TailwindCSS
- Profile Management: Users can upload and update their profile pictures
- Online Status: View real-time online/offline status of users

## 🛠️ Tech Stack:
- Backend: Node.js, Express, MongoDB, Socket.io
- Frontend: React, TailwindCSS
- Containerization: Docker
- Orchestration: Kubernetes (planned)
- Web Server: Nginx
- State Management: Zustand
- Authentication: JWT
- Styling Components: DaisyUI

## 🔧 Prerequisites:
- Node.js (v14 or higher)
- Docker (for containerizing the app)
- Git (to clone the repository)

## Run Application using Docker Compose  🐳
1] Create the infrastructure using Terraform on AWS cloude :
1. Navigate to the backend directory:
```
cd backend     # Note: Replace your_jwt_secret_key with a strong secret key of your choice.

```
2. Create a .env file and add the following content (modify the values as needed):
```
MONGODB_URI=mongodb://mongoadmin:secret@mongodb:27017/dbname?authSource=admin
JWT_SECRET=your_jwt_secret_key
PORT=5001
```
3. Build & Run the Containers:
```
docker-compose up -d --build # Make sure replacing your own docker images
```
## Run Application using EKS Cluster and advance tools  ☸️ 
1. Clonning the repository
```
git clone https://github.com/nilesh-fatfatwale/fullstack-chatapp.git
```
2. go to terraform folder to build eks infrastruture and bastin host
```
cd terraform
```
3. before initializing the project install aws cli and get the IAM access key and secret key
```
sudo apt-get install unzip   # if you dont have unzip on your machine
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
4. create an user & give admin access for devlopment purpose and get the IAM credentials
<img width="1492" height="448" alt="image" src="https://github.com/user-attachments/assets/f2e995ae-2a97-4c71-ae3d-495a74fb832f" />

5. aws configure to local machine
```
 aws configure # put the access key and secret key 
```
6. create a ssh key
```
ssh-keygen # add key name to create key and replace the key in the ec2.tf 
```
7.terraform initialize the project 
```
terraform init # set the remote backend s3
```
8. terraform validate and plan before making actual changes
```
terraform validate && terraform plan
```
9. if everything fine lets create our infrastructure
```
terraform apply --auto-approve
```
it will takes 20-30 minutes to create the infrastructure

2] Building an CICD pipeline for building docker image and push to dockerHub 
1. Install Java and Jenkins and docker on bastinhost server
```
sudo apt update
sudo apt install fontconfig openjdk-21-jre
java -version

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins

sudo apt-get install docker.io   # install docker
```

2. start the jenkins and add jenkins on docker group
```
sudo usermod -aG docker Jenkins
```
3. get the password to login and create new user credential
go to this location `var/lib/Jenkins\secrets\initialAdminPassword`
```
cat var/lib/Jenkins\secrets\initialAdminPassword
```
1. Steps to implement the project:
- Go to Jenkins Master and click on Manage Jenkins --> Plugins --> Available plugins install the below plugins:
-- OWASP
-- SonarQube Scanner
-- Docker
-- Pipeline: Stage View
2. tool setup SonarQube and Owasp

3. Credential setup --> github,docker-hub,gmail,sonarqube token

4. create a new pipeline for docker build and push to docker hub
  
## Kubernetes & Argocd:
1. Install AWS Cli
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
aws configure
```
Setup out old aws key here as well
2. Kubectl
```
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
kubectl version --short --client
```
3. eksctl
```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
```
1. update kubeconfig
```
aws eks update-kubeconfig --name fullstack_chatapp --region <region>
```
1. Install and Configure ArgoCD
 1) Create argocd namespace
```
kubectl create namespace argocd
 ```
 3) Apply argocd manifest
```
 kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
 4) Make sure all pods are running in argocd namespace
```
watch kubectl get pods -n argocd
```
 5) Install argocd CLI
```
sudo curl --silent --location -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.4.7/argocd-linux-amd64
```
 6) Provide executable permission
```
sudo chmod +x /usr/local/bin/argocd
```
 7) Check argocd services
```
 kubectl get svc -n argocd
```
 8) Change argocd server's service from ClusterIP to LoadBalancer
```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```
 9) Confirm service is patched or not
```
kubectl get svc -n argocd
```
 10) Access it on browser, click on advance and proceed with
 11) Fetch the initial password of argocd server
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
Username: admin
Now, go to User Info and update your argocd password

12) change the username password
13) login argocd cli
```
argocd login <dns/ip:portnumber> --username admin
```
14) `argocd cluster list`
15) `kubectl config get-contexts`
16) `argocd cluster add <> --name fullstack_chatapp`
17) setup github repo
18) setup  application on argocd

## EKS Monitoring :
1. Install Helm Chart
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```
2. Add Helm Stable Charts for Your Local Client
```
helm repo add stable https://charts.helm.sh/stable
```
3. Add Prometheus Helm Repository
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```
4. Create Prometheus Namespace
```
kubectl create namespace prometheus
kubectl get ns
```
5. Install Prometheus using Helm
```
helm install stable prometheus-community/kube-prometheus-stack -n prometheus
```
6. Verify prometheus installation
```
kubectl get pods -n prometheus
```
7. Check the services file (svc) of the Prometheus
```
kubectl get svc -n prometheus
```
- Expose Prometheus and Grafana to the external world through LoadBalancer
```
kubectl edit svc stable-kube-prometheus-sta-prometheus -n prometheus
```
8. Verify service
```
kubectl get svc -n prometheus
```
9. Now,let’s change the SVC file of the Grafana and expose it to the outer world
```
kubectl edit svc stable-grafana -n prometheus
```
10. Check grafana service
```
kubectl get svc -n prometheus
```
11. Get a password for grafana
```
kubectl get secret --namespace prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
## Clean Up:
```
terraform destroy --aut0-approve
```



before argocd apply make sure add kind and name ins project argocd 
