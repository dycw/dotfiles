# setup-docker

1. ```console
   export VM_USERNAME='...'
   export VM_HOST='...'
   ```

1. ```console
   ssh-copy-id "${VM_USERNAME}@${VM_HOST}"
   ```

1. ```console
   ssh "${VM_USERNAME}@${VM_HOST}"
   su -
   apt update
   apt install -y sudo
   sudo usermod -aG sudo <${VM_USERNAME}>
   sudo groupadd docker
   sudo usermod -aG docker <${VM_USERNAME}>
   ```

1. ```console
   ssh "${VM_USERNAME}@${VM_HOST}"

   # Add Docker's official GPG key:
   sudo apt-get -y update
   sudo apt-get install -y ca-certificates curl
   sudo install -m 0755 -d /etc/apt/keyrings
   sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
   sudo chmod a+r /etc/apt/keyrings/docker.asc

   # Add the repository to Apt sources:
   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
     $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
     sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   sudo apt-get -y update
   sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   sudo apt-get install -y docker-compose-plugin
   ```
