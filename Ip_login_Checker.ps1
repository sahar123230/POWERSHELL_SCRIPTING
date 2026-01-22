
function IpCheck($ip){

	$body = @{'fields' = 'status,proxy'}

	$ipInfo = Invoke-RestMethod -Uri "http://ip-api.com/json/$ip/" -Body $body
		
	if ($ipInfo.proxy -eq 1) {
		Write-Output "IP address $ipAddress has been marked as malicious!"
		sendMail("Logged In IP address $ipAddress has been marked as malicious!")
	} else {
			Write-Output "IP address $ipAddress has been marked as clean!"
		
	}
}


function sendMail($message) {

	$smtpServer = "smtp.letsdefend.io"
	$smtpUser = "labuser"
	$smtpPassword = "**********"

	$from = "alerter@letsdefend.io"
	$to = "admin@letsdefend.io"

	$smtpCred = New-Object System.Management.Automation.PSCredential -ArgumentList $smtpUser, $($smtpPassword | ConvertTo-SecureString -AsPlainText -Force)
			
	Send-MailMessage -SmtpServer $smtpServer -From $from -To $to -Subject $subject -Body $body -Credential $smtpCred -UseSsl
}



$events = Get-WinEvent -FilterHashtable @{Logname='Security';ID=4624;StartTime=(Get-Date).AddHours(-1)}
foreach ($event in $events) {

	$eventXML = [xml]$event.ToXml()


	$ipAddress = $eventXML.Event.EventData.Data | Where-Object {$_.Name -eq 'IpAddress'} | Select-Object -ExpandProperty '#text'
	$userName = $eventXML.Event.EventData.Data | Where-Object {$_.Name -eq 'TargetUserName'} | Select-Object -ExpandProperty '#text'


	try {
		$ipBytes = [System.Net.IPAddress]::Parse($ipAddress).GetAddressBytes()
		if ($ipBytes[0] -eq 10) {
			# This is Local Block, Do Nothing
			continue
		}
		elseif ($ipBytes[0] -eq 172 -and $ipBytes[1] -ge 16 -and $ipBytes[1] -le 31) {
			# This is Local Block, Do Nothing
			continue
		}
		elseif ($ipBytes[0] -eq 192 -and $ipBytes[1] -eq 168) {
			# This is Local Block, Do Nothing
			continue
		}
		else {
			# This is Real IP
			Write-Output "User $userName has logged in from external IP address $ipAddress"
			ipCheck ($ipAddress)
		}
	}
	catch {
		# This is Local Login Success
		continue
	}
}
