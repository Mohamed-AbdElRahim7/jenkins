// Jenkinsfile
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
                    // git branch: 'main', credentialsId: 'your-git-credential-id', url: 'https://github.com/your-org/your-repo.git'
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
                    // Install core dependencies including wget, gnupg, and Python packages for apt-add-repository
                    sh 'sudo apt-get update && sudo apt-get install -y software-properties-common python3-apt dirmngr python3-launchpadlib wget gnupg'

                    // Install Ansible directly from Debian repositories (removed PPA due to bookworm incompatibility)
                    sh 'sudo apt-get install -y ansible'

                    // Download HashiCorp GPG key to a temporary file, dearmor it,
                    // and move it to the keyrings directory using sudo tee for proper permissions.
                    sh '''
                        sudo wget -O /tmp/hashicorp-gpg-key.gpg https://apt.releases.hashicorp.com/gpg
                        sudo gpg --dearmor /tmp/hashicorp-gpg-key.gpg | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
                        sudo rm /tmp/hashicorp-gpg-key.gpg
                    '''

                    // Add HashiCorp repository
                    sh 'echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list'

                    // Update apt and install Terraform
                    sh 'sudo apt update && sudo apt install -y terraform'

                    // Verify installations
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

                            // Added -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null to bypass SSH host key verification.
                            // WARNING: In production, consider more secure ways to manage host keys (e.g., pre-populating known_hosts).
                            sh "ansible-playbook -i inventory.ini playbook.yml -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
                        }
                    }
                }
            }
        }
    }

    // The 'post' section has been re-added as per your request.
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
