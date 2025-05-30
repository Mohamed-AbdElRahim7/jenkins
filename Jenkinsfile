pipeline {
    // Defines the Jenkins agent to run the pipeline.
    agent any

    // Define environment variables used throughout the pipeline.
    environment {
        AWS_REGION = 'us-east-1'
        AWS_CREDENTIALS_ID = 'aws-credentials'
        SSH_KEY_CREDENTIAL_ID = 'jenkins-private-key'
        // Define paths to Terraform and Ansible directories relative to the workspace root
        TERRAFORM_DIR = 'terraform'
        ANSIBLE_DIR = 'ansible'
    }

    // Define the stages of the pipeline.
    stages {
        // Stage to checkout source code.
        // This is crucial now as Terraform and Ansible files are external.
        stage('Checkout SCM') {
            steps {
                script {
                    echo "Checking out SCM..."
                    // IMPORTANT: Configure your SCM (e.g., Git) here.
                    // Example for a Git repository:
                    // git branch: 'master', credentialsId: 'your-git-credential-id', url: 'https://github.com/Mohamed-AbdElRahim7/jenkins.git'
                    // For this example, we'll assume the files are already in the workspace
                    // or you've configured the SCM in your Jenkins job settings.
                }
            }
        }

        // Stage to install necessary dependencies (Terraform and Ansible) on the Jenkins agent.
        stage('Install Dependencies') {
            steps {
                script {
                    echo "Installing Terraform and Ansible..."
                    sh 'sudo apt-get update && sudo apt-get install -y software-properties-common'
                    sh 'sudo apt-add-repository --yes --update ppa:ansible/ansible'
                    sh 'sudo apt-get install -y ansible'
                    sh 'wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg'
                    sh 'echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list'
                    sh 'sudo apt update && sudo apt install -y terraform'
                    sh 'terraform version'
                    sh 'ansible --version'
                }
            }
        }

        // Stage to provision the EC2 instance using Terraform.
        stage('Terraform Apply') {
            steps {
                script {
                    echo "Creating EC2 instance with Terraform..."
                    // Change directory to where main.tf is located.
                    dir("${TERRAFORM_DIR}") {
                        withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: "${AWS_REGION}") {
                            sh 'terraform init'
                            sh 'terraform apply -auto-approve'
                            // Capture the public IP output from Terraform.
                            env.EC2_PUBLIC_IP = sh(returnStdout: true, script: 'terraform output -raw public_ip').trim()
                            echo "EC2 Public IP: ${env.EC2_PUBLIC_IP}"
                        }
                    }
                }
            }
        }

        // Stage to run the Ansible playbook on the newly provisioned EC2 instance.
        stage('Ansible Run') {
            steps {
                script {
                    echo "Running Ansible playbook on EC2 instance..."
                    // Change directory to where playbook.yml is located.
                    dir("${ANSIBLE_DIR}") {
                        withCredentials([file(credentialsId: "${SSH_KEY_CREDENTIAL_ID}", variable: 'SSH_KEY_FILE')]) {
                            sh "chmod 400 ${SSH_KEY_FILE}"

                            // Create the Ansible inventory file dynamically in the Ansible directory.
                            writeFile file: 'inventory.ini', text: """
                                [ec2_instance]
                                ${env.EC2_PUBLIC_IP} ansible_user=ubuntu ansible_ssh_private_key_file=${SSH_KEY_FILE} ansible_python_interpreter=/usr/bin/python3
                            """

                            // Run the Ansible playbook using the dynamically created inventory.
                            sh "ansible-playbook -i inventory.ini playbook.yml"
                        }
                    }
                }
            }
        }
    }

    // The 'post' section defines actions that run after the main pipeline stages complete.
    post {
        always {
            script {
                echo "Cleaning up resources with Terraform Destroy..."
                // Ensure we are in the Terraform directory for destroy.
                dir("${TERRAFORM_DIR}") {
                    withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: "${AWS_REGION}") {
                        sh 'terraform destroy -auto-approve || true'
                    }
                }
                echo "Cleanup complete."
            }
        }
    }
}
