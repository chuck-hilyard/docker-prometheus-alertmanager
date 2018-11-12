node('common')  {
	PROJECT_NAME = 'prometheus-alertmanager'
  def CONSUL_URL = "http://consul:8500/v1/kv/${PROJECT_NAME}/config?keys"
  def response = httpRequest(contentType: 'APPLICATION_JSON', url: "${CONSUL_URL}")
  def consul_key_list = response.content.tokenize(",")
  def consul_keys = [:]
  for (key in consul_key_list) {
    key = key.toString().replace("[","").replace("]","").replace("\"", "")
    response = httpRequest(contentType: 'APPLICATION_JSON', url: "http://consul:8500/v1/kv/${key}?raw")
    value = response.content
    consul_keys[key] == value
  }

  try {
    stage('Code Checkout') {
      git branch: "${BRANCH}",
      url: "${github_repo}"
      checkout scm
      stash includes: '**', name: 'everything'
    }
  }

  catch(err) {
    currentBuild.result = "FAILURE"
  throw err
  }
}

node('docker-builds') {

  stage('Docker Build') {
		unstash 'everything'
    sh "docker build -t ${PROJECT_NAME}:${BRANCH} ."
    sh "docker tag ${PROJECT_NAME}:${BRANCH} ${AWS_ACCOUNT_NUMBER}.dkr.ecr.us-west-2.amazonaws.com/${PROJECT_NAME}-${FQDN_HYPHENATED}:${BRANCH}"
  }

  stage('Docker Deploy') {
    AWS_LOGIN = sh(script: "aws ecr get-login --region ${REGION} --profile ${ENVIRONMENT}-${PLATFORM_LOWERCASE} --no-include-email", returnStdout: true).trim()
    sh(script: "echo $AWS_LOGIN |/bin/bash -; docker push ${AWS_ACCOUNT_NUMBER}.dkr.ecr.us-west-2.amazonaws.com/${PROJECT_NAME}-${FQDN_HYPHENATED}:${BRANCH}", returnStdout: true)
  }
}

// groovy ONLY executes on master nodes and must be included in scriptApproval.xml
// README: https://github.com/jenkinsci/pipeline-plugin/blob/master/TUTORIAL.md#serializing-local-variables
import groovy.text.StreamingTemplateEngine

@NonCPS
def sortBindings(vars) {
  def template = new StreamingTemplateEngine().createTemplate(text);
  String stuff = template.make(vars);
	return stuff;
}
