pipeline {
  agent any
  environment {
    VAULT_ADDR = 'http://vault:8200'
    MY_TOKEN = credentials('vault-token')
  }
  stages {

    stage('Get consul key') {
      steps {
        script {
          def response = sh(
            script: "curl -s $CONSUL_KEY",
            returnStdout: true
          ).trim()

          echo "Consul raw response: ${response}"

          try {
            def json = readJSON text: response
            def port = new String(json[0].Value.decodeBase64())
          } catch (err) {
            echo "Failed to parse JSON: ${err}"
            error("Could not parse response as JSON. Check Consul URL or network.")
          }
        }
      }
    }

    stage('Get AWS Credentials') {
      steps {
        script {
          def response = sh(
            script: """
              curl --silent --request GET \
                   --header "X-Vault-Token: ${MY_TOKEN}" \
                   ${VAULT_ADDR}/v1/secret/data/ssh/imtec-key
            """,
            returnStdout: true
          ).trim()

          try {
            def json = readJSON text: response
            def imtec_key = json.data.data.key
          } catch (err) {
            echo "Failed to parse JSON: ${err}"
            error("Could not parse Vault response. Check if path is correct and Vault is unsealed.")
          }
        }
      }
    }

    stage('use imtec_key') {
      steps {
        script {
          sh """
            ansible-playbook nginx.yml -i inventory.ini \
            -e "nginx_port=${port}" \
            --private-key=${imtec_key}
          """
        }
      }
    }
  }
}
