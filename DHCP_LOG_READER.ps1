$macAddress = "MAC-ADDRESS"
$logPath = "dhcp.log"

$events = Get-Content -Path $logPath |
Where-Object { $_ -match $macAddress } |
ForEach-Object {
	$fields = $_.Split(',')
	$eventDate = [DateTime]::ParseExact($fields[1], "MM/dd/yy HH:mm:ss", $null)
	$eventType = $fields[2]
	$ipAddress = $fields[3]
	$deviceName = $fields[4]
	$mac = $fields[
5
]

	if ($mac -eq $macAddress) {
		New-Object -TypeName PSObject -Property @{
			EventDate = $eventDate
			EventType = $eventType
			IPAddress = $ipAddress
			DeviceName = $deviceName
			MACAddress = $mac
			}
		}
}

$events | Sort-Object -Property EventDate
