# nix-remote-builder

This little script configures a docker container as nix remote builder for nix on your OSX machine. For this to work you need to have [docker-for-mac](https://docs.docker.com/docker-for-mac/) installed.

## Installation

```
$ ./init.sh
```

This will:

* fetch and run the required docker image
* create an entry in your ssh config file in `~/.ssh/config`
* install an ssh key to ~/.ssh/docker_rsa`
* create a keypair for nix package signing
* install some config files

## Usage

During the installation the docker container is started. If you want to start it at some later point you can do that like this:

```
$ docker run --restart always --name nix-docker -d -p 3022:22 lnl7/nix:ssh
```

With the docker container running you only need to tell nix to use it:

```
$ source ~/.nix/remote-systems.conf
```

You can then tell nix to build something for `linux` and it will automatically build the derivation inside the docker container:

```
$ nix-build -A nano --argstr system x86_64-linux
```

## Test

In order to test if your setup is working you can try to build the derivation provided in `./test`:

```
$ cd test
$ ./test.sh
these derivations will be built:
  /nix/store/s2by0icmyqg84k6r7aml3x00prf2j09c-build-test.drv
copying 1 missing paths (0.00 MiB) to ‘nix-docker’...
building ‘/nix/store/s2by0icmyqg84k6r7aml3x00prf2j09c-build-test.drv’ on ‘nix-docker’
$ file
result/bin/hello: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.32, not stripped
```
