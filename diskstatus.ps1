$global:VerbosePreference = "Continue"
$disk=$args[0]


$tempfile = [System.IO.Path]::GetTempFileName()
New-Item $tempfile –itemtype file –force | OUT-NULL
ADD-CONTENT –path $tempfile "LIST DISK"
$LISTDISK=(DISKPART /S $tempfile)
$TOTALDISK=($LISTDISK.Count)-8
Remove-Item $tempfile
$Disks = @{}

for ($d=0;$d -le $TOTALDISK;$d++)
{
    $SIZE=$LISTDISK[-1-$d].substring(25,9).replace(" ","") 
#    Write-Verbose $SIZE 
    $DISKID=$LISTDISK[-1-$d].substring(1,8).replace(" ","")
#    Write-Verbose $DISKID
    $DISKSTATUS=$LISTDISK[-1-$d].substring(12,6).trim()
#    Write-Verbose $DISKSTATUS
    $Disks.Add($DISKID, $DISKSTATUS)
}

If ($args[0]) {
    If ($Disks.ContainsKey($args[0])){
        If ($Disks.Get_Item($args[0]) -eq 'В сети' -or $Disks.Get_Item($args[0]) -eq 'Online'){
            Write-Host 1
        }Else{
            Write-Host 0
        }
    }else{
        Write-Host "ZBX_NOTSUPPORTED"
    }
    
}Else{
    $idx = 0
    write-host "{"
    write-host """data"":["
    Foreach ($kvp in $Disks.GetEnumerator() | sort name){
        If ($idx -lt $TOTALDISK)
        {
            $line= "{ ""{#DISKNUM}"" : """ + $kvp.key + """ },"
            write-host $line
        }Else{
            $line= "{ ""{#DISKNUM}"" : """ + $kvp.key + """ }"
            write-host $line
        }
        $idx++
    }
    write-host
    write-host " ]"
    write-host "}"
}
