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
        // Build and push all images
        sh 'docker buildx bake --push --progress plain'
        // Create the Debian package and manifest
        sh 'dpkg-buildpackage -uc -us -b; mv ../wazigate_0.1_all.deb .'
        sh 'dpkg-scanpackages -m . | gzip --fast > Packages.gz'
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
      sh 'cp wazigate_0.1_all.deb Packages.gz /var/www/Staging/downloads/'
      archiveArtifacts artifacts: 'wazigate_0.1_all.deb, Packages.gz', fingerprint: true
      junit 'tests/results.xml'
    }
  }
}
