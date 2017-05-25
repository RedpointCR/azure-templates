# docker-swarm-windows-autoscale

Create a Windows Server 2016 Docker Swarm with a single manager and a worker scale set confgured to autoscale

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FRedPointCR%2Fazure-templates%2Fmaster%2Fdocker-swarm-windows-autoscale%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FRedPointCR%2Fazure-templates%2Fmaster%2Fdocker-swarm-windows-autoscale%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a Windows Server 2016 Docker Swarm. The swarm is deployed to a vnet and consists of: 
 * a single Docker manager node 
 * two worker nodes in a scaleset (configured to autoscale based on CPU load)
 * a load balancer (with a single rule to load balance port 80 across the scaleset)

The load balancer front end IP is internal to the vNet and not exposed externally. 
The only externally exposed port is 3389 to the swarm manager.

Deployment is as simple as filling in the admin username and password parameters. See below for a description of other parameters.

![Deployment Overview - Windows Swarm](https://raw.githubusercontent.com/RedpointCR/azure-templates/master/docker-swarm-windows-autoscale/docker-windows-swarm-autoscale.png)


### Template Parameters
 * _artifactsLocation - URL to the template
 * _artifactsLocationSasToken - blank when deploying from Github. Only used if the template is in an Azure Storage Account
 * powerShellDscZip - relative URL for the DSC zip file
 * vmSize - A valid Azure VM size. You must use a size that supports managed disks and premium storage
 * maxWorkers - the maximum number of instances in the scaleset
 * scaleUpCPUThreshold - when the CPU utilization of the scale set reaches this value, additional nodes will be added
 * scaleUpCount - the number of nodes to add when scale up is triggered

### Scaleset Defaults

The scaleset is configured for a minimum of 2 nodes. The maximum defaults to 4, and the scaleUpCount is 2. This causes the scale set to max itself out when scale up is triggered. In practice, nodes take ~10 minutes to join the swarm once scale up is triggered.

Nodes are automatically scaled down one at a time every 5 minutes while the CPU usage stays below 60%.

### Docker configuration

Docker configuration is accomplished using PowerShell DSC scripts. DSC will:
 * Install Docker if not installed
 * Configure the Docker daemon to listen on port 2375 (and restart the service)
 * Initialize a swarm
 * Join N managers and N workers to the swarm