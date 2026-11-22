@echo off
setlocal
title BAMBU 0.5.9 - LIBERAR COMANDO CONFIGURAR
set "BAMBU_SCRIPT=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$t=[IO.File]::ReadAllText($env:BAMBU_SCRIPT);$m='# BAMBU_LIBERAR_OP_PS';$i=$t.LastIndexOf($m);if($i -lt 0){throw 'Marcador nao encontrado'};& ([scriptblock]::Create($t.Substring($i+$m.Length)))"
echo.
pause
exit /b

# BAMBU_LIBERAR_OP_PS
$ErrorActionPreference = 'Stop'
$server = Join-Path $env:APPDATA 'BAMBU Estudio Launcher Teste\mapas\parkour-paradise-3\servidor-mine\servidor'
$cache = Join-Path $server 'usercache.json'
$ops = Join-Path $server 'ops.json'
$nick = 'brunexttk'
try {
 Write-Host '================================================' -ForegroundColor Cyan
 Write-Host ' BAMBU 0.5.9 - LIBERAR /tparkour configurar' -ForegroundColor Cyan
 Write-Host '================================================' -ForegroundColor Cyan
 Write-Host ('Servidor: ' + $server)
 if (-not (Test-Path -LiteralPath (Join-Path $server 'plugins') -PathType Container)) {
   throw 'Pasta do servidor BAMBU nao encontrada. Nenhuma alteracao foi feita.'
 }
 if (-not (Test-Path -LiteralPath $cache -PathType Leaf)) {
   throw 'usercache.json nao encontrado. Entre no servidor como brunexttk, saia, feche o servidor e tente novamente.'
 }
 $players = @((Get-Content -LiteralPath $cache -Raw -Encoding UTF8 | ConvertFrom-Json))
 $player = @($players | Where-Object { $_.name -ieq $nick } | Select-Object -First 1)
 if ($player.Count -ne 1 -or -not $player[0].uuid) {
   throw 'Jogador brunexttk nao aparece no usercache.json deste BAMBU. Entre no jogo com esse nome, saia, feche o servidor e tente novamente.'
 }
 $uuid=[string]$player[0].uuid
 if ($uuid -notmatch '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$') {
   throw 'UUID do usuario invalido no usercache.json. Abortado.'
 }
 Write-Host ('Jogador localizado: ' + $nick + ' / ' + $uuid) -ForegroundColor Green
 Write-Host ''
 Write-Host 'ATENCAO: OP concede PERMISSAO DE ADMINISTRADOR nesse servidor Minecraft.' -ForegroundColor Yellow
 Write-Host 'Feche BAMBU e Minecraft antes de continuar.' -ForegroundColor Yellow
 $ok=Read-Host 'Digite SIM para conceder OP ao brunexttk'
 if($ok -cne 'SIM'){Write-Host 'Cancelado. Nenhuma alteracao feita.';exit 0}
 $items=@()
 if(Test-Path -LiteralPath $ops -PathType Leaf){
   $raw=[IO.File]::ReadAllText($ops)
   if($raw.Trim()){
     $parsed=$raw | ConvertFrom-Json
     if($null -ne $parsed){$items=@($parsed)}
   }
   $backup=$ops+'.bak-'+(Get-Date -Format 'yyyyMMdd_HHmmss')
   Copy-Item -LiteralPath $ops -Destination $backup -ErrorAction Stop
   Write-Host ('Backup criado: '+$backup) -ForegroundColor Green
 }
 $found=$false
 foreach($entry in $items){
   if(([string]$entry.uuid) -ieq $uuid -or ([string]$entry.name) -ieq $nick){
     $entry.uuid=$uuid
     $entry.name=$nick
     $entry.level=4
     $entry.bypassesPlayerLimit=$false
     $found=$true
   }
 }
 if(-not $found){
   $items+= [pscustomobject]@{uuid=$uuid;name=$nick;level=4;bypassesPlayerLimit=$false}
 }
 $json=ConvertTo-Json -InputObject @($items) -Depth 6
 if(-not $json.TrimStart().StartsWith('[')){throw 'Falha de validacao: ops.json nao esta em formato de lista.'}
 $utf8=New-Object System.Text.UTF8Encoding($false)
 [IO.File]::WriteAllText($ops,$json,$utf8)
 Write-Host ''
 Write-Host '[OK] brunexttk agora tem OP no servidor BAMBU 0.5.9.' -ForegroundColor Green
 Write-Host 'Abra BAMBU, entre no Minecraft e digite /tparkour configurar' -ForegroundColor Cyan
 Write-Host 'Para remover OP depois, use o comando deop brunexttk no console ou reverta o backup.' -ForegroundColor Yellow
} catch {
 Write-Host ('[ERRO] '+$_.Exception.Message) -ForegroundColor Red
 exit 1
}
