@Library('Shared') _

pipeline {
    agent any
    
    environment{
        SONAR_HOME = tool "Sonar"
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
                git url: "https://github.com/nilesh-fatfatwale/fullstack-chatapp.git",
                branch: "main"
            }
        }

        stage("SonarQube: Code Analysis"){
            steps{
                script{
                    sonarqube_analysis("Sonar","fullstack-chatapp","fullstack-chatapp")
                }
            }
        }
        
        stage("SonarQube: Code Quality Gates"){
            steps{
                script{
                    sonarqube_code_quality()
                }
            }
        }

        stage("OWASP: Dependency check"){
            steps{
                script{
                    owasp_dependency()
                }
            }
        }


        stage('Build Docker Images') {
            parallel {

                stage('Build backend Image') {
                    steps {
                        script {
                            withCredentials([
                                usernamePassword(
                                    credentialsId: 'DockerHub',
                                    usernameVariable: 'dockerUsername',
                                    passwordVariable: 'dockerPassword'
                                )
                            ]) {
                                docker_build_multi_env(
                                    dockerHubName: "${dockerUsername}",
                                    imageName: "fullstack-chatapp-backend",
                                    imageTag: "${Fullstack_Backend_Tag}",
                                    dockerfile: 'backend/Dockerfile',
                                    context: 'backend/'
                                )
                            }
                        }
                    }
                }

                stage('Build frontend Image') {
                    steps {
                        script {
                            withCredentials([
                                usernamePassword(
                                    credentialsId: 'DockerHub',
                                    usernameVariable: 'dockerUsername',
                                    passwordVariable: 'dockerPassword'
                                )
                            ]) {
                                docker_build_multi_env(
                                    dockerHubName: "${dockerUsername}",
                                    imageName: "fullstack-chatapp-frontend",
                                    imageTag: "${params.Fullstack_Frontend_Tag}",
                                    dockerfile: 'frontend/Dockerfile',
                                    context: 'frontend/'
                                )
                            }
                        }
                    }
                }

            }
        }

        stage('Security Scan with Trivy') {
            steps {
                script {
                    trivy_scan()
                }
            }
        }

        stage('Push Docker Images') {
            parallel {

                stage('Push Main backend Image') {
                    steps {
                        script {
                            withCredentials([
                                usernamePassword(
                                    credentialsId: 'DockerHub',
                                    usernameVariable: 'dockerUsername',
                                    passwordVariable: 'dockerPassword'
                                )
                            ]) {

                                sh "docker login -u ${dockerUsername} -p ${dockerPassword}"
                                sh "docker push ${dockerUsername}/fullstack-chatapp-backend:${params.Fullstack_Backend_Tag}"
                            }
                        }
                    }
                }

                stage('Push frontend Image') {
                    steps {
                        script {
                            withCredentials([
                                usernamePassword(
                                    credentialsId: 'DockerHub',
                                    usernameVariable: 'dockerUsername',
                                    passwordVariable: 'dockerPassword'
                                )
                            ]) {

                                sh "docker login -u ${dockerUsername} -p ${dockerPassword}"
                                sh "docker push ${dockerUsername}/fullstack-chatapp-frontend:${params.Fullstack_Frontend_Tag}"
                            }
                        }
                    }
                }

            }
        }

    }
}