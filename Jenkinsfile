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
        // update each submodule
        sh 'git submodule update --recursive'
        // Build all images
        sh 'docker buildx bake --load --progress plain'
        // Save all images in a single tar file
        sh 'docker save -o wazigate_images.tar `cat docker-compose.yml | yq .services[].image | envsubst`'

        // Build wazigate-dashboard
        dir("wazigate-edge") {
          dir("wazigate-dashboard") {
            // install all needed modules, run build, run create stats -> saved in wazigate-dashboard (open with npn )
            sh 'npm i && npm run build && npm run build-stats'
          }
        }
        // Build wazigate(-edge) go backend
        dir("wazigate-edge") {
          script {
            env.GOARCH = "arm64"
            env.GOOS = "linux"
            SEC_SINCE_UNIX_EPOCH = sh (
              script: 'date +%s',
              returnStdout: true
            ).trim()
            echo "Seconds since UNIX epoch: ${SEC_SINCE_UNIX_EPOCH}"
            env.SEC_SINCE_UNIX_EPOCH = "$SEC_SINCE_UNIX_EPOCH"
          }
          sh 'echo "2nd:Seconds since UNIX epoch: ${SEC_SINCE_UNIX_EPOCH}"'
          sh 'go build -ldflags "-s -w -X main.branch=v2 -X main.version=$WAZIGATE_TAG -X main.buildNr=$BUILD_ID -X main.buildtime=$SEC_SINCE_UNIX_EPOCH" -o wazigate .'
        }

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
            sh "sudo -E python3 repeated_functional_and_performance_tests.py ${currentBuild.number}"
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
      //junit 'tests/results_of_repeated_tests.xml'
      // Create Plot for tracking performance
      // plot xmlFileName: 'plot_aggregated_performance_results_test1test.csv', 
      //   xmlSeries: [[
      //                       file: 'aggregated_performance_results.xml',
      //                       exclusionValues: '',
      //                       displayTableFlag: false,
      //                       inclusionFlag: 'OFF',
      //                       nodeType: 'Nodeset', 
      //                       xpath: '/root/test1/*',
      //                       url: '']],
      //   group: 'Performance evaluation',
      //   title: 'Time taken for individual tests',
      //   style: 'line',
      //   exclZero: false,
      //   keepRecords: false,
      //   logarithmic: false,
      //   numBuilds: '',
      //   useDescr: false,
      //   yaxis: 'testime',
      //   yaxisMaximum: '250',
      //   yaxisMinimum: '0'
      plot(
        group: 'Performance evaluation', 
        title: 'Time taken for aggregated performance tests',
        csvFileName: 'plot_aggregated_performance_results.csv',
        csvSeries: [[
          file: 'tests/aggregated_performance_results.csv', 
          url: '']],
        style: 'line', 
        exclZero: false,
        keepRecords: false,
        logarithmic: false,
        numBuilds: '',
        useDescr: false,
        yaxis: 'Time in sec', 
        yaxisMinimum: '0', 
        yaxisMaximum: '250',
        keepRecords: false)
    }
  }
}
