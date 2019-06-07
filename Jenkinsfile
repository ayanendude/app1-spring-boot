node{

  //Define all variables
  def project = 'project1'
  def appName = 'app1-spr-hello'
  def serviceName = "${appName}-backend"
  def imageVersion = 'development'
  def namespace = 'dev'
  def imageTag = "ayanendude/${project}/${appName}:${imageVersion}.${env.BUILD_NUMBER}"

  //Checkout Code from Gitt
  stage('Code checkout') {
    checkout scm
  }
  stage('Build application') {
    sh("/usr/local/Cellar/maven/3.6.1/libexec/bin/mvn clean install")
    //sh("mvn clean install")
  }

  //Stage  : Docker login...
  stage('Docker Image build') {
      //sh("docker build -t ${imageTag} .")
      sh("/usr/local/bin/docker build -t ayanendude/app1-spring-boot .")
  }


  //Stage 2 : Push the image to docker registry
  stage('Push image to registry') {
      withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
      sh ("/usr/local/bin/docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}")
      sh ("/usr/local/bin/docker push ayanendude/app1-spring-boot")}
  }

  //Stage 3 : Deploy Application
  stage('Deploy Application') {
       switch (namespace) {
              //Roll out to Dev Environment
              case "dev":
                   // Create namespace if it doesn't exist
                   sh("kubectl get ns ${namespace} || kubectl create ns ${namespace}")
           //Update the imagetag to the latest version
                   //sh("sed -i.bak 's#gcr.io/${project}/${appName}:${imageVersion}#${imageTag}#' ./k8s/development/*.yaml")
                   //Create or update resources
           sh("kubectl --namespace=${namespace} apply -f deployment-dev.yaml")
                   //sh("kubectl --namespace=${namespace} apply -f k8s/development/service.yaml")
           //Grab the external Ip address of the service
                   //sh("echo http://`kubectl --namespace=${namespace} get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
                   break

        //Roll out to Dev Environment
              case "production":
                   // Create namespace if it doesn't exist
                   sh("kubectl get ns ${namespace} || kubectl create ns ${namespace}")
           //Update the imagetag to the latest version
                   sh("sed -i.bak 's#gcr.io/${project}/${appName}:${imageVersion}#${imageTag}#' ./k8s/production/*.yaml")
           //Create or update resources
                   sh("kubectl --namespace=${namespace} apply -f k8s/production/deployment.yaml")
                   sh("kubectl --namespace=${namespace} apply -f k8s/production/service.yaml")
           //Grab the external Ip address of the service
                   sh("echo http://`kubectl --namespace=${namespace} get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
                   break

              default:
                   sh("kubectl get ns ${namespace} || kubectl create ns ${namespace}")
                   //sh("sed -i.bak 's#gcr.io/${project}/${appName}:${imageVersion}#${imageTag}#' ./k8s/development/*.yaml")
                   sh("kubectl --namespace=${namespace} apply -f deployment.yaml")
                   //sh("kubectl --namespace=${namespace} apply -f k8s/development/service.yaml")
                   //sh("echo http://`kubectl --namespace=${namespace} get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
                   break
  }

}
}