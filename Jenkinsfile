pipeline {
  agent any
  tools {
    terraform 'terraform'
  }
  stages {
     stage('init') {
       steps {
         withCredentials([usernamePassword(credentialsId: 'aws-auth', passwordVariable: 'aws_secret', usernameVariable: 'aws_access')]) {
           sh "echo 'access_key = \"${aws_access}\"\nsecret_key = \"${aws_secret}\"' > terraform.tfvars"
         }
         sh "terraform fmt"
         sh "terraform validate"
         sh "terraform init -input=false"
       }
     }

//    stage('destroy') {
//      steps {
//        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
//          sh "terraform destroy --auto-approve -no-color"
//        }
//      }  
//    }
  
    stage('apply') {
      steps {
        sh "terraform apply --auto-approve -no-color"
//         sh "terraform output home | tr -d \'\"\' >> ./ansible/hosts"
      }
    }
    
//     stage('config') {
//       steps {
// //         withCredentials([sshUserPrivateKey(credentialsId: "aws-key-infra", keyFileVariable: 'aws_key')]) {
//           sh 'whoami'
// //            sh 'ansible-playbook -i ./ansible/hosts ./ansible/playbook.yml -u ubuntu --key-file "${aws_key}"'

// //         }
//         sh 'ansible-playbook -i ./ansible/hosts ./ansible/playbook.yml -u ubuntu --key-file ./home.pem'
//       }
//     }  
//   }
  
//   post {
//     success {            
//       withCredentials([string(credentialsId: 'telegram-token-home-ui-infra', variable: 'telegram_token'), string(credentialsId: 'telegram-chatid-home-ui-infra', variable: 'telegram_chatid')]) {
//         sh  ("""
//           curl -s -X POST https://api.telegram.org/bot${telegram_token}/sendMessage -d chat_id=${telegram_chatid} -d parse_mode=markdown -d text='*${env.JOB_NAME}* : POC *Branch*: ${env.GIT_BRANCH} *Build* : OK *Published* = YES'
//         """)
//       }
//     }
//     aborted {             
//       withCredentials([string(credentialsId: 'telegram-token-home-ui-infra', variable: 'telegram_token'), string(credentialsId: 'telegram-chatid-home-ui-infra', variable: 'telegram_chatid')]) {
//         sh  ("""
//           curl -s -X POST https://api.telegram.org/bot${telegram_token}/sendMessage -d chat_id=${telegram_chatid} -d parse_mode=markdown -d text='*${env.JOB_NAME}* : POC *Branch*: ${env.GIT_BRANCH} *Build* : `Aborted` *Published* = `Aborted`'
//         """)
//       }
//     }
//     failure {
//       withCredentials([string(credentialsId: 'telegram-token-home-ui-infra', variable: 'telegram_token'), string(credentialsId: 'telegram-chatid-home-ui-infra', variable: 'telegram_chatid')]) {
//         sh  ("""
//           curl -s -X POST https://api.telegram.org/bot${telegram_token}/sendMessage -d chat_id=${telegram_chatid} -d parse_mode=markdown -d text='*${env.JOB_NAME}* : POC *Branch*: ${env.GIT_BRANCH} *Build* : `not OK` *Published* = `no`'
//         """)
//       }
//     }
//     always {
//     deleteDir()
//     }    
  }
}
