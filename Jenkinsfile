node('common')  {
	PROJECT_NAME = 'prometheus-alertmanager'
	AWS_ACCOUNT_NUMBER = sh(script: "curl http://consul:8500/v1/kv/${PROJECT_NAME}/config/AWS_ACCOUNT_NUMBER?raw", returnStdout: true).trim()
	FQDN = sh(script: "curl http://consul:8500/v1/kv/${PROJECT_NAME}/config/FQDN?raw", returnStdout: true).trim()
	FQDN_HYPHENATED = FQDN.replace('.', '-')
	ENVIRONMENT = sh(script: "curl http://consul:8500/v1/kv/${PROJECT_NAME}/config/ENVIRONMENT?raw", returnStdout: true).trim()
	PLATFORM = sh(script: "curl http://consul:8500/v1/kv/${PROJECT_NAME}/config/PLATFORM?raw", returnStdout: true).trim()
	PLATFORM_LOWERCASE = PLATFORM.toLowerCase()
	BRANCH = sh(script: "curl http://consul:8500/v1/kv/${PROJECT_NAME}/config/branch?raw", returnStdout: true).trim()
	REGION = sh(script: "curl http://consul:8500/v1/kv/${PROJECT_NAME}/config/REGION?raw", returnStdout: true).trim()
  github_repo = sh(script: "curl http://consul:8500/v1/kv/${PROJECT_NAME}/config/github_repo?raw", returnStdout: true).trim()

  try {
    stage('Code Checkout') {
      git branch: "${BRANCH}", // <- this needs to be solved
      url: "${github_repo}"
      stash includes: 'Dockerfile', name: 'dockerfile'
      stash includes: '*.yml', name: 'yaml_files'
      stash includes: 'amtool', name: 'amtool'
    }

    stage('Build') {
      sh "go get github.com/prometheus/alertmanager/cmd/amtool"
      sh "export GOOS=linux make build"
    }
  }

  catch(err) {
    currentBuild.result = "FAILURE"
  throw err
  }
}

node('docker-builds') {

  stage('Docker Build') {
		unstash 'dockerfile'
		unstash 'yaml_files'
		unstash 'amtool'
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
