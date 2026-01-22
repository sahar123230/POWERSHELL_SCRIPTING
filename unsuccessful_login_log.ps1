# Set Username
$username = "USER"
# Set start and end dates
$startDate = Get-Date "DATE"
$endDate = Get-Date "DATE"

# Get 4625 Events into HashTable
$events = Get-WinEvent -FilterHashTable @{
	LogName = 'Security'
	ID = 4625
	StartTime = $startDate
	EndTime = $endDate
}

# Print data to screen
foreach ($event in $events) {
	$xml = [xml]$event.ToXml()
	$eventUsername = $xml.Event.EventData.Data | Where-Object {$_.Name -eq 'TargetUserName'} | Select-Object -ExpandProperty '#text'
	if ($eventUsername -eq $username) {
		Write-Host "User 
$username
, Login Date: 
$
(
$event
.TimeCreated)"
		}
}
