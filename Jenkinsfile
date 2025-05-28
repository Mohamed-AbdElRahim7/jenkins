pipeline {
    agent {
        docker {
            image 'hashicorp/terraform:1.6.6' 
            args '-v /var/run/docker.sock:/var/run/docker.sock -u root'
        }
    }

    environment {
        TF_WORKING_DIR = 'terraform'
        ANSIBLE_WORKING_DIR = 'ansible'
        AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh '''
                    apk add --no-cache ansible openssh bash curl
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                dir(env.TF_WORKING_DIR) {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir(env.TF_WORKING_DIR) {
                    sh 'terraform apply -auto-approve -var="key_name=jenkins"'
                }
            }
        }

        stage('Get EC2 IP') {
            steps {
                dir(env.TF_WORKING_DIR) {
                    script {
                        env.EC2_IP = sh(returnStdout: true, script: 'terraform output -raw instance_ip').trim()
                        echo "EC2 Public IP: ${env.EC2_IP}"
                    }
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                sshagent(['jenkins']) {
                    dir(env.ANSIBLE_WORKING_DIR) {
                        sh """
                        ansible-playbook -i '${env.EC2_IP},' playbook.yml --private-key ~/.ssh/jenkins -u ec2-user
                        """
                    }
                }
            }
        }

        stage('Verify Script Execution') {
            steps {
                sh """
                echo 'Login to EC2 and verify: /home/ec2-user/hello_ansible.txt'
                """
            }
        }
    }
}
