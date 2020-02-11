def label = "worker-${UUID.randomUUID().toString()}"

podTemplate(label: label, containers: [
  containerTemplate(name: 'gradle', image: 'gradle:5.6.3-jdk8', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.8.8', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'helm', image: 'lachlanevenson/k8s-helm:latest', command: 'cat', ttyEnabled: true)
],
volumes: [
  hostPathVolume(mountPath: '/home/gradle/.gradle', hostPath: '/tmp/jenkins/.gradle'),
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]) {
  node(label) {
    def myRepo = checkout scm
    def gitCommit = myRepo.GIT_COMMIT
    def gitBranch = myRepo.GIT_BRANCH
    def shortGitCommit = "${gitCommit[0..10]}"
    def previousGitCommit = sh(script: "git rev-parse ${gitCommit}~", returnStdout: true)
    def ARTIFACTORY_URL = "http://10.1.0.176:80"

    stage('Test') {
      try {
        container('gradle') {
          sh """
            pwd && ls
            export "GIT_BRANCH=${gitBranch}"
            export "GIT_COMMIT=${gitCommit}"
            gradle test -Partifactory_user=admin -Partifactory_password=admin123 -Partifactory_contextUrl=${ARTIFACTORY_URL}/artifactory
            """
        }
      }
      catch (exc) {
        println "Failed to test - ${currentBuild.fullDisplayName}"
        throw(exc)
      }
    }
    stage('Build') {
      container('gradle') {
        sh """
        pwd && ls
        gradle build -Partifactory_user=admin -Partifactory_password=admin123 -Partifactory_contextUrl=${ARTIFACTORY_URL}/artifactory
        """
      }
    }
    stage('Push to Container') {
          container('docker') {
            sh """
            pwd && ls
            docker login ${ARTIFACTORY_URL} -u admin -p admin123
            docker build -t "${ARTIFACTORY_URL}/dino/upload-files:${shortGitcommit}" .
            docker push "${ARTIFACTORY_URL}/dino/upload-files:${shortGitcommit}"
            """
          }
        }
  }
}
