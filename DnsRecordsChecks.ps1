# **************************************************************************************************
# DnsRecordsChecks : Script permettant de tester la résolution DNS d'un FQDN depuis son réseau interne ET externe
# Version 1.0.0
# Auteur : Damien CASSU
# Commentaire : Pour pouvoir exécuter le script => Set-ExecutionPolicy RemoteSigned -Scope Process
# **************************************************************************************************

#Constantes
$EXTERNAL_DNS_SERVER = "8.8.8.8"
$SCRIPT_NAME = "DnsRecordsChecks"
$SCRIPT_VERSION ="1.0.0"

#Variables
$InternalDnsServer = ""
$IsNewDnsRequestWanted = "Y"

#Message lancement script
Write-Host "####### $SCRIPT_NAME Version $SCRIPT_VERSION is starting #######"


#Récupération IP serveur DNS réseau interne 
$NetworkInterfacesList = Get-DnsClientServerAddress -AddressFamily IPv4
Foreach ($interface in $NetworkInterfacesList) {
    if($interface.ServerAddresses -ne "") {
      $InternalDnsServer = $interface.ServerAddresses
      break 
    }
    
}

#Si pas de DNS interne - fin programme
if ($InternalDnsServer -eq "") {
    Write-Host -ForegroundColor Red "[ERROR] - No internal DNS found - Exiting"
    exit
}

#Boucle vérification DNS
do {
   $Fqdn = Read-Host "Please enter the FQDN to check : "
   Write-Host "`n`r"
    
   Write-Host -NoNewline "Checking "
   Write-Host -ForegroundColor Green -NoNewline $Fqdn 
   Write-Host -NoNewline " IP address using " 
   Write-Host -NoNewline -ForegroundColor Green "INTERNAL DNS SERVER "  
   Write-Host "($InternalDnsServer)"
   try {
        Resolve-DnsName -ErrorAction Stop -Name $Fqdn -Type A -DnsOnly -NoHostsFile -Server $InternalDnsServer 
    } catch {
        Write-Host -ForegroundColor Yellow "[WARNING] - $($_.Exception.Message)"
   }
   Write-Host "`n`r"
   
   Write-Host -NoNewline "Checking "
   Write-Host -ForegroundColor Green -NoNewline $Fqdn 
   Write-Host -NoNewline " IP address using " 
   Write-Host -NoNewline -ForegroundColor Green "EXTERNAL DNS SERVER " 
   Write-Host "($EXTERNAL_DNS_SERVER)"
   
   try {
        Resolve-DnsName -ErrorAction Stop -Name $Fqdn -Type A -DnsOnly -NoHostsFile -Server $EXTERNAL_DNS_SERVER  
   } catch {
        Write-Host -ForegroundColor Yellow "[WARNING] - $($_.Exception.Message)"
   }  
   Write-Host "`n`r"


   #Boucle choix utilisateur
   do {
        $IsNewDnsRequestWanted = Read-Host "Do you want to run another search ? [Y/N] "
   } while (($IsNewDnsRequestWanted -cne "Y") -and ($IsNewDnsRequestWanted -cne "N"))
   
} until ($IsNewDnsRequestWanted -ceq "N")



