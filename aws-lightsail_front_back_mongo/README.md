# Simple Frontend+Backend+MongoDB production server running at AWS Lightsail

The process:
1. **Terraform** creates AWS resources.
2. **Domain registrar** maps the domain name to the instance IP.
2. **Ansible** creates services at the instance.

## Setup Terraform

[Installation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

Write AWS key and secret to **terraform/provider.tf**  
User should have either full admin rights, or at least full permissions for Lightsail, IAM, and ECR (see [P.S.](#ps) in the end of readme).

Then init terraform:
```
$ cd terraform
$ terraform init
```


## Use Terraform

0. List Lightsail blueprints
```
$ aws lightsail get-blueprints
```

1. Apply configs
```
$ terraform plan
$ terraform apply
```

2. Get instance keys
```
terraform output -raw public_key > ../public_key && \
terraform output -raw private_key > ../private_key && \
chmod 400 ../private_key
```

3. Check connection
```
ssh -i ../private_key ubuntu@$(terraform output -raw instance_ip)
```

4. Get instance ip
```
terraform output -raw instance_ip
```

5. Get AWS ECR user credentials
```
terraform output -raw access_key
terraform output -raw secret_key
```


## Setup Ansible

[Installation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

1. Write IP to **ansible/inventory.ini**
2. Write AWS ECR user credentials to **ansible/config.yml**
3. Check host:
```
$ ansible -i inventory.ini all --list-hosts
```


## Use Ansible

1. Run playbooks one by one 
```
cd ansible
ansible-playbook -i inventory.ini 0-create-files.yml
ansible-playbook -i inventory.ini 1-setup-docker.yml
ansible-playbook -i inventory.ini 2-setup-nginx.yml
ansible-playbook -i inventory.ini 3-setup-compose.yml
ansible-playbook -i inventory.ini 4-setup-certbot.yml
```

2. If you need to run only certain steps, use tags, e.g.:
```
ansible-playbook -i inventory.ini 4-setup-certbot.yml --tags "dry"
```

# P.S.
## Minimal permissions required for AWS

- AmazonEC2ContainerRegistryFullAccess
- IAMFullAccess
- LightsailFullAccess - no built-in policy, created manually:
```
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "lightsail:*"
        ],
        "Resource": "*"
    }
  ]
}
```
