@Library('Shared') _

pipeline {
    agent any
    
    environment {
        SONAR_HOME = tool "Sonar"
        ECR_REGISTRY = "661596277003.dkr.ecr.us-east-1.amazonaws.com"
        AWS_REGION = "us-east-1"
    }
    
    parameters {
        string(name: 'Fullstack_Backend_Tag', defaultValue: 'latest', description: 'docker image tag for Fullstack_Backend')
        string(name: 'Fullstack_Frontend_Tag', defaultValue: 'latest', description: 'docker image tag Fullstack_Frontend')
    }
    
    stages {
        stage("Validate Parameters") {
            steps {
                script {
                    if (params.Fullstack_Backend_Tag == '' || params.Fullstack_Frontend_Tag == '') {
                        error("Fullstack_Backend_Tag and Fullstack_Frontend_Tag must be provided.")
                    }
                }
            }
        }

        stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Clone Repository') {
            steps {
                git url: "https://github.com/nilesh-fatfatwale/fullstack-chatapp.git", branch: "main"
            }
        }

        stage("SonarQube Analysis") {
            steps {
                script {
                    sonarqube_analysis("Sonar", "fullstack-chatapp", "fullstack-chatapp")
                    sonarqube_code_quality()
                }
            }
        }

        stage("Security Scans") {
            steps {
                script {
                    owasp_dependency()
                    trivy_scan()
                }
            }
        }

        stage('Build Docker Images') {
            parallel {
                stage('Build Backend') {
                    steps {
                        dir('backend') {
                            sh "docker build -f Dockerfile -t fullstack-chatapp-backend:${params.Fullstack_Backend_Tag} ."
                        }
                    }
                }
                stage('Build Frontend') {
                    steps {
                        dir('frontend') {
                            sh "docker build -f Dockerfile -t fullstack-chatapp-frontend:${params.Fullstack_Frontend_Tag} ."
                        }
                    }
                }
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: 'aws-ecr-creds',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    
                    script {
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                        
                        // Push Backend
                        sh "docker tag fullstack-chatapp-backend:${params.Fullstack_Backend_Tag} ${ECR_REGISTRY}/chatapp-backend:${params.Fullstack_Backend_Tag}"
                        sh "docker push ${ECR_REGISTRY}/chatapp-backend:${params.Fullstack_Backend_Tag}"
                        
                        // Push Frontend
                        sh "docker tag fullstack-chatapp-frontend:${params.Fullstack_Frontend_Tag} ${ECR_REGISTRY}/chatapp-frontend:${params.Fullstack_Frontend_Tag}"
                        sh "docker push ${ECR_REGISTRY}/chatapp-frontend:${params.Fullstack_Frontend_Tag}"
                    }
                }
            }
        }
    }

    post {
        success {
            emailext(
                attachLog: true,
                from: 'fatfatwalenilesh@gmail.com',
                to: 'nileshfatfatwale007@gmail.com',
                subject: "🚀 ChatAPP CI/CD SUCCESS - Build #${env.BUILD_NUMBER}",
                mimeType: 'text/html',
                body: """
                <html>
                <body style="font-family: Arial, sans-serif; background-color: #121212; color: #ffffff; padding: 20px;">
                    <h2 style="color: #4CAF50;">✅ BUILD SUCCESSFUL!</h2>
                    
                    <table style="width: 100%; max-width: 600px; border-collapse: collapse; color: white;">
                        <tr style="background-color: #1e2a1e;">
                            <td style="padding: 10px; border: 1px solid #333; font-weight: bold; width: 30%;">Project:</td>
                            <td style="padding: 10px; border: 1px solid #333;">${env.JOB_NAME}</td>
                        </tr>
                        <tr style="background-color: #1a242a;">
                            <td style="padding: 10px; border: 1px solid #333; font-weight: bold;">Build:</td>
                            <td style="padding: 10px; border: 1px solid #333;">#${env.BUILD_NUMBER}</td>
                        </tr>
                        <tr style="background-color: #1a243a;">
                            <td style="padding: 10px; border: 1px solid #333; font-weight: bold;">Status:</td>
                            <td style="padding: 10px; border: 1px solid #333; color: #4CAF50; font-weight: bold;">SUCCESS</td>
                        </tr>
                        <tr style="background-color: #2a2a1a;">
                            <td style="padding: 10px; border: 1px solid #333; font-weight: bold;">Images:</td>
                            <td style="padding: 10px; border: 1px solid #333;">
                                Backend: chatapp-backend:${params.Fullstack_Backend_Tag}<br>
                                Frontend: chatapp-frontend:${params.Fullstack_Frontend_Tag}
                            </td>
                        </tr>
                        <tr style="background-color: #2a1a1a;">
                            <td style="padding: 10px; border: 1px solid #333; font-weight: bold;">Build URL:</td>
                            <td style="padding: 10px; border: 1px solid #333;"><a href="${env.BUILD_URL}" style="color: #6495ED;">View Console</a></td>
                        </tr>
                    </table>
                    
                    <p style="margin-top: 20px;">Images pushed to AWS ECR successfully! 🎉</p>
                </body>
                </html>
                """
            )
        }
    }
}