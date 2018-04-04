$EsxHosts = Get-VMHost
foreach($EsxHost in $EsxHosts){
  $esxcli = Get-VMHost $EsxHost | Get-EsxCli -V2
  $esxcli.storage.nfs.remove.Invoke(@{volumename = 'Storage'}) 
}