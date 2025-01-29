pipeline {
    agent any
    environment {
        PACKER_TEMPLATE = 'image-template.pkr.hcl' 
        REGION = 'us-east-1'
        AMI_ID = ''
    }
    stages {
        stage('Packer Init') {
            steps {
                echo 'Initializing Packer...'
                sh 'packer init .'
            }
        }
        stage('Validate Packer Template') {
            steps {
                echo 'Validating Packer template...'
                sh 'packer validate ${PACKER_TEMPLATE}'
            }
        }
        stage('Build Image and Capture AMI') {
            steps {
                script {
                    // Run Packer to build the AMI and capture the output
                    def buildOutput = sh(script: "packer build ${PACKER_TEMPLATE}", returnStdout: true).trim()
                    echo "Packer Build Output:\n${buildOutput}"

                }
            }
    }
    post {
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline execution failed. Check logs for details.'
        }
        always {
            echo 'Pipeline execution completed!'
        }
    }
}
}