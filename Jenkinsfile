// This Jenkinsfile will build the docker images for all WaziGate components.
// After that, it will restart them on a test WaziGate RPI and run the test suite.

pipeline {
  agent any
  options {
    timeout(time: 1, unit: 'HOURS')
  }
  environment {
    WAZIGATE_TAG = 'nightly'
  }
  stages {
    stage('Prepare') {
      steps {
        sh 'pip3 install unittest-xml-reporting'
        
        sh 'docker run --rm --privileged multiarch/qemu-user-static --reset -p yes'
        catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
            sh 'docker buildx create --name rpibuilder --platform linux/arm/v7; true'
        }
        sh 'docker buildx use rpibuilder'
        sh 'docker buildx inspect --bootstrap'
      }
    }
    stage('Build') {
      steps {
        dir("wazigate-edge") {
          git branch: 'v2', url: 'https://github.com/Waziup/wazigate-edge.git'
          dir ("wazigate-dashboard") {
            git 'https://github.com/Waziup/wazigate-dashboard.git'
          }
          sh 'docker buildx build --platform=linux/arm64 --tag waziup/wazigate-edge:$WAZIGATE_TAG --push --progress plain .'
        }
        dir("wazigate-system") {
          git 'https://github.com/Waziup/wazigate-system.git'
          sh 'docker buildx build --platform=linux/arm/v7 --tag waziup/wazigate-system:$WAZIGATE_TAG --push --progress plain .'
        }
        dir("wazigate-lora") {
          git branch: 'v2', url: 'https://github.com/Waziup/wazigate-lora.git'
          sh 'docker buildx build --platform=linux/arm64 --tag waziup/wazigate-lora:$WAZIGATE_TAG --push --progress plain .'
          dir("forwarders") {
            sh 'docker buildx build --platform=linux/arm64 --tag waziup/wazigate-lora-forwarders --push --progress plain .'
          }
        }
      }
    }
    stage('Stage') {
      steps {
        sh 'echo "restart containers on RPI"'
        sh 'ssh -o StrictHostKeyChecking=no pi@$WAZIGATE_IP "cd /var/lib/wazigate; sudo WAZIGATE_TAG=nightly ./update_containers.sh"'
      }
    }
    stage('Test') {
      steps {
        dir('tests'){
          catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            sh 'sudo -E python3 tests.py'
          }
        }
      }
    }
  }
  post {
    always {
      junit 'tests/results.xml'
    }
  }
}
