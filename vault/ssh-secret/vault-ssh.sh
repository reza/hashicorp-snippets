export SECRET_PATH=ssh

vault secrets enable -path=${SECRET_PATH} ssh
vault write ${SECRET_PATH}/config/ca generate_signing_key=true
vault read -field=public_key ${SECRET_PATH}/config/ca > trusted-user-ca-keys.pem

vault write ${SECRET_PATH}/roles/user -<<EOF > role-user-ssh.json
{
  "allow_user_certificates": true,
  "allowed_users": "*",
  "default_extensions": [
    {
      "permit-pty": ""
    }
  ],
  "key_type": "ca",
  "default_user": "ubuntu",
  "ttl": "30m0s"
}
EOF

ssh-keygen -t rsa -f user.key -C "user@example.com"

vault write -field=signed_key ${SECRET_PATH}/sign/user public_key=@user.key.pub > user.key.pub.signed

echo "Copy trusted-user-ca-keys.pem to /etc/ssh on your ssh target."
echo "Add the following line to the /etc/ssh/sshd_config file:"
echo "TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem"
echo "Restart ssh daemon on ssh host: sudo systemctl restart sshd.service"
echo "For logging: tail -f /var/log/auth.log | grep --line-buffered "sshd""