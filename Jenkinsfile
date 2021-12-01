// This Jenkinsfile will build the docker images for all WaziGate components.
// After that, it will restart them on a test WaziGate RPI and run the test suite.

pipeline {
  agent any
  environment {
    WAZIGATE_TAG = 'nightly'
    WAZIGATE_IP  = '172.16.11.211' 
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
          git 'https://github.com/Waziup/wazigate-edge.git'
          sh 'docker buildx build --platform=linux/arm/v7 --tag waziup/wazigate-edge:$WAZIGATE_TAG --push --progress plain .'
        }
        dir("wazigate-system") {
          git 'https://github.com/Waziup/wazigate-system.git'
          sh 'docker buildx build --platform=linux/arm/v7 --tag waziup/wazigate-system:$WAZIGATE_TAG --push --progress plain .'
        }
        dir("wazigate-lora") {
          git 'https://github.com/Waziup/wazigate-lora.git'
          sh 'docker buildx build --platform=linux/arm/v7 --tag waziup/wazigate-lora:$WAZIGATE_TAG --push --progress plain .'
        }
      }
    }
    stage('Stage') {
      steps {
        sh 'echo "restart containers on RPI"'
        sh 'ssh pi@$WAZIGATE_IP sudo WAZIGATE_TAG=nightly /var/lib/wazigate/update_containers.sh'
        sh 'echo "Should wait that containers are ready"'
      }
    }
    stage('Test') {
      steps {
        dir('tests'){
          sh 'sudo -E python3 tests.py'
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
