# Admin + Backend + MongoDB replica

## Setup Ansible

[Installation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

1. Write IP to **ansible/inventory.ini**
2. Write AWS ECR user credentials to **ansible/config.yml**
3. Check host:
```
$ cd ansible
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
ansible-playbook -i inventory.ini 5-import-db.yml
```

2. If you need to run only certain steps, use tags, e.g.:
```
ansible-playbook -i inventory.ini 4-setup-certbot.yml --tags "dry"
```
