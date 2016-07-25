#!/usr/bin/env bash

NIX_KEY_DIR="${HOME}/.nix/keys"
DOCKER_SSH_KEY="${HOME}/.ssh/docker_rsa"
IS_RUNNING=$(docker inspect --format="{{.State.Running}}" nix-docker 2>/dev/null)

if [ "$IS_RUNNING" = "true" ]; then
    echo "nix-docker container is already running"
else
    echo "Starting docker container"
    docker run --restart always --name nix-docker -d -p 3022:22 lnl7/nix:ssh
fi

touch ~/.ssh/config
grep -q nix-docker ~/.ssh/config
if [ $? -eq 0 ] ; then
    echo "Found entry for \"nix-docker\" in ssh config"
else
    echo "Adding ssh config entry to ${HOME}/.ssh/config"
    cat ./files/ssh-config | sed -e "s,__KEY__,${DOCKER_SSH_KEY}," >> ${HOME}/.ssh/config
fi

echo "Installing (insecure) rsa key"
mkdir -p $NIX_KEY_DIR
cp ./files/insecure_rsa $DOCKER_SSH_KEY
chmod 600 $DOCKER_SSH_KEY

echo "Creating (insecure) signing keypair"
openssl genrsa -out $NIX_KEY_DIR/signing-key.sec 2048
openssl rsa -in $NIX_KEY_DIR/signing-key.sec -pubout > $NIX_KEY_DIR/signing-key.pub
chmod 600 $NIX_KEY_DIR/signing-key.sec

echo "Copying key to build machine"
ssh -o "StrictHostKeyChecking=no" nix-docker mkdir -p /etc/nix
scp $NIX_KEY_DIR/signing-key.sec nix-docker:/etc/nix/signing-key.sec

echo "Installing nix config files"
cp files/remote-systems.conf ~/.nix
cp files/remote-build-env ~/.nix
