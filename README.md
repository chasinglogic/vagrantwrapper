# vagrantwrapper, use one Vagrantfile for all your projects.

Vagrant wrapper allows you to store a single Vagrantfile in a predefined
location `$VAGRANTW_DIR` and use that across multiple projects with ease. Think
like the popular [virtualenvwrapper]() but for Vagrant.

## Example

Let's say for instance I have a project that looks like the following:

```text
./example
└── main.c

0 directories, 1 file
```

And I need to test if it compiles on Ubuntu when I'm running on a Mac or Fedora.
In this situation you have a few options:

1. Spin up a VM using Vagrant 

The problem here is then I'd have to add a Vagrantfile to this projects repo and
either commit it or Gitignore it.  This becomes more arduous when you have
multiple projects like this since you have to maintain a Vagrantfile per
project. So our project looks like this:

```text
./example
└── main.c
└── Vagrantfile

0 directories, 1 file
```


2. Use a docker container

The problem with docker containers is shared with that of the above solution of
'Vagrant per project'. You have to pre-provision, and pre-build a container or
VM image and then always use it. Containers don't maintain state so if you spend
some time installing development dependencies in a container that work will be
lost. Additionally, containers are not always representative of a real system
(for example if you're working on a SystemD unit file and or init system related
problems you can't properly use a container) where a real VM is.

3. Remote VPS or EC2 instance

Syncing your data to and from a remote machine is an arduous process at best.
Additionally if you want to develop on a remote machine that means you're
limited on what tools you can use and have to provision / maintain this machine
as a development environment.

### Vagrant wrapper to the rescue

Vagrant is a great tool and will automatically sync your data from the host
machine to remote. But due to the problems outlined in 1. it makes it difficult
to use on projects that are not centered around it or want to maintain a shared
Vagrantfile. 

Vagrant wrapper solves this by letting you store a shared Vagrantfile in a
directory elsewhere on your file system and letting you create multiple VMs
using a single Vagrantfile. Once it's installed we can just run vagrant commands
through it and it will manage creating VMs for us and syning our directories
properly as if the Vagrantfile was in our current working directory:

```text
~/Code/example  vagrantw up
/Users/chasinglogic/.vagrantwrapper not found creating...
Creating default Vagrantfile...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3250  100  3250    0     0  15218      0 --:--:-- --:--:-- --:--:-- 15258
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'ubuntu/bionic64'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'ubuntu/bionic64' is up to date...
==> default: Setting the name of the VM: example_default_1542487881348_11610
==> default: Fixed port collision for 22 => 2222. Now on port 2200.
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 22 (guest) => 2200 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2200
    default: SSH username: vagrant
    default: SSH auth method: private key
    default: Warning: Connection reset. Retrying...
    default: Warning: Remote connection disconnect. Retrying...
    default: Warning: Connection reset. Retrying...
    default: Warning: Remote connection disconnect. Retrying...
    default: Warning: Connection reset. Retrying...
    default: Warning: Remote connection disconnect. Retrying...
    default: Warning: Connection reset. Retrying...
    default: Warning: Remote connection disconnect. Retrying...
    default: Warning: Connection reset. Retrying...
    default: Warning: Remote connection disconnect. Retrying...
    default:
    default: Vagrant insecure key detected. Vagrant will automatically replace
    default: this with a newly generated keypair for better security.
    default:
    default: Inserting generated public key within guest...
    default: Removing insecure key from the guest if it's present...
    default: Key inserted! Disconnecting and reconnecting using new SSH key...
==> default: Machine booted and ready!
==> default: Checking for guest additions in VM...
==> default: Mounting shared folders...
    default: /vagrant => /Users/chasinglogic/Code/example
~/Code/example
```

It requires zero setup other than installation to get started.

## How it Works

Vagrant wrapper is a fairly simple bash script that requires a one line change
in your Vagrantfile to work.

First vagrant wrapper grabs whatever the current working directory is and stores
this value for later use. Then it finds the directory at the environment
variable `$VAGRANTW_DIR` (`$HOME/.vagrantwrapper` by default). If the directory
does not exist it creates it.

It uses the Vagrantfile found at `$VAGRANTW_DIR/Vagrantfile` as the base for
all environments it creates. If this file is not found it downloads the
[Vagrantfile from this
repository](https://github.com/chasinglogic/vagrantwrapper/blob/master/Vagrantfile) which is an Ubuntu 18.04 box.

It then creates an "environment" where vagrant will store it's local
`.vagrant` folder. This environment is stored at
`$VAGRANTW_DIR/environments/$ENVIRONMENT_NAME`. The environment name is
always equal to the basename of the `pwd` of where `vagrantw` was invoked. So
in our example above it was:
`/Users/chasinglogic/.vagrantwrapper/environments/example`.

It then symlinks the `VAGRANTW_DIR/Vagrantfile` into this new environment
directory. After that, it changes directory into this new environment
directory and invokes vagrant passing through the arguments passed to
`vagrantw`.

## Installation

If you're interested in using vagrant wrapper there is an install script
which you can use with the following command:

```bash
curl https://raw.githubusercontent.com/chasinglogic/vagrantwrapper/master/install.sh | bash
```

By default this will install into `$HOME/.local/bin` if you would like to
install vagrant wrapper somewhere else set the environment variable
`$INSTALL_DIR` to that location before running the above.

## Usage

```text
Usage: vagrantw [options] [<args>...]

Vagrant wrapper, a way to use one Vagrantfile for all your projects. ARGS is
always passed directly through to vagrant and so any flags or commands that
vagrant accepts this wrapper will as well. The only exceptions being '-h' and
'-n' as described below.

The '-a' argument is used to run a vagrant command against all machines
managed by vagrant wrapper. Useful for common tasks like shutting down all
VMs.

Options:
    -h         Print this help message and exit.
    -a         Run vagrant command on all known environments
    -n <name>  Name for this new environment. This defaults to the
               basename of the present working directory.

For vagrant help and not the help for this script run 'vagrantw help' or
'vagrantw --help'

```