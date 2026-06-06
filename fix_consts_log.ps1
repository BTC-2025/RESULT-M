$logFile = "C:\Users\ELCOT\.gemini\antigravity-ide\brain\74deb495-aacc-4a58-8a38-95eba413a17f\.system_generated\tasks\task-5646.log"
$lines = Get-Content $logFile

$fixes = @{}

foreach ($line in $lines) {
    if ($line -match "- invalid_constant" -or $line -match "- non_constant_list_element") {
        # Split by ' - '
        $parts = $line -split ' - '
        if ($parts.Length -ge 3) {
            $fileAndLine = $parts[$parts.Length - 2].Trim()
            $chunks = $fileAndLine -split ':'
            if ($chunks.Length -eq 3) {
                $filePath = $chunks[0]
                $lineNum = [int]$chunks[1]
                
                if (-not $fixes.ContainsKey($filePath)) {
                    $fixes[$filePath] = @()
                }
                $fixes[$filePath] += ($lineNum - 1)
            }
        }
    }
}

foreach ($key in $fixes.Keys) {
    if (Test-Path $key) {
        $contentLines = Get-Content $key
        $changed = $false
        
        foreach ($l in $fixes[$key]) {
            if ($l -ge 0 -and $l -lt $contentLines.Length) {
                # Look up to 5 lines up for 'const '
                $startIndex = $l
                $endIndex = [Math]::Max(0, $l - 5)
                
                for ($i = $startIndex; $i -ge $endIndex; $i--) {
                    if ($contentLines[$i] -match 'const ') {
                        $contentLines[$i] = $contentLines[$i] -replace 'const ', ''
                        $changed = $true
                        break
                    }
                }
            }
        }
        
        if ($changed) {
            Set-Content -Path $key -Value $contentLines
            Write-Host "Fixed constants in $key"
        }
    }
}
