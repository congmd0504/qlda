$port = 8080
$root = 'C:\Users\congm\OneDrive\Desktop\test'
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://+:$port/")
$listener.Start()
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.PrefixOrigin -ne 'WellKnown' } | Select-Object -First 1).IPAddress
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Quiz server dang chay!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  May tinh : http://localhost:$port" -ForegroundColor Yellow
Write-Host "  Dien thoai: http://$($ip):$port" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Nhan Ctrl+C de tat server" -ForegroundColor Gray
Write-Host ""
$mime = @{'.html'='text/html; charset=utf-8';'.css'='text/css';'.js'='application/javascript';'.json'='application/json';'.png'='image/png';'.ico'='image/x-icon'}
while ($listener.IsListening) {
    try {
        $ctx = $listener.GetContext()
        $req = $ctx.Request
        $res = $ctx.Response
        $p = $req.Url.LocalPath.TrimStart('/')
        if ($p -eq '' -or $p -eq '/') { $p = 'index.html' }
        $fp = Join-Path $root $p
        Write-Host "$(Get-Date -Format 'HH:mm:ss') $p"
        if (Test-Path $fp -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($fp).ToLower()
            $mt = if ($mime[$ext]) { $mime[$ext] } else { 'application/octet-stream' }
            $b = [System.IO.File]::ReadAllBytes($fp)
            $res.ContentType = $mt
            $res.ContentLength64 = $b.Length
            $res.OutputStream.Write($b, 0, $b.Length)
        } else {
            $res.StatusCode = 404
            $b = [System.Text.Encoding]::UTF8.GetBytes('404 Not Found')
            $res.ContentLength64 = $b.Length
            $res.OutputStream.Write($b, 0, $b.Length)
        }
        $res.OutputStream.Close()
    } catch { }
}