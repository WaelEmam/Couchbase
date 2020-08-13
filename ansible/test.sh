ansible-playbook create_aws_env.yaml --ask-vault-pass --tags create_ec2
echo "[cb-servers]" > inventory
ansible -i ec2.py tag_Name_ansible_cb --list-hosts| grep -v hosts | sed -e 's/^[ \t]*//' >> inventory
