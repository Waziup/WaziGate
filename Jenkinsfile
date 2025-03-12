// This Jenkinsfile will build the docker images for all WaziGate components.
// After that, it will restart them on a test WaziGate RPI and run the test suite.

pipeline {
  agent any
  parameters {
    booleanParam(name: 'skip_perf_tests', defaultValue: false, description: 'Set to true to skip the perf test stage')
  }
  options {
    timeout(time: 1, unit: 'HOURS')
  }
  stages {
    stage('checkout') {
       steps {
          //Fetch HEAD for all submodules
          sh 'git submodule foreach --recursive "git fetch origin; git checkout $(git rev-parse --abbrev-ref HEAD); git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)"'
       }
    }
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

        // *************** if needed, pull missing docker images on the node *************** //
        //sh 'docker images'
        //sh 'docker pull --platform linux/arm64 postgres:14-alpine'
        //sh 'docker pull --platform linux/arm64 redis:7-alpine'
        //sh 'docker pull --platform linux/arm64/v8 eclipse-mosquitto:1.6'
        //sh 'docker pull --platform linux/arm64 chirpstack/chirpstack-gateway-bridge:4'
        //sh 'docker pull --platform linux/arm64 chirpstack/chirpstack:4'
        //sh 'docker pull --platform linux/arm64 chirpstack/chirpstack-rest-api:4'
        // ********************************************************************* //

        // Save all images in a single tar file
        sh 'docker save -o wazigate_images.tar `cat docker-compose.yml | yq .services[].image | envsubst`'

        // Build wazigate-dashboard
        dir("wazigate-edge") {
          dir("wazigate-dashboard") {
            // rebuild node-sass
            sh 'npm rebuild node-sass'

            // install all needed modules, run build, run create stats -> saved in wazigate-dashboard (open with npn )
            sh 'npm i --force && npm run build --force'
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
          sh 'go build -ldflags "-s -w -X main.branch=v3 -X main.version=$WAZIGATE_TAG -X main.buildNr=$BUILD_ID -X main.buildtime=$SEC_SINCE_UNIX_EPOCH" -buildvcs=false -o wazigate .'
        }

        // Create the Debian package and manifest (including the docker images)
        sh 'dpkg-buildpackage -uc -us -b; mv ../$DEB_NAME .'
        sh 'dpkg-scanpackages -m . | gzip --fast > Packages.gz'
      }
    }
    stage('Stage') {
      steps {
        // *************** monitor the node *************** //
        sh 'ssh pi@$WAZIGATE_IP "df -h; ls -a; docker volume ls; exit"'
        // *********************************************** //

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
    stage('Perf_Tests') {
      when { expression { params.skip_perf_tests != true } }
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
      plot csvFileName: 'plot_aggregated_performance_results.csv',
        csvSeries: [[
                              file: 'tests/aggregated_performance_results.csv', 
                              url: '']],
        group: 'Performance evaluation', 
        title: 'Time taken for aggregated performance tests',
        style: 'line', 
        exclZero: false,
        keepRecords: false,
        logarithmic: false,
        numBuilds: '',
        useDescr: false,
        yaxis: 'Time in sec', 
        yaxisMinimum: '0', 
        yaxisMaximum: '1000'
    }
  }
}
