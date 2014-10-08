Vagrant.configure("2") do |config|

  if %w{up provision}.include? ARGV.first
    if ENV["username"].nil?
      puts "using default username 'deploy'"
      username = 'deploy'
    else
      username = ENV["username"]
      puts "using given username '#{username}'"
    end

    if ENV["box"].nil? || ENV["box"].empty?
      puts "failed.  You must specify a base box to use.\ne.g. env box=ubuntu/trusty64 vagrant up"
      exit(1)
    else
      box = ENV["box"]
    end


    box_pathsafe = box.gsub('/', '-')

    private_key_path = Dir.glob(File.join(Dir.home, '.ssh/id_{dsa,ec_dsa,rsa}')).first
    identity = File.read("#{private_key_path}.pub")

    vagrantfile_path = "./local-#{box_pathsafe}-Vagrantfile"
    File.write(vagrantfile_path, <<-VAGRANTFILE) unless File.exists? vagrantfile_path
Vagrant.configure("2") do |config|
  config.ssh.username = '#{username}'
  config.ssh.private_key_path = '#{private_key_path}'
  config.ssh.forward_agent = true

  config.vm.provision "shell", inline: <<-EOF
    getent passwd vagrant &> /dev/null
    if [ $? -eq 0 ] ; then
      sudo deluser vagrant --remove-home
    fi
  EOF
end
    VAGRANTFILE

  end

  config.vm.box = box

  config.vm.provision "shell", inline: <<-EOF
    sudo apt-get update

    # update bash if it is vulnerable to the shellshock bug
    (env x='() { :;}; exit 1' bash -c "echo bash: $(dpkg -s bash | grep Version)")
    if [ $? -ne 0 ] ; then
      sudo apt-get install bash
    fi

    getent passwd #{username} &> /dev/null
    if [ $? -ne 0 ] ; then 
      sudo useradd --shell /bin/bash --home-dir /home/#{username} --create-home --groups admin --user-group #{username}
    fi

    set_permissions () {
      the_path=$1
      the_user=$2
      the_group=$3
      the_mode=$4

      if [ "$(sudo stat -c '%U' $the_path)" != "$the_user" ] ; then
        sudo chown $the_user $the_path
      fi

      if [ "$(sudo stat -c '%G' $the_path)"  != "$the_group" ] ; then
        sudo chgrp $the_group $the_path
      fi

      if [ "$(sudo stat -c '%a' $the_path)" != "$the_mode" ] ; then
        sudo chmod $the_mode $the_path
      fi
    }
    
    sshdir=/home/#{username}/.ssh

    if [ ! -d $sshdir ] ; then
      sudo mkdir -p $sshdir
    fi

    set_permissions $sshdir #{username} #{username} 700    

    
    authorized_keys=$sshdir/authorized_keys

    if [ ! -f $authorized_keys ] ; then
      touch $authorized_keys
    fi

    grep "#{identity}" $authorized_keys &> /dev/null
    if [ $? -ne 0 ] ; then
      echo "#{identity}" >> $authorized_keys
    fi

    set_permissions $authorized_keys #{username} #{username} 600

  EOF
end