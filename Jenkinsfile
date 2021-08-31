pipeline {
  agent any
  environment {
    ARDUINO_DIRECTORIES_USER = '/home/cdupont/Documents/Waziup/WaziDev/'
  }
  stages {
    stage('Prepare') {
      steps {
        sh 'pip3 install unittest-xml-reporting'
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
      junit 'IntegrationTests/results.xml'
    }
  }
}
