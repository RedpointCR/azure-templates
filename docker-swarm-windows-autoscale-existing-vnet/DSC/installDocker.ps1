Configuration ContainerHostDsc
{
    param(
        [string]$masterIP,
        [string]$dockerVersion="1.13.1-cs1",
        [string]$insecureRegistry,
        [string]$dockerConfig = 'C:\ProgramData\Docker\config\daemon.json',
        [ValidateSet('manager','worker')]
        [string]$nodeType
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $AllNodes.NodeName {
  	
    # Install Docker and reboot if the service does not already exist  
    Script InstallDocker
    {
            SetScript = {
                Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
		        Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
		        Install-Module -Name DockerMsftProvider -Force
		        Install-Package -Name docker -ProviderName DockerMsftProvider -RequiredVersion $using:dockerVersion
                Restart-Computer -force
            }
            GetScript = {
                return @{
                    'Service' = (Get-Service -Name Docker).Name
                }
            }
            TestScript = {
                if (Get-Service -Name Docker -ErrorAction SilentlyContinue) {
                    return $True
                }
                return $False
            }
            DependsOn = @()
    }
    # Configure Docker to listen on port 2375, add insecure registry if specified, open windows firewall ports and restart service
    Script ConfigDocker
    {
            SetScript = {
            $daemonFile = $using:dockerConfig
            $daemonConfig = New-Object psobject -Property @{"hosts"=@("tcp://0.0.0.0:2375", "npipe://")}
            if (($using:insecureRegistry)) {$daemonConfig | add-member -membertype NoteProperty -Name 'insecure-registries' -Value @($($using:insecureRegistry + ':5000')) }
            mkdir -Path c:\programdata\docker\config -force
            set-content $daemonFile ($daemonConfig | convertto-json -depth 5)       
            netsh advfirewall firewall add rule name="Docker swarm-mode cluster management TCP" dir=in action=allow protocol=TCP localport=2375
            netsh advfirewall firewall add rule name="Docker swarm-mode cluster management TCP2377" dir=in action=allow protocol=TCP localport=2377
            netsh advfirewall firewall add rule name="Docker swarm-mode node communication TCP" dir=in action=allow protocol=TCP localport=7946
            netsh advfirewall firewall add rule name="Docker swarm-mode node communication UDP" dir=in action=allow protocol=UDP localport=7946
            netsh advfirewall firewall add rule name="Docker swarm-mode overlay network TCP" dir=in action=allow protocol=TCP localport=4789
            netsh advfirewall firewall add rule name="Docker swarm-mode overlay network UDP" dir=in action=allow protocol=UDP localport=4789
            Restart-Service Docker
            }
            GetScript = {
                return @{
                    'Docker Version' = $(docker --version)
                }
            }
            TestScript = {
                if (get-content $using:dockerConfig -ea 0) {
                    return $True
                }
                return $False
            }
            DependsOn = @('[Script]InstallDocker')
    }

    Service DockerService
    {
            Name        = "Docker"
            State       = "Running"
    } 
    # Initialize a new swarm if not already created
    Script InitSwarm
    {
            SetScript = {
                if (! ($(docker -H $using:masterIP info) | Select-String 'Managers') ) {
                    docker -H $using:masterIP swarm init --advertise-addr $using:masterIP --listen-addr $using:masterIP
                }
            }
            GetScript = {
                return @{
                    'Docker Version' = $(docker --version)
                }
            }
            TestScript = {
                if ($(docker -H $using:masterIP info) | Select-String 'Managers') {
                    return $True
                }
                return $False
            }
            DependsOn = @('[Service]DockerService')
    }
    # If a swarm exists, retrive the appropriate join token and join it
    Script JoinSwarm
    {
            SetScript = {
                if (! ($(docker info) | Select-String 'NodeID') ) {
                    $token = docker -H $using:masterIP swarm join-token -q $using:nodeType 
                    docker swarm join --token $token $($using:masterIP + ':2377')
                }
            }
            GetScript = {
                return @{
                    'Docker Version' = $(docker --version)
                }
            }
            TestScript = {
                if (($(docker info) | Select-String 'NodeID') ) {
                    return $True
                }
                return $False
            }
            DependsOn = @('[Script]InitSwarm')
    }
  }
}

# Configure the LCM
Configuration ConfigureLCM
{
   Node $AllNodes.NodeName {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            RefreshMode = 'Push'
            ConfigurationMode = 'ApplyAndAutoCorrect'
	          ActionAfterReboot = 'ContinueConfiguration'
        }
    }
}

# Configuration Data
$ConfigData = @{
	  AllNodes = @(
		    @{
			      NodeName                    = 'localhost'
		    }
	  )
}

# Compile the LCM Config
ConfigureLCM `
	  -OutputPath . `
	  -ConfigurationData $ConfigData

# Apply the LCM Config
Set-DscLocalConfigurationManager `
	  -Path .\ConfigureLCM\ `
	  -ComputerName Localhost `
	  -Verbose

# Compile the Node Config
ContainerHostDsc `
	  -OutputPath . `
	  -ConfigurationData $ConfigData

# Apply the DSC Configuration
Start-DscConfiguration `
	  -Path .\ContainerHostDsc\ `
	  -ComputerName Localhost `
	  -Wait `
	  -Force `
	  -Verbose
