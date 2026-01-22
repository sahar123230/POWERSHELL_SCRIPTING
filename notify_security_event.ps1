
# SMTP Server Settings
$smtpServer = "smtp server"
$smtpUser = "USRR"
$smtpPassword = "**********"

# Sender and Recipient Mail Addresses
$from = "MAIL"
$to = "MAIL"

# Determine Start Time
$lastHour = (Get-Date).AddHours(-1)

# EventID and Threshold List
$eventLimits = @{4625=10; 4648=5; 4703=3; 1102=1; 7045=2}

#ControlEvents
foreach ($entry in $eventLimits.GetEnumerator()) {
	$id = $entry.Key
	$limit = $entry.Value
	$events = Get-WinEvent -FilterHashtable @{Logname='Security'; ID=$id; StartTime=$lastHour}
	if ($events.Count -gt $limit) {
		$subject = "Alert: Detected Event ID $id"
		$body = "Detected $($events.Count) instances of event ID $id on the following system: $($events[0].MachineName) at $($events[0].TimeCreated)"
				
		# Generate SMTP credentials
		$smtpCred = New-Object System.Management.Automation.PSCredential -ArgumentList $smtpUser, $($smtpPassword | ConvertTo-SecureString -AsPlainText -Force)
				
		# Send email notification
		Send-MailMessage -SmtpServer $smtpServer -From $from -To $to -Subject $subject -Body $body -Credential $smtpCred -UseSsl
	}
}
