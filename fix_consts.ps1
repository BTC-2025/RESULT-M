Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | Where-Object { $_.Name -ne "app_theme.dart" } | ForEach-Object {
    $content = Get-Content $_.FullName
    $changed = $false
    for ($i = 0; $i -lt $content.Length; $i++) {
        if ($content[$i] -match "context\.colors") {
            if ($content[$i] -match "const ") {
                # Replace 'const WidgetName(' with 'WidgetName('
                $content[$i] = [regex]::Replace($content[$i], 'const\s+([A-Z][a-zA-Z0-9_]*\()', '$1')
                $changed = $true
            }
        }
    }
    if ($changed) {
        Set-Content -Path $_.FullName -Value $content
        Write-Host "Fixed const in $($_.FullName)"
    }
}
