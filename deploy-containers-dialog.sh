#!/bin/bash
HEIGHT=25
WIDTH=60
CHOICE_HEIGHT=4
TITLE="Deploy containers"
BACKTITLE="Deploy ECS Containers for clusters"
MENU='Please enter your choice from the options'
OPTIONS=(1 "container1-cluster-region" 
         2 "container2-cluster-region" 
         3 "Quit")
CHOICE=$(dialog --clear \
          --backtitle "$BACKTITLE" \
          --title "$TITLE" \
          --menu "$MENU" \
          $HEIGHT $WIDTH $CHOICE_HEIGHT \
          "${OPTIONS[@]}" \
          2>&1 >/dev/tty)
clear

#select opt in "${options[@]}"
#do
case $CHOICE in 
    1)
      JENKINS_JOB="job1"
      JENKINS_USER="username"
      JENKINS_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      CRUMB=$(curl -s --user ${JENKINS_USER}:${JENKINS_TOKEN} 'http://jenkins.example.com:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')
      echo "container1"
      curl -X POST -H "${CRUMB}" http://jenkins.example.com:8080/job/${JENKINS_JOB}/buildWithParameters?deploy_container='container1' --user ${JENKINS_USER}:${JENKINS_TOKEN}
      ;;
    2)
      JENKINS_JOB="job2"
      JENKINS_USER="username"
      JENKINS_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      CRUMB=$(curl -s --user ${JENKINS_USER}:${JENKINS_TOKEN} 'http://jenkins.example.com:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')
      echo "container2"
      curl -X POST -H "${CRUMB}" http://jenkins.example.com:8080/job/${JENKINS_JOB}/buildWithParameters?deploy_container='container2' --user ${JENKINS_USER}:${JENKINS_TOKEN}
      ;;
    3)
      break
      ;;
    *) echo  invalid option;;
esac
#done
