pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        TF_WORKING_DIR = 'terraform'
        ANSIBLE_WORKING_DIR = 'ansible'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Mohamed-AbdElRahim7/your-repo.git', branch: 'master'
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
                sshagent(['ec2-ssh-key']) {
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
                sshagent(['ec2-ssh-key']) {
                    sh "ssh -o StrictHostKeyChecking=no -i ~/.ssh/jenkins ec2-user@${env.EC2_IP} 'cat /home/ec2-user/hello_ansible.txt'"
                }
            }
        }
    }
}
