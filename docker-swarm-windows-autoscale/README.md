# docker-swarm-windows-autoscale

Create a Windows Server 2016 Docker Swarm with a single manager and a worker scale set confgured to autoscale

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FRedPointCR%2Fazure-templates%2Fmaster%2Fdocker-swarm-windows-autoscale%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FRedPointCR%2Fazure-templates%2Fmaster%2Fdocker-swarm-windows-autoscale%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a Windows Server 2016 Docker Swarm. The swarm is deployed to a vnet and consists of: 
 * a single manager 
 * two worker nodes in a scaleset (configured to autoscale based on CPU load)
 * a load balancer (with a single rule to load balance port 80 across the scaleset)

The load balancer front end IP is internal to the vNet and not exposed externally. 
The only externally exposed port is 3389 to the swarm manager.

(https://raw.githubusercontent.com/RedpointCR/azure-templates/master/docker-swarm-windows-autoscale/docker-windows-swarm-autoscale.png)

