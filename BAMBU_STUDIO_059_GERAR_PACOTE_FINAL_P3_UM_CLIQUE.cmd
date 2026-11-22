@echo off
setlocal
title BAMBU STUDIO 0.5.9 RC10 - GERAR PACOTE FINAL PARADISE 3
set "BAMBU_FINAL_SCRIPT=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$s=[IO.File]::ReadAllText($env:BAMBU_FINAL_SCRIPT);$m='# CODIGO_GERADOR_BAMBU_FINAL_2026';$p=$s.LastIndexOf($m);if($p -lt 0){throw 'Erro: codigo nao localizado'};& ([scriptblock]::Create($s.Substring($p+$m.Length)))"
echo.
echo Pressione uma tecla para fechar.
pause >nul
exit /b

# CODIGO_GERADOR_BAMBU_FINAL_2026
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$version='BAMBU_STUDIO_0_5_9_RC10_PARKOUR_PARADISE_3_FINAL'
$appSource=Join-Path $env:USERPROFILE 'Downloads\BAMBU_STUDIO_059_RC10_GULIVE_MOTOR_CORRIGIDO\BAMBU_STUDIO_0_5_9_PORTATIL_INTERFACE_INTEGRADA'
$serverSource=Join-Path $env:APPDATA 'BAMBU Estudio Launcher Teste\mapas\parkour-paradise-3\servidor-mine\servidor'
$desktop=[Environment]::GetFolderPath('Desktop')
if(-not $desktop -or -not(Test-Path -LiteralPath $desktop -PathType Container)){$desktop=Join-Path $env:USERPROFILE 'Downloads'}
$destZip=Join-Path $desktop ($version+'.zip')
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
$stagingRoot=Join-Path $env:TEMP ('BAMBU_FINAL_BUILD_'+$stamp)
$staging=Join-Path $stagingRoot $version
$appDest=Join-Path $staging 'BAMBU_STUDIO'
$mapDest=Join-Path $staging 'MAPA_PARADISE_3_BASE'
$expected='201656BC3CB0462D96BB6E1FDCAEA62417D704168CD3B051CF8C0F3CF1A1F8FF'
function Note([string]$msg,[string]$c='Gray'){Write-Host $msg -ForegroundColor $c}
function Hash([string]$p){(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash}
function RobocopyChecked([string]$a,[string]$b,[string[]]$more){
 $args=@($a,$b,'/E','/R:2','/W:1','/NP','/NFL','/NDL','/NJH','/NJS','/COPY:DAT','/DCOPY:DAT')+$more
 & robocopy.exe @args | Out-Null
 if($LASTEXITCODE -ge 8){throw ('Falha ao copiar arquivos (robocopy codigo '+$LASTEXITCODE+'): '+$a)}
}
try{
 Note '=================================================================' 'Cyan'
 Note ' BAMBU STUDIO 0.5.9 RC10 - GERACAO FINAL / PARADISE 3' 'Cyan'
 Note ' Cria ZIP COMPLETO da versao que ja funcionou no Minecraft' 'Cyan'
 Note '=================================================================' 'Cyan'
 Note ''
 if(-not(Test-Path -LiteralPath $appSource -PathType Container)){
   throw ('Pasta da versao funcional nao encontrada: '+$appSource)
 }
 if(-not(Test-Path -LiteralPath $serverSource -PathType Container)){
   throw ('Servidor Paradise 3 nao encontrado: '+$serverSource)
 }
 $engine=Join-Path $appSource 'resources\app\engine'
 $jar=Join-Path $engine 'bambu-paradise3-v6-source.jar'
 $hook=Join-Path $engine 'bambu-paradise3-v6-hook.cjs'
 $main=Join-Path $engine 'servidor.cjs'
 $asset=Join-Path $engine 'hud-layout-assets\custom-parkour-tiktok-hud-bambu.jar'
 $sourceWorld=Join-Path $serverSource 'world\level.dat'
 foreach($f in @($jar,$hook,$main,$asset,$sourceWorld)){
   if(-not(Test-Path -LiteralPath $f -PathType Leaf)){throw ('Arquivo necessario AUSENTE: '+$f)}
 }
 if(-not([IO.File]::ReadAllText($main).Contains('BAMBU-PARADISE3-V6'))){
   throw 'O motor nao contem a integracao Paradise 3 V6 que passou no teste.'
 }
 if(-not([IO.File]::ReadAllText($hook).Contains('bambu-paradise3-v6-source.jar'))){
   throw 'Gancho do motor nao corresponde ao plugin P3.'
 }
 $realHash=Hash $jar
 if($realHash -ne $expected){
   throw ('Plugin P3 diferente da versao validada. Obtido: '+$realHash+'; esperado: '+$expected)
 }
 $exe=@(Get-ChildItem -LiteralPath $appSource -Filter '*.exe' -File -ErrorAction Stop |
   Where-Object {$_.Name -match '(?i)Bambu.*Studio.*Teste'})
 if($exe.Count -eq 0){throw 'Executavel Bambu Studio Teste.exe nao encontrado na raiz.'}
 $starter=Join-Path $appSource 'ABRIR_BAMBU_TESTE_059_PORTATIL.cmd'
 if(-not(Test-Path -LiteralPath $starter -PathType Leaf)){throw ('Inicializador original nao encontrado: '+$starter)}
 Note '[OK] Aplicativo completo localizado.' 'Green'
 Note '[OK] Plugin P3 conferido pelo SHA256.' 'Green'
 Note '[OK] Mundo Paradise 3 localizado.' 'Green'
 Note ''
 if(Test-Path -LiteralPath $destZip -PathType Leaf){
   $previous=Join-Path $desktop ($version+'_ANTERIOR_'+$stamp+'.zip')
   Move-Item -LiteralPath $destZip -Destination $previous -ErrorAction Stop
   Note ('Backup do ZIP anterior: '+$previous) 'Yellow'
 }
 Note 'Copiando o aplicativo completo (executavel, recursos, motor e plugins)...' 'Cyan'
 New-Item -ItemType Directory -Path $appDest -Force | Out-Null
 RobocopyChecked $appSource $appDest @('/XD','logs','crash-reports','.git','BACKUP','BACKUPS')
 foreach($essential in @(
   (Join-Path $appDest 'resources\app\engine\servidor.cjs'),
   (Join-Path $appDest 'resources\app\engine\bambu-paradise3-v6-source.jar'),
   (Join-Path $appDest 'resources\app\engine\bambu-paradise3-v6-hook.cjs')
 )){
   if(-not(Test-Path -LiteralPath $essential -PathType Leaf)){throw ('Arquivo essencial faltando no pacote: '+$essential)}
 }
 if((Hash (Join-Path $appDest 'resources\app\engine\bambu-paradise3-v6-source.jar')) -ne $expected){
   throw 'Erro no hash do plugin ao copiar o motor.'
 }
 Note 'Copiando uma base limpa do servidor e do mapa Paradise 3...' 'Cyan'
 New-Item -ItemType Directory -Path $mapDest -Force | Out-Null
 # Exclui credenciais do servidor, logs e dados pessoais dos jogadores.
 # O aplicativo recria seus proprios server.properties, RCON e licenciamento.
 RobocopyChecked $serverSource $mapDest @(
   '/XD','plugins','logs','crash-reports','playerdata','stats','advancements','.cache','cache','backups',
   '/XF','ops.json','usercache.json','whitelist.json','banned-players.json','banned-ips.json',
         'server.properties','eula.txt','*.log','*.log.gz','session.lock','*.pid'
 )
 $plugDir=Join-Path $mapDest 'plugins'
 New-Item -ItemType Directory -Path $plugDir -Force | Out-Null
 Copy-Item -LiteralPath $jar -Destination (Join-Path $plugDir 'custom-parkour-tiktok.jar') -Force -ErrorAction Stop
 $yml=Join-Path $serverSource 'plugins\TParkourParadise\checkpoints.yml'
 if(Test-Path -LiteralPath $yml -PathType Leaf){
   $p=Join-Path $plugDir 'TParkourParadise'
   New-Item -ItemType Directory -Path $p -Force | Out-Null
   Copy-Item -LiteralPath $yml -Destination (Join-Path $p 'checkpoints.yml') -Force -ErrorAction Stop
 }
 if(-not(Test-Path -LiteralPath (Join-Path $mapDest 'world\level.dat') -PathType Leaf)){
   throw 'O mapa nao foi copiado para o pacote.'
 }
 $runner=@'
@echo off
setlocal
title BAMBU STUDIO 0.5.9 RC10 - PARADISE 3 FINAL
cd /d "%~dp0"
if not exist "%~dp0BAMBU_STUDIO\resources\app\engine\bambu-paradise3-v6-source.jar" (
 echo [ERRO] Arquivo do plugin Paradise 3 ausente.
 pause
 exit /b 1
)
if not exist "%APPDATA%\BAMBU Estudio Launcher Teste\mapas\parkour-paradise-3\servidor-mine\servidor\world\level.dat" (
 echo [BAMBU] Instalando mapa Paradise 3 para este Windows...
 if not exist "%~dp0MAPA_PARADISE_3_BASE\world\level.dat" (
   echo [ERRO] Mapa Paradise 3 nao esta no pacote.
   pause
   exit /b 1
 )
 robocopy "%~dp0MAPA_PARADISE_3_BASE" "%APPDATA%\BAMBU Estudio Launcher Teste\mapas\parkour-paradise-3\servidor-mine\servidor" /E /R:2 /W:1 /NFL /NDL /NJH /NJS
 if errorlevel 8 (
    echo [ERRO] Falhou a preparacao do mapa.
    pause
    exit /b 1
 )
 echo [BAMBU] Mapa instalado; progresso anterior nao foi substituido.
)
if exist "%~dp0BAMBU_STUDIO\ABRIR_BAMBU_TESTE_059_PORTATIL.cmd" (
 call "%~dp0BAMBU_STUDIO\ABRIR_BAMBU_TESTE_059_PORTATIL.cmd"
) else (
 echo [ERRO] Inicializador original do BAMBU ausente.
 pause
 exit /b 1
)
'@
 $readme=@'
BAMBU STUDIO 0.5.9 RC10 - PARKOUR PARADISE 3
PACOTE FINAL GERADO A PARTIR DA INSTALACAO FUNCIONAL

COMO USAR
1. Extraia o ZIP INTEIRO para uma pasta (nao execute dentro do ZIP).
2. Execute INICIAR_BAMBU_FINAL.cmd na raiz do pacote.
3. No BAMBU, clique em Preparar e iniciar servidor.
4. Entre no Minecraft 26.2 e configure escudo, teto e nivel negativo.

O QUE ESTA INCLUIDO
- BAMBU STUDIO portatil completo, inclusive .exe e recursos do Electron.
- Motor que preserva o plugin especifico do Paradise 3 antes de abrir Java.
- Plugin GULIVE Paradise 3 dentro do motor (nao requer programa GULIVE).
- Copia limpa do servidor e do mundo Paradise 3 que funcionava neste PC.
- Checkpoints atuais do servidor, quando presentes.
- Inicializador original e inicializador final simples.

PRESERVACAO DE DADOS
O inicializador final so copia o mundo se a instalacao Paradise 3 ainda nao existir.
Nunca sobrescreve um mundo ja existente por causa desse passo.
Nao inclui ops.json, usercache, banimentos, whitelist, server.properties
(senha RCON), licencas ou dados pessoais dos jogadores.
As credenciais e licencas do BAMBU sao mantidas pelo seu sistema normal.

TESTES CONCLUIDOS ANTES DA GERACAO
- Plugin correto Paradise 3 carregou na 0.5.9 RC10.
- As tres perguntas SIM/NAO foram apresentadas.
- Escudo e teto ligados, nivel negativo desligado; configuracao salva.
- O aviso de 7/7 checkpoints em blocos nao apareceu nas capturas finais.

IMPORTANTE
Os 100 checkpoints e todos os presentes TikTok ainda precisam de testes
em uma partida completa. A ausencia do aviso vermelho nao substitui isso.
Nao publique a versao como aprovada para producao sem testar.
Preserve o ZIP anterior da versao que estava funcionando.

MAPA E JAVA
Se o BAMBU precisar preparar Java ou outros recursos, use o botao unico;
o programa continua gerenciando isso como antes.
'@
 $utf8=[System.Text.UTF8Encoding]::new($false)
 [IO.File]::WriteAllText((Join-Path $staging 'INICIAR_BAMBU_FINAL.cmd'),$runner,$utf8)
 [IO.File]::WriteAllText((Join-Path $staging 'LEIA-ME_BAMBU_FINAL.txt'),$readme,$utf8)
 $manifest=[pscustomobject]@{
   version=$version
   generated=(Get-Date).ToString('s')
   plugin_p3_sha256=$expected
   plugin_p3_source='GULIVE-Local-1.25.1/servidor-mine/parkour-paradise-3'
   engine='BAMBU STUDIO Teste 0.5.9 RC10 motor corrigido'
   map='Parkour Paradise 3'
   includesFullApplication=$true
   includesMapAndServer=$true
   excludesPersonalServerData=$true
   checkpointGameplayValidation='pendente'
 }
 [IO.File]::WriteAllText((Join-Path $staging 'MANIFESTO_FINAL.json'),($manifest|ConvertTo-Json -Depth 5),$utf8)
 Note 'Compactando ZIP final... Pode levar alguns minutos.' 'Cyan'
 [IO.Compression.ZipFile]::CreateFromDirectory(
   $staging,
   $destZip,
   [IO.Compression.CompressionLevel]::Optimal,
   $true
 )
 $z=[IO.Compression.ZipFile]::OpenRead($destZip)
 try{
   foreach($required in @(
     ($version+'/INICIAR_BAMBU_FINAL.cmd'),
     ($version+'/BAMBU_STUDIO/resources/app/engine/bambu-paradise3-v6-source.jar'),
     ($version+'/BAMBU_STUDIO/resources/app/engine/bambu-paradise3-v6-hook.cjs'),
     ($version+'/MAPA_PARADISE_3_BASE/world/level.dat')
   )){
     if(-not $z.GetEntry($required)){throw ('Arquivo ausente no ZIP gerado: '+$required)}
   }
 } finally {$z.Dispose()}
 $size=[Math]::Round((Get-Item -LiteralPath $destZip).Length / 1MB,1)
 Note ''
 Note '=================================================================' 'Green'
 Note '[OK] PACOTE FINAL GERADO E ESTRUTURA DO ZIP CONFERIDA!' 'Green'
 Note ('ARQUIVO: '+$destZip) 'White'
 Note ('TAMANHO: '+$size+' MB') 'White'
 Note 'O aplicativo original NAO foi modificado pela geracao do ZIP.' 'Green'
 Note 'Extraia o ZIP e abra INICIAR_BAMBU_FINAL.cmd.' 'Cyan'
 Note '=================================================================' 'Green'
} catch {
 Note ''
 Note ('[ERRO] '+$_.Exception.Message) 'Red'
 Note 'O aplicativo original nao foi alterado.' 'Yellow'
 exit 1
} finally {
 if(Test-Path -LiteralPath $stagingRoot -PathType Container){
  Remove-Item -LiteralPath $stagingRoot -Recurse -Force -ErrorAction SilentlyContinue
 }
}
