
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
                    userRemoteConfigs: [[url: 'https://github.com/dhairyashild/java-source-code.git']]
                )
            }
        }
        stage("Build Project") {
            steps {
                // Build Maven project
                dir('/home/ubuntu/jenkins/workspace/springboot-project-pipeline-code/') {
                    sh 'mvn clean install'
                }
            }
        }
        stage("deploy") {
            steps {
                rtUpload (
                    serverId: 'jfrog-id',
                    spec: '''{
                          "files": [
                            {
                              "pattern": "/home/ubuntu/jenkins/workspace/springboot-project-pipeline-code/target/*.jar",
                              "target": "libs-snapshot-local"
                            }
                         ]
                    }''',

                    // Optional - Associate the uploaded files with the following custom build name and build number,
                    // as build artifacts.
                    // If not set, the files will be associated with the default build name and build number (i.e the 
                    // the Jenkins job name and number).
                    // buildName: 'holyFrog',
                    // buildNumber: '42',
                    // // Optional - Only if this build is associated with a project in Artifactory, set the project key as follows.
                    // project: 'my-project-key'
                )
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv(installationName: 'sonar') {
                    sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=java-project'
                }
            }
        } 
        stage('ecr push') {
            steps {
                dir('/home/ubuntu/jenkins/workspace/springboot-project-pipeline-code/java-springboot-code') {
                    sh 'aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/d8y1d3c0'
                    sh 'docker build -t spring-app .'
                    sh 'docker tag spring-app:latest public.ecr.aws/d8y1d3c0/spring-app:latest'
                    sh 'docker push public.ecr.aws/d8y1d3c0/spring-app:latest'
                }
            }
        }
        stage("clone-terraform-code") {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/dhairyashild/springboot-project-pipeline-code.git']])        
            }   
        }
        stage("terraform init") {
            steps {
                dir('CONTINEOUS-DEPLOYMENT') {
                    sh 'terraform init'
                }
            }
        }
        stage("terraform fmt") {
            steps {
                dir('CONTINEOUS-DEPLOYMENT') {
                    sh 'terraform fmt'
                }
            }
        }
        stage("terraform plan") {
            steps {
                dir('CONTINEOUS-DEPLOYMENT') {
                    sh 'terraform plan'
                }
            }
        }
        stage("terraform apply") {
            steps {
                dir('CONTINEOUS-DEPLOYMENT') {
                    sh 'terraform $ACTION --auto-approve'
                }
            }
        }
    }
}
