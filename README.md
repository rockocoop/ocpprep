Openshift on prem deployment playbooks:

Below is the procedure for running a disconnected install.  

Sample inventory file is under inventories/inventory_os


Prerequisites:
1. Collect the images in the vars/image_list.yml and import to local docker registry
2. Setup local yum repo with the following repos (under "repos" directory):

  rhel-7-server-rpms

  rhel-7-server-extras-rpms

  rhel-7-server-ansible-2.6-rpms
		
  rhel-7-server-ose-3.11-rpms
3. Deploy/Setup the RHEL 7.6 Machines that you will be using for your cluster and set IP address


Procedure:
1. Login to the deployer machine where you will run the playbooks from
2. Copy the playbooks/templates/setup_internal_repos.yml file to /etc/yum.repos.d/ocp.repo and update the {{ yumrepo_url}} 
   with the IP of the internal repo
3. Install ansible
   yum install ansible -y
4. Insure ssh connection to all instances without login by sharing ssh keys (ssh-copy-id)
5. Update inventory file with desired parameters
6. Run pre-install.yml
   
   cd ocpprepost/playbooks

   ansible-playbook -i inventory pre-install.yml

7. Install openshfit-ansible on deployer:

   sudo yum install openshift-ansible -y

8. Run the installation playbooks:

   cd /usr/share/ansible/openshift-ansible
  
   ansible-playbook -i inventory  playbooks/prerequisites.yml
  
   ansible-playbook -i inventory playbooks/deploy_cluster.yml

9. Run post-jobs.yml
   
   cd ocpprepost/playbooks

   ansible-playbook -i inventory post-jobs.yml

############################################################

Playbooks Details:

pre-install.yml:
- Sets up yum repo configuration to point to internal repo
- Sets ntp
- Sets dns
- Updates hosts file
- Installs docker (including storage on separate disk)
- Sets internal docker registry as insecure in daemon.json
- Sets up etcd storage on separate disk (optional)
- Install support packages
- Sets hostname
- Sets keepalived VIP in front of LBs (optional)

post-jobs.yml:
- Adds cluster data store to external grafana server



Additional parameters in inventory file for this playbook are as follows:

Under all:vars 
- dns = uncomment and add a list of dns servers (optional)
- searchdomain = default search domain to add to resolv.conf
- ntp = uncomment and add a list of ntp servers (optional)
- openshift_docker_insecure_registries = set docker registry IP
- yumrepo_url = set the IP for the internal yum repo
- buildhosts = sets if to update the hosts file on the servers.  valid values are true or false

############################
(Optional) In the case of using 2 internal load balancers, you can use the following parameters to 
deploy keepalived VIP in front of them.  If not then comment them out

- keepalived_vip = virtual floating ip to be used 
- keepalived_interface = interface on the loadblancers to be used (ie. eth0)
- keepalived_vrrpid = random unique integer
############################


Following are for adding the cluster to external Grafana Server as part of the 
post-jobs.yml. (Optional)
- grafanaURL= full grafana URL (ie. http://10.142.15.244:3000)
- grafanaPass = grafana admin password
- grafanaClusterName =  desired data source name as it will appear in grafana
- grafmas = FQDN of one of the master nodes
- prometheusURL = URL of prometheus route as given in oc get routes command under openshift-monitoring project.
                  Must be routable to an infra node running the router.

Under OSEv3
- oreg_url: set the IP for the internal docker registry

Under Each host entry:
- hostname = sets the hostname

Under node:vars
- pv_device = Sets the extra disk to be used for docker storage. (ie. sdb)

Under etcd:vars
- pv_etcd = value under etcd:vars. Sets the extra disk to be used for etcd storage (ie. sdc) (optional)



###########################################

Online Option

In order to use this deployment option with the RHEL online registries do the following:
1. Comment out the yumrepo_url param
2. Add the following parameters to the all section of the inventory file and populate the values
- rheluser
- rhelpass
- rhelpool
3. Add the following with in the OSEv3 section
- oreg_auth_password
- oreg_auth_user
4. Run procedure as above
