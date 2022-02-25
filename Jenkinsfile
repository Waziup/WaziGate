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
        // Create the Debian package
        sh 'dpkg-buildpackage -uc -us'
        sh 'mv ../wazigate_0.1_all.deb .'
        // Build and push all images
        sh 'docker buildx bake --push --progress plain'
      }
    }
    stage('Stage') {
      steps {
        sh 'scp wazigate_0.1_all.deb pi@$WAZIGATE_IP:~/'
        sh 'ssh pi@$WAZIGATE_IP "sudo dpkg -i wazigate_0.1_all.deb"'
        sh 'echo "restart containers on RPI"'
        sh 'ssh pi@$WAZIGATE_IP "WAZIGATE_TAG=$WAZIGATE_TAG /var/lib/wazigate/update_containers.sh"'
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
    success {
      archiveArtifacts artifacts: 'wazigate_0.1_all.deb', fingerprint: true
      sh 'cp wazigate_0.1_all.deb /var/www/Staging/downloads/'
      junit 'tests/results.xml'
    }
  }
}
