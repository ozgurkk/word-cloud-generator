pipeline {
  agent any
  stages {
    stage('gitcheckout') {
      steps {
        git(url: 'https://github.com/ozgurkk/word-cloud-generator', branch: 'main')
      }
    }

  }
}