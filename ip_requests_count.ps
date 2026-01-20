# log file location
$filePath = "LOG_FILE.log"

# Get 'c-ip' (client IP) field index from log file header
$ipFieldIndex = (Get-Content -Path $filePath | Where-Object { $_ -match "^#Fields:" }).Split(' ').IndexOf('c-ip') -1

# Skip informational lines
$logContent = Get-Content -Path $filePath | Where-Object { $_ -notmatch "^#" }

$ipCount = @{}

foreach($line in $logContent) {
	$ip = $line.Split(' ')[
$ipFieldIndex
]
	if ($ipCount.ContainsKey($ip)) {
		$ipCount[$ip]++
	} else {
		$ipCount[$ip] = 1
	}
}

$ipCount
