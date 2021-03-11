node{

  //Define all variables
  def appName = 'app1-spring-boot'
  def serviceName = "${appName}-backend"
  def imageVersion = 'development'
  def namespace = 'dev'
  def buildNum = "${env.BUILD_NUMBER}"
  def buildNumInt = "${env.BUILD_NUMBER}" as Integer
  def buildNumInt_1 = "${buildNumInt}" - 1
  //def imageTag = "ayanendude/${appName}:${imageVersion}.${env.BUILD_NUMBER}"
  def imageTag_1 = "ayanendude/${appName}:${imageVersion}.${env.buildNumInt_1}"

  //Stage 1 : Checkout code
  stage('Code checkout') {
    checkout scm
    sh("who am i")
     // break //to test UCD
  }

  //Stage 2 : Maven to build application.
  stage('Build application') {
    //sh("/usr/local/Cellar/maven/3.6.1/libexec/bin/mvn clean install")
    sh "/usr/local/Cellar/maven/3.6.1/libexec/bin/mvn clean install"
  }

    //Stage : Scan
    stage ('Test & Scan'){
        parallel Test:{
            sh "sleep 2"
            sh "echo 2"
            //sh "/usr/local/Cellar/maven/3.6.1/libexec/bin/mvn test"
        }, BlackDuck:{
            sh "sleep 3"
            sh "echo 3"
        }/*, SonarQube:{

            withSonarQubeEnv('Sonar1') {
                sh '/usr/local/Cellar/maven/3.6.1/libexec/bin/mvn clean package sonar:sonar \
                -Dsonar.projectKey=ayanendude_first_spring \
                -Dsonar.organization=ayanendude-github \
                -Dsonar.host.url=https://sonarcloud.io \
                -Dsonar.login=f538d1cdfae15608808898a0437676e813b9bbee'
            }

        }*/
    }

  //Stage 3: Docker image build
  stage('Docker Image build') {
      //sh("docker build -t ${imageTag} .")
      //sh("sudo -n /usr/local/bin/docker build -t ayanendude/app1-spring-boot .")
      //sh("sudo -n /usr/local/bin/docker build -t ${imageTag} .")
      sh("/usr/local/bin/docker build -t ${imageTag} .")
      //sh("docker build -t ${imageTag} .")
  }

  //Stage 4: Push the image to docker registry..
  stage('Push image to registry') {
      withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
      //sh ("sudo -n /usr/local/bin/docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}")
      sh ("/usr/local/bin/docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}")
      //sh ("sudo -n /usr/local/bin/docker push ayanendude/app1-spring-boot")
      //sh ("sudo -n /usr/local/bin/docker push ${imageTag}")}
      sh ("/usr/local/bin/docker push ${imageTag}")}
  }

  //Stage 5: Deploy Application
  stage('Deploy Application') {
       switch (namespace) {
              //Roll out to Dev Environment
              case "dev":
                   // Create namespace if it doesn't exist
                   //sh("sudo -n /usr/local/bin/kubectl --kubeconfig /Users/ayanendude/.kube/config version")
                   sh("/usr/local/bin/kubectl --kubeconfig /Users/ayanendude/.kube/config version")
                   sh("/usr/local/bin/kubectl --kubeconfig /Users/ayanendude/.kube/config get nodes")
                   sh("/usr/local/bin/kubectl --kubeconfig /Users/ayanendude/.kube/config get ns ${namespace} || /usr/local/bin/kubectl --kubeconfig /Users/ayanendude/.kube/config create ns ${namespace}")
                   
                   //Update the imagetag to the latest version
                //    sh ("sed s%VERSION%${buildNum}% Deployment/deployment-dev.yml | sed s%IMAGENAME%${imageTag}% | /usr/local/bin/kubectl --kubeconfig /Users/ayanendude/.kube/config apply -f - --record")
                //    sh ("sed s%VERSION%${buildNum}% Service/service-temp.yml | /usr/local/bin/kubectl --kubeconfig /Users/ayanendude/.kube/config apply -f -")
                   sh ("sed s%VERSION%${buildNumInt}% Deployment/deployment-dev.yml | sed s%IMAGENAME%${imageTag}% | /usr/local/bin/kubectl --kubeconfig /Users/ayanendude/.kube/config apply -f - --record")
                   sh ("sed s%VERSION%${buildNumInt}% Service/service-temp.yml | /usr/local/bin/kubectl --kubeconfig /Users/ayanendude/.kube/config apply -f -")
                   
                   //sh("kubectl --namespace=${namespace} apply -f k8s/development/service.yaml")
                   //Grab the external Ip address of the service
                   //sh("echo http://`kubectl --namespace=${namespace} get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
                   break

        //Roll out to Prd Environment
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
stage ('Approval Process') {
    timeout(time: 30, unit: "MINUTES") {
        input message: 'Do you want to switch Public service', ok: 'Yes'
    }
}

stage('Update Service') {
       switch (namespace) {
              //Roll out to Dev Environment
              case "dev":
                   //sh ("sed s%VERSION%${buildNumInt}% Service/service-temp.yml | /usr/local/bin/kubectl --kubeconfig /Users/ayanendude/.kube/config delete -f -")
                   sh ("sed s%VERSION%${buildNum}% Service/service-dev.yml | /usr/local/bin/kubectl --kubeconfig /Users/ayanendude/.kube/config apply -f -")
                   //sh ("sed s%VERSION%${buildNum}% Service/service-temp.yml | /usr/local/bin/kubectl --kubeconfig /Users/ayanendude/.kube/config delete -f -")
                   sh ("sed s%VERSION%${buildNumInt_1}% Deployment/deployment-dev.yml | sed s%IMAGENAME%${imageTag_1}% | /usr/local/bin/kubectl --kubeconfig /Users/ayanendude/.kube/config delete -f - --record")
                   
                   //sh("kubectl --namespace=${namespace} apply -f k8s/development/service.yaml")
                   //Grab the external Ip address of the service
                   //sh("echo http://`kubectl --namespace=${namespace} get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
                   break

        //Roll out to Prd Environment
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