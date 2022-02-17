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
         withCredentials([string(credentialsId: 'postgres-auth', variable: 'db_password')]) {
           sh "echo 'db_password = \"${db_password}\"' >> terraform.tfvars"
         }
         sh "terraform init -input=false"
         sh "terraform validate"
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
        sh "terraform output load_balancer_ip"
      }
    }
    
//     stage('update') {
//       steps {
//         withAWS(credentials: 'aws-auth-keys', region: 'us-east-2') {
//           sh "aws ecs register-task-definition --region us-east-2 --container-definitions file://container-definition.json"
//           sh "aws ecs update-service --cluster home --service home-application --task-definition home-application-task")         
//       }
//     }  
  }
  
  post {
//     success {            
//       withCredentials([string(credentialsId: 'telegram-token-home-dev-infra', variable: 'telegram_token'), string(credentialsId: 'telegram-chatid-home-dev-infra', variable: 'telegram_chatid')]) {
//         sh  ("""
//           curl -s -X POST https://api.telegram.org/bot${telegram_token}/sendMessage -d chat_id=${telegram_chatid} -d parse_mode=markdown -d text='*${env.JOB_NAME}* : POC *Branch*: ${env.GIT_BRANCH} *Build* : OK *Published* = YES'
//         """)
//       }
//     }
//     aborted {             
//       withCredentials([string(credentialsId: 'telegram-token-home-dev-infra', variable: 'telegram_token'), string(credentialsId: 'telegram-chatid-home-dev-infra', variable: 'telegram_chatid')]) {
//         sh  ("""
//           curl -s -X POST https://api.telegram.org/bot${telegram_token}/sendMessage -d chat_id=${telegram_chatid} -d parse_mode=markdown -d text='*${env.JOB_NAME}* : POC *Branch*: ${env.GIT_BRANCH} *Build* : `Aborted` *Published* = `Aborted`'
//         """)
//       }
//     }
//     failure {
//       withCredentials([string(credentialsId: 'telegram-token-home-dev-infra', variable: 'telegram_token'), string(credentialsId: 'telegram-chatid-home-dev-infra', variable: 'telegram_chatid')]) {
//         sh  ("""
//           curl -s -X POST https://api.telegram.org/bot${telegram_token}/sendMessage -d chat_id=${telegram_chatid} -d parse_mode=markdown -d text='*${env.JOB_NAME}* : POC *Branch*: ${env.GIT_BRANCH} *Build* : `not OK` *Published* = `no`'
//         """)
//       }
//     }
    always {
    deleteDir()
    }    
  }
}
