pipeline {
    
    agent any
   environment {
        GITHUB_PAT = credentials('github_pat')
    }

    stages {
        

        stage('Checkout PR Branch') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github_pat', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN')]) {
                        // Use HTTPS URL with credentials
                        def repoUrl = "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/csye7125-su24-team18/infra-aws.git"
                def prNumber = env.CHANGE_ID
                def prAuthor = env.CHANGE_AUTHOR
                def prBranch = env.CHANGE_BRANCH
                
                echo "PR Number: ${prNumber}"
                echo "PR Author: ${prAuthor}"
                echo "PR Branch: ${prBranch}"
                
                // Fetch the PR
                sh "git fetch ${repoUrl} +refs/pull/${prNumber}/head:pr/${prNumber}"
                
                // Checkout the PR branch
                sh "git checkout pr/${prNumber}"
                
                // Ensure we're on the correct branch
                sh "git branch"
                    }
                }
            }
        }
 
         stage("Check Commit"){
            steps{
                script{
                    String commitMessage = sh(script: 'git log -1 --pretty=%B', returnStdout: true).trim()
                    def conventionalCommitRegex = /^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|\w+)(\(.+\))?: .{1,}$/

                    if (!commitMessage.matches(conventionalCommitRegex)) {
                        error "Commit message '${commitMessage}' does not follow the conventional commit format"
                    }
                }
            }
        }
        stage('Compare Changes') {
                steps {
                    script {
                        // Compare the PR branch with the main branch
                        def diff = sh(script: 'git diff origin/main...HEAD', returnStdout: true).trim()
                        echo "Git Diff: ${diff}"
                        if (diff == "") {
                            echo "No differences found."
                        } else {
                            echo "Differences found:\n${diff}"
                        }
                    }
                }
            }
       stage('Terraform init') {
            steps {
                script {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Format') {
            steps {
                script {
                    def fmtResult = sh(script: 'terraform fmt -check > terraform_fmt_output.log 2>&1', returnStatus: true)
                    echo "Terraform fmt exit code: ${fmtResult}"
                    sh 'cat terraform_fmt_output.log'
                    if (fmtResult != 0) {
                        error 'Terraform formatting check failed'
                    }
                }
            }
        }
        stage('Terraform Validate') {
            steps {
                script {
                    def validateResult = sh(script: 'terraform validate > terraform_validate_output.log 2>&1', returnStatus: true)
                    echo "Terraform validate exit code: ${validateResult}"
                    sh 'cat terraform_validate_output.log'
                    if (validateResult != 0) {
                        error 'Terraform validation failed'
                    }
                }
            }
        }
    
    
    }
}
