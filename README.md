# GCP & GKE Terraform CI/CD Setup

This is demonstration how to make basic CI/CD pipeline setup using Jenkins and SonarQube in GCP.

### Terraform Setup
- Make sure terraform exist in OS path. To test, type `which terraform`.
- In terminal, create new file `terraform.tfvars`.

```
project     = "project_id" # set your GCP progect id
region      = "us-central1"
zone        = "us-central1-c"
size        = "n1-standard-2"
public_key  = ".key/user.pub"
private_key = ".key/user.pem"
master_user = "user"
master_pass = "abcdefghij123" # password must be at least 16 characters
app_repo    = "https://github.com/incubus8/gcp-cicd-terraform-jenkins.git"
```

### Create SSH .key
- create ssh key `ssh-keygen -f user.pem -N""` # leave an empty password
- rename public to `.pub`
- place both in `.key` subdir

### IAM Setup
- enable Kubernetes Engine API by visiting service console
- Console -> IAM & admin -> Service accounts -> select default account (or create new) ->  Edit -> Create Key -> Json
- place the service account key file into the `.key/account.json`

### GCP Build Server Setup

- In terminal, type `terraform init`, then `terraform apply`
- Login to build server http://{terraform.output.build}:8080/
- Create SERVICE_ACCOUNT_KEY secret file (Jenkins -> Credentials -> Global Credentials -> Add Credentials)
  * SERVICE_ACCOUNT_KEY { type = secret file } For secrets file, use '.key/account.json'
- Create new project using `pipeline` template and paste `jenkins/Jenkinsfile` content
- Manage Jenkins -> Manage Plugins -> Available -> filter: sonar -> SonarQube Scanner for Jenkins -> Install and restart
- Manage Jenkins -> Configure System -> SonarQube servers -> Add SonarQube -> Name: sonar, Host: http://{terraform.output.sonar}:9000 -> Save
- Manage Jenkins -> Global Tool Configuration -> Add SonarQube Scanner -> Name: scanner -> Save
- Enable Poll SCM, if CI mode is required

### Test
- App url `http://{terraform.output.app}:5000`
- Jenkins URL server `http://{terraform.output.build}:8080`
- SonarQube `http://{terraform.output.sonar}:9000`

### Destroy

In terminal, type:

```
terraform destroy
```

## Attention

This is just a demo pipeline. You may want to setup more strict security if you want to apply in production.

## Further Improvement
- Deploy using Kubernetes Control Plane

Jakarta (c) 2019
