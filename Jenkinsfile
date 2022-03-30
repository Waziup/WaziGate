// This Jenkinsfile will build the docker images for all WaziGate components.
// After that, it will restart them on a test WaziGate RPI and run the test suite.

pipeline {
  agent any
  options {
    timeout(time: 1, unit: 'HOURS')
  }
  stages {
    stage('Prepare') {
      steps {
        sh 'pip3 install unittest-xml-reporting'
       
        //Install docker buildx builder
        sh 'docker run --rm --privileged multiarch/qemu-user-static --reset -p yes'
        catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
            sh 'docker buildx create --name rpibuilder --platform linux/arm64/v8; true'
        }
        sh 'docker buildx use rpibuilder'
        sh 'docker buildx inspect --bootstrap'

        //read environment variables
        script {
          def props = readProperties interpolate: true, file: '.env'
          env.WAZIGATE_TAG = props.WAZIGATE_TAG
          env.DEB_NAME = "wazigate_${WAZIGATE_TAG}_all.deb"
        }
        sh 'echo "BUILD_ID=$BUILD_ID" >> .env'
      }
    }
    stage('Build') {
      steps {
        // Build all images
        sh 'docker buildx bake --load --progress plain'
        // Save all images in a single tar file
        sh 'docker save -o wazigate_images.tar `cat docker-compose.yml | yq .services[].image | envsubst`'

        // Create the Debian package and manifest (including the docker images)
        sh 'dpkg-buildpackage -uc -us -b; mv ../$DEB_NAME .'
        sh 'dpkg-scanpackages -m . | gzip --fast > Packages.gz'
      }
    }
    stage('Stage') {
      steps {
        // Copy Debian package to RPI
        sh 'scp $DEB_NAME pi@$WAZIGATE_IP:~/'
        sh 'ssh pi@$WAZIGATE_IP "sudo dpkg --unpack $DEB_NAME"'
        // Restart containers on RPI
        sh 'ssh pi@$WAZIGATE_IP "/var/lib/wazigate/update_containers.sh"'
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
    stage('Repeated_Tests') {
      steps {
        dir('tests'){
          catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
            echo "current build number: ${currentBuild.number}"
            sh 'sudo -E python3 repeated_functional_and_performance_tests.py'
          }
        }
      }
    }
  }
  post {
    success {
      // Pushing all images to dockerhub
      sh 'docker-compose push'
      // Install debian package in download repo
      sh 'cp $DEB_NAME Packages.gz /var/www/Staging/downloads/'
      // Publish artifacts
      archiveArtifacts artifacts: 'Packages.gz, $DEB_NAME', fingerprint: true
      junit 'tests/results.xml'
      junit 'tests/results_of_repeated_tests.xml'
    }
  }
}
