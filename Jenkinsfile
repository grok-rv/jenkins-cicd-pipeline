#!/usr/bin/env groovy
/**
* this is a cicd pipeline jenkinsfile for engage store morpheus poc
* Deploy Test 14
*/
import hudson.model.*
import groovy.json.JsonSlurperClassic
import groovy.json.JsonBuilder
import groovy.json.JsonOutput
import groovy.util.*

def slackNotificationChannel = 'channelname'

def notifySlack(text, channel, attachments) {
    def slackURL = 'https://hooks.slack.com/services/xxx/xxxx/xxx'
    def jenkinsIcon = 'https://wiki.jenkins-ci.org/download/attachments/2916393/logo.png'
    def payload = JsonOutput.toJson([text      : text,
                                     channel   : channel,
                                     username  : "Jenkins",
                                     attachments: attachments,
                                     icon_url: jenkinsIcon ])
    sh "curl -X POST --data-urlencode \'payload=${payload}\' ${slackURL}"
}

pipeline {

  agent {
    node { label 'slavename' }
  }

/**  options {
      // Discard the old builds and keep only the 7 most recent builds
      buildDiscarder(logRotator(numToKeepStr:'10'))

      //retry the entire pipeline for 3 times on failure
      retry(3)

      //abort the pipeline if it's more than 2 hours
      timeout(time: 3, unit: 'HOURS')

      //disable concurrent executions of pipeline
      disableConcurrentBuilds()
  
  }*/

  stages {
    // checkout the git source code repo
    stage('Git Checkout') {
      steps {
        dir('dirname') {
          git branch: 'master', credentialsId: '', url: 'git@github.com:rv0147/dirname.git'
        }
      }
    }
    
    
    //Run the tests, integration, uitests locally
    stage('Run Tests Locally') {
      steps {
        retry(3) {
            dir('dirname/tests') {
                sh './docker_test.sh'
            }
        }
      }
    }
    
   
    stage('Abort or Proceed Deploy') {
        steps {
            dir('dirname/scripts') {
              script {
                try {
                    sh 'python commit_message.py'
                } catch (err) {
                    echo "caught: ${err}"
                    currentBuild.result= 'ABORTED'
                    notifySlack("", slackNotificationChannel, [[
                        title: "Deploy containers ABORTED",
                        title_link: "${env.BUILD_URL}",
                        text: "${currentBuild.result}",
                        color: "grey"
                    ]])
                    
                    emailext(
                        subject: "Deployment Failed! - ${env.JOB_NAME} [${env.BUILD_NUMBER}]",
                        body: """FAILURE!: '${env.JOB_NAME} [${env.BUILD_NUMBER}]'
                        Check console output at <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]/a>""",
                        to: "ramu.xx@gmail.com"
                    )
                }
              }
            }
        }
    }
    
    // Verify git commit id
    stage('Verify tests') {
      steps {
        dir('dirname/scripts') {
            script {
                try {
                    sh './prodtests.sh'
                } catch(err) {
                    echo "caught: ${err}"
                    sh 'python restore_commit.py'
                    currentBuild.result = 'FAILURE'
                    notifySlack("", slackNotificationChannel, [[
                        title: "Verify commitid and prodtests failed. Restore and Recycle!",
                        title_link: "${env.BUILD_URL}",
                        text: "${currentBuild.result}",
                        color: "danger"
                    ]])
                    emailext(
                        subject: "Deployment Failed! - ${env.JOB_NAME} [${env.BUILD_NUMBER}]",
                        body: """Build failed due to verify commitid tests!: '${env.JOB_NAME} [${env.BUILD_NUMBER}]'
                        Check console output at <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]/a>""",
                        to: "ramu.xx@gmail.com"
                    )

                }
            }
         
        }
      }
    }  
  }
  

  post {
    /**  
    always {
            echo "Build ${env.JOB_NAME}"
            //build junit files
            junit 'dirname/tests/*.xml'
            //build artifacts
            archiveArtifacts artifacts: 'dirname/tests/artifacts/*', fingerprint: true
    } */
    success {
            notifySlack("", slackNotificationChannel, [[
                title: "${env.JOB_NAME}, build #${env.BUILD_NUMBER}",
                title_link: "${env.BUILD_URL}",
                text: "SUCCESS",
                color: "good"

            ]])

            emailext(
                subject: "${env.JOB_NAME} [${env.BUILD_NUMBER}] Success!",
                body: """'${env.JOB_NAME} [${env.BUILD_NUMBER}]' Success!":</p>
                    <p>Check console output at <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]/a></p>""",
                to: "ramu.xxxx@gmail.com"
            )
    }
    
    failure {
        notifySlack("", slackNotificationChannel, [[
                title: "${env.JOB_NAME}, build #${env.BUILD_NUMBER}",
                title_link: "${env.BUILD_URL}",
                text: "Deployment Failed and Rollback",
                color: "danger"

        ]])

        emailext(
                subject: "Deployment Failed! - ${env.JOB_NAME} [${env.BUILD_NUMBER}]",
                body: """FAILURE!: '${env.JOB_NAME} [${env.BUILD_NUMBER}]'
                    Check console output at <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]/a>""",
                to: "ramu.xxxxx@gmail.com"
        )

    }
    
    unstable {
        notifySlack("", slackNotificationChannel, [[
                title: "${env.JOB_NAME}, build #${env.BUILD_NUMBER}",
                title_link: "${env.BUILD_URL}",
                text: "Deployment Aborted!!",
                color: "grey"

        ]])

        emailext(
                subject: "Deployment Aborted! - ${env.JOB_NAME} [${env.BUILD_NUMBER}]",
                body: """Aborted!: '${env.JOB_NAME} [${env.BUILD_NUMBER}]'
                    Check console output at <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]/a>""",
                to: "ramu.xxx@gmail.com"
        )

    }
    
    
  }
}
