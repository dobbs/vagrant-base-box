This shell script and Vagrantfile together allow you to create a local
Vagrant base box with customized user settings that are as easy to use
as other base boxes, but which do not use the default user and default
insecure keypair.

#Creating your local base box:

    sh vagrant-box-add.sh ubuntu/trusty64

#Verifying that the base box is now available in your system:

    % vagrant box list
    local/ubuntu-trusty64              (virtualbox, 0)

#Using the new base box in another Vagrantfile:

    Vagrant.configure("2") do |config|
      config.vm.box = "local/ubuntu-trusty64"
    end

#The backstory:

Vagrant base boxes have default user settings which rely on an
insecure keypair for authentication.

So of course one of the first things I always want to do is change the
default user and especially to specify my own keypair like this:

    config.ssh.forward_agent = true
    config.ssh.username = "deploy"
    config.ssh.private_key_path = "~/.ssh/id_rsa"

That trick never works because the basebox doesn't know my deploy user
and that user doesn't have .ssh/authorized_keys to match my private
key.
