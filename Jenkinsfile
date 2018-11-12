node('common')  {
	PROJECT_NAME = 'prometheus-alertmanager'
  CONSUL_URL = "http://consul:8500/v1/kv/${PROJECT_NAME}/config?keys"
  def response = httpRequest(contentType: 'APPLICATION_JSON', url: "${CONSUL_URL}")
  println('Status: '+response.status)
  println('Response: '+response.content)
  def consul_key_list = response.content.tokenize(",")
  // build the k/v
  def consul_map = [:]
  for (item in consul_key_list) {
    println("item: $item[1]")
    #response = httpRequest(contentType: 'APPLICATION_JSON', url: "http://consul:8500/v1/kv/${item}")
    #value = response.content()
    #println("key:${item}  value:${value}")
  }

  /*
	*AWS_ACCOUNT_NUMBER = sh(script: "curl http://consul:8500/v1/kv/${PROJECT_NAME}/config/AWS_ACCOUNT_NUMBER?raw", returnStdout: true).trim()
	*FQDN = sh(script: "curl http://consul:8500/v1/kv/${PROJECT_NAME}/config/FQDN?raw", returnStdout: true).trim()
	*FQDN_HYPHENATED = FQDN.replace('.', '-')
	*ENVIRONMENT = sh(script: "curl http://consul:8500/v1/kv/${PROJECT_NAME}/config/ENVIRONMENT?raw", returnStdout: true).trim()
	*PLATFORM = sh(script: "curl http://consul:8500/v1/kv/${PROJECT_NAME}/config/PLATFORM?raw", returnStdout: true).trim()
	*PLATFORM_LOWERCASE = PLATFORM.toLowerCase()
	*BRANCH = sh(script: "curl http://consul:8500/v1/kv/${PROJECT_NAME}/config/branch?raw", returnStdout: true).trim()
	*REGION = sh(script: "curl http://consul:8500/v1/kv/${PROJECT_NAME}/config/REGION?raw", returnStdout: true).trim()
  *github_repo = sh(script: "curl http://consul:8500/v1/kv/${PROJECT_NAME}/config/github_repo?raw", returnStdout: true).trim()
  */

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
