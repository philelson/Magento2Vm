#
# author phil@pegasus-commerce.com
#
# Github key 6bc03fa6185ff8c59097157a283741cc85650cd4
#
Vagrant.configure("2") do |config|
	# All Vagrant configuration is done here. The most common configuration
  	# options are documented and commented below. For a complete reference,
  	# please see the online documentation at vagrantup.com.
  	# Every Vagrant virtual environment requires a box to build off of.
  	# This is an ubuntu environment, needs to be changed to redhat at some point
  	config.vm.box = "centos/7"

    # Assign this VM to a host-only network IP, allowing you to access it
    # via the IP. Host-only networks can talk to the host machine as well as
    # any other machines on the same network, but cannot be accessed (through this
    # network interface) by any external networks.
  	config.vm.network :private_network, ip: "11.10.2.200"
  
  	# We are simply provisioning the environment via a shell script. 
  	# This includes apache, PHP, MySQL, vhosts and downloading and installed the latest DB
  	config.vm.provision :shell, :path => "bootstrap.sh"
  
  	# Current directory this of vagrant file is to be mounted on the guest machine
  	# in /var/www/b2c (same path which is in the vhosts)
  	config.vm.synced_folder ".", "/var/www", type: "nfs"

  	# Create a forwarded port mapping which allows access to a specific port
  	# within the machine from a port on the host machine. In the example below,
  	# accessing "localhost:8080" will access port 80 on the guest machine.
  	# Note if the site you're after isn't working correctly, update core_config_data 
  	# URL's to include 8080 in the URL.
  	# See .vagrant/bootstrap.sh for more information.
  	config.vm.network :forwarded_port, guest: 80, host: 8080

	#VM with 1GB of RAM
  	config.vm.provider :virtualbox do |vb|
  		vb.customize 	["modifyvm", :id, "--cpuexecutioncap", "90"]
    	vb.customize 	["modifyvm", :id, "--memory", "4096"]
    	vb.customize 	["modifyvm", :id, "--cpus", "1"]
  	end
  
  	#Configuring the host vhosts
  	config.hostmanager.enabled = true
  	config.hostmanager.manage_host = true
  	config.hostmanager.ignore_private_ip = true
  	config.hostmanager.include_offline = true
  	config.vm.define 'magento2' do |node|
    	node.vm.hostname = 'magento2.dev'
    	node.hostmanager.aliases = %w(magento2.dev)
  	end
end
