
# Slack webhook URL and VirusTotal API key values
$slackWebhookUrl = ""
$virusTotalApiKey = ""


# Get running process list
$processes = Get-Process

# Start Foreach loop for process list
$results = foreach ($process in $processes) {
    # Find current process path
	$filePath = $process.MainModule.FileName
		
		
	if ($filePath) {
		# Calculate Hash Value with SHA256 Algorithm
		$hash = Get-FileHash -Path $filePath -Algorithm SHA256
		# Add FileName,Path and Hash values into PSObject
		[PSCustomObject]@{
			'Process Name' = $process.Name
			'File Path' = $filePath
			'SHA256 Hash' = $hash.Hash
		}
	}
}

# Groups array by SHA256 hash value and returns only unique values
$results | Group-Object -Property 'SHA256 Hash' | ForEach-Object {
	$_.Group | Select-Object -First 1
}

foreach ($result in $uniqueResults) {
	$hash = $result.'SHA256 Hash'
	# VirusTotal Hash Control
	$vtResponse = Invoke-RestMethod -Method 'Get' -Uri "https://www.virustotal.com/api/v3/files/$hash" -Headers @{"x-apikey" = $virusTotalApiKey}
	if ($vtResponse.data.attributes.last_analysis_stats.malicious -gt 0) {
		# If mailicus found, send to slack via webhook
		$slackMessage = @{
			text = "Suspicius Process Found! Process Name: $($result.'Process Name'), Executable Path: $($result.'File Path'), SHA256 Hash: $hash"
		}
		Invoke-RestMethod -Method 'Post' -Uri $slackWebhookUrl -Body (ConvertTo-Json -InputObject $slackMessage)
	}
}
