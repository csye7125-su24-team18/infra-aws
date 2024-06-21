pipeline {
    
    agent any
   environment {
        GITHUB_PAT = credentials('github_pat')
    }

    stages {
        

        stage('Checkout PR Branch') {
            steps {
                script {
                    // Fetch the latest changes from the origin using credentials
                    withCredentials([usernamePassword(credentialsId: GITHUB_PAT, usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN')]) {
                        sh 'git config --global credential.helper store'
                        sh 'echo "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com" > ~/.git-credentials'
                        // Fetch all branches including PR branches
                        sh 'git fetch origin +refs/pull/*/head:refs/remotes/origin/pr/*'
                        // Dynamically fetch the current PR branch name using environment variables
                        def prBranch = env.CHANGE_BRANCH
                        echo "PR Branch: ${prBranch}"
                        // Checkout the PR branch
                        sh "git checkout -B ${prBranch} origin/pr/${env.CHANGE_ID}"
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
    post {
        always {
            echo 'Cleaning up workspace'
            cleanWs()
        }
    }
}