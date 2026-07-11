Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | Where-Object { $_.Name -ne "app_theme.dart" } | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match "AppColors\.") {
        $newContent = $content -replace "AppColors\.", "context.colors."
        Set-Content -Path $_.FullName -Value $newContent
        Write-Host "Updated $($_.FullName)"
    }
}
