pipeline {
    agent any
    environment {
        PACKER_TEMPLATE = 'image-template.pkr.hcl' 
        REGION = 'us-east-1'
        ACCOUNT_ID = '796973478257'
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

                    // Extract the AMI ID from the Packer build output
                    def amiId = buildOutput.split("\n").find { it.contains("us-east-1: ami-") }
                                             .split(":").last().trim()
                    echo "Captured AMI ID: ${amiId}"

                    // Save the AMI ID as an environment variable for the next stage
                    env.AMI_ID = amiId
                }
            }
        }
        stage('Share AMI') {
            steps {
                script {
                    // Share the AMI with the second account
                    sh """
                        aws ec2 modify-image-attribute --image-id ${env.AMI_ID} --launch-permission 'Add=[{UserId=${ACCOUNT_ID}}]' --region ${REGION}
                    """
                }
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
