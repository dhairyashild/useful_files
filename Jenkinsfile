pipeline {
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        region = "ap-south-1"
    }
    agent {
        label 'worker'
    }
    tools {
        maven "maven"
        // docker "docker"
    }
    stages {
        stage("Clone Repository") {
            steps {
                // Checkout code from Git
                checkout scmGit(
                    branches: [[name: '*/main']],
                    extensions: [],
                    userRemoteConfigs: [[url: 'https://github.com/dhairyashild/project-repo.git']]
                )
            }
        }
        stage("Build Project") {
            steps {
                // Build Maven project
                dir('/home/ubuntu/jenkins/workspace/springboot-project-pipeline-code/springboot-java-poject') {
                    sh 'mvn clean install'
                }
            }
        }
        stage("Run SonarQube Analysis") {
            steps {
                // Run SonarQube analysis
                dir('/home/ubuntu/jenkins/workspace/springboot-project-pipeline-code/springboot-java-poject') {
                    sh '''mvn clean verify sonar:sonar \
                        -Dsonar.projectKey=eks-proect \
                        -Dsonar.host.url=http://3.109.181.11:9000 \
                        -Dsonar.login=sqp_e31d168ec336fbd5dc5809022620b7d87e90637b'''
                }
            }
        }
        stage('Push Docker Image to ECR') {
            steps {
                // Push Docker image to ECR
                dir('/home/ubuntu/jenkins/workspace/springboot-project-pipeline-code/springboot-java-poject') {
                    sh 'aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/d8y1d3c0'
                    sh 'docker build -t spring-app .'
                    sh 'docker tag spring-app:latest public.ecr.aws/d8y1d3c0/spring-app:latest'
                    sh 'docker push public.ecr.aws/d8y1d3c0/spring-app:latest'
                }
            }
        }
        stage("Initialize Terraform") {
            steps {
                // Initialize Terraform
                dir('continuous-deployment') {
                    sh 'terraform init'
                }
            }
        }
        stage("Format Terraform Files") {
            steps {
                // Format Terraform files
                dir('continuous-deployment') {
                    sh 'terraform fmt'
                }
            }
        }
        stage("Generate Terraform Plan") {
            steps {
                // Generate Terraform plan
                dir('continuous-deployment') {
                    sh 'terraform plan'
                }
            }
        }
        stage("Apply Terraform Changes") {
            steps {
                // Apply Terraform changes
                dir('continuous-deployment') {
                    sh 'terraform apply --auto-approve'
                }
            }
        } 
        stage("Set Kubernetes Context") {
            steps {
                // Set Kubernetes context
                sh 'aws eks update-kubeconfig --region ap-south-1 --name my-cluster'
                sh 'kubectl create namespace workshop'
            }
        }
        stage('Create IAM Service Account') {
            steps {
                // Create IAM service account
                sh 'curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json'
                sh 'aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json'
                sh 'eksctl utils associate-iam-oidc-provider --region=ap-south-1 --cluster=my-cluster --approve'
                sh 'eksctl delete iamserviceaccount --cluster=my-cluster --namespace=kube-system --name=aws-load-balancer-controller --region=ap-south-1 --override-existing-serviceaccounts'
                sh 'eksctl create iamserviceaccount --cluster=my-cluster --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::103849455660:policy/AWSLoadBalancerControllerIAMPolicy --approve --override-existing-serviceaccounts --region=ap-south-1'
            }
        }
        stage("Install AWS Load Balancer Controller") {
            steps {
                // Install AWS load balancer controller
                sh 'sudo snap install helm --classic'
                sh 'helm repo add eks https://aws.github.io/eks-charts'
                sh 'helm repo update eks' 
                sh 'helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=my-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller'
                sh 'kubectl get deployment -n kube-system aws-load-balancer-controller'
                sh 'kubectl apply -f kubernates_manifest'
            }
        } 
    }
}
