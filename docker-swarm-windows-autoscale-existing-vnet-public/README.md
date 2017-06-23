# docker-swarm-windows-autoscale-existing-vnet-public

Create a Windows Server 2016 Docker Swarm with a single manager and a worker scale set confgured to autoscale. 
### This template is the same as https://github.com/RedpointCR/azure-templates/tree/master/docker-swarm-windows-autoscale-existing-vnet except it exposes the swarm with a public IP

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FRedPointCR%2Fazure-templates%2Fmaster%2Fdocker-swarm-windows-autoscale-existing-vnet-public%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FRedPointCR%2Fazure-templates%2Fmaster%2Fdocker-swarm-windows-autoscale-existing-vnet-public%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a Windows Server 2016 Docker Swarm. The swarm consists of: 
 * a single Docker manager node 
 * two worker nodes in a scaleset (configured to autoscale based on CPU load)
 * a load balancer (with a single rule to load balance port 80 across the scaleset)

The load balancer front end IP is internal to the vNet and not exposed externally. 

Deployment requires filling in the admin username and password parameters as well as the following info about the existing vNet:
 * vnetName
 * subnetName
 * managerNSG - the NSG that the manager node will be attached to. No rules are created.
 * managerPrivateIP - the static private IP to assign to the Swarm manager. Pick one that's not in use
 * loadBalancerDNSname - the hostname portion of the DNS name for the loadBalancer

See https://github.com/RedpointCR/azure-templates/tree/master/docker-swarm-windows-autoscale for a description of other parameters.

![Deployment Overview - Windows Swarm](https://raw.githubusercontent.com/RedpointCR/azure-templates/master/docker-swarm-windows-autoscale-existing-vnet-public/docker-windows-swarm-autoscale.png)


