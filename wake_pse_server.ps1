# PSE Vision Server - Wake-on-LAN Script
# MAC Address ของ Ubuntu server

$MAC = "C0:25:A5:CE:74:1A"
$IP = "10.1.100.255"  # Broadcast address

Write-Host "🔌 Sending Magic Packet to PSE Vision Server..." -ForegroundColor Cyan
Write-Host "   MAC: $MAC" -ForegroundColor White
Write-Host "   IP:  $IP" -ForegroundColor White

# Convert MAC to byte array
$MacByteArray = $MAC -split '[:-]' | ForEach-Object { [Byte] "0x$_" }

# Create Magic Packet (6 bytes of FF + 16 repetitions of MAC)
$MagicPacket = [Byte[]](,0xFF * 6) + ($MacByteArray * 16)

# Send UDP packet
$UdpClient = New-Object System.Net.Sockets.UdpClient
$UdpClient.Connect($IP, 9)
$UdpClient.Send($MagicPacket, $MagicPacket.Length) | Out-Null
$UdpClient.Close()

Write-Host "✅ Magic Packet sent successfully!" -ForegroundColor Green
Write-Host "⏰ Server should wake up in 5-10 seconds..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Waiting 10 seconds before testing connection..." -ForegroundColor Gray

Start-Sleep -Seconds 10

Write-Host "Testing connection..." -ForegroundColor Cyan
if (Test-Connection -ComputerName "10.1.100.78" -Count 2 -Quiet) {
    Write-Host "✅ Server is online!" -ForegroundColor Green
    Write-Host "You can now connect via Remote Desktop or SSH." -ForegroundColor White
} else {
    Write-Host "⏰ Server is still booting... Please wait 30 seconds and try again." -ForegroundColor Yellow
}
