@echo off
setlocal
title BAMBU 0.5.9 - PARKOUR PARADISE 3 - MOTOR V5
set "BAMBU_SCRIPT_V5=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$s=[IO.File]::ReadAllText($env:BAMBU_SCRIPT_V5);$m='# BAMBU_V5_PS';$p=$s.LastIndexOf($m);if($p -lt 0){throw 'Marcador V5 ausente'};& ([scriptblock]::Create($s.Substring($p+$m.Length)))"
echo.
echo Pressione qualquer tecla para sair.
pause >nul
exit /b

# BAMBU_V5_PS
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$backupRoot=Join-Path $env:LOCALAPPDATA 'BAMBU_059_PARADISE3_V5_BACKUP'
$last=Join-Path $backupRoot 'ultimo_manifesto.txt'
$server=Join-Path $env:APPDATA 'BAMBU Estudio Launcher Teste\mapas\parkour-paradise-3\servidor-mine\servidor'
$targetJar=Join-Path $server 'plugins\custom-parkour-tiktok.jar'
$targetYml=Join-Path $server 'plugins\TParkourParadise\checkpoints.yml'
function Say([string]$s,[string]$c='Gray'){Write-Host $s -ForegroundColor $c}
function HashOf([string]$p){if(Test-Path -LiteralPath $p -PathType Leaf){return (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash};return 'AUSENTE'}
function JarOk([string]$p) {
  if(-not(Test-Path -LiteralPath $p -PathType Leaf)){return $false}
  $z=$null
  try{$z=[IO.Compression.ZipFile]::OpenRead($p);return ($null -ne $z.GetEntry('plugin.yml'))}
  catch{return $false}
  finally{if($z){$z.Dispose()}}
}
function FindSource {
  foreach($base in @(
    (Join-Path $env:LOCALAPPDATA 'GULIVE-Local-1.25.1'),
    (Join-Path $env:USERPROFILE 'Desktop\GULIVE-Local-1.25.1'),
    (Join-Path $env:USERPROFILE 'Downloads\GULIVE-Local-1.25.1')
  )){
    $s=Join-Path $base 'servidor-mine\parkour-paradise-3\servidor'
    $j=Join-Path $s 'plugins\custom-parkour-tiktok.jar'
    $y=Join-Path $s 'plugins\TParkourParadise\checkpoints.yml'
    if((JarOk $j) -and (Test-Path -LiteralPath $y -PathType Leaf)){
      return [pscustomobject]@{jar=$j;yml=$y;server=$s}
    }
  }
  return $null
}
function FindEngine {
  $items=New-Object 'System.Collections.Generic.List[string]'
  foreach($base in @(
    (Join-Path $env:USERPROFILE 'Downloads'),
    (Join-Path $env:USERPROFILE 'Desktop'),
    (Join-Path $env:USERPROFILE 'OneDrive')
  )){
    if(-not(Test-Path -LiteralPath $base -PathType Container)){continue}
    Say ('Localizando motor BAMBU em: '+$base)
    Get-ChildItem -LiteralPath $base -Filter 'servidor.cjs' -File -Recurse -ErrorAction SilentlyContinue |
      Where-Object {$_.FullName -match '(?i)BAMBU[_ -]?STUDIO' -and $_.FullName -match '(?i)(0_5_9|059)' -and $_.FullName -match '(?i)resources[\\/]app[\\/]engine[\\/]servidor\.cjs$'} |
      ForEach-Object {[void]$items.Add($_.DirectoryName)}
  }
  $found=@($items.ToArray() | Sort-Object -Unique)
  if($found.Count -eq 0){throw 'Nao achei o motor da BAMBU 0.5.9 descompactada (resources\app\engine\servidor.cjs).'}
  if($found.Count -eq 1){return $found[0]}
  Say 'Escolha a pasta do BAMBU que voce ABRE no Windows:' 'Cyan'
  for($i=0;$i -lt $found.Count;$i++){Say ('['+($i+1)+'] '+$found[$i]) 'White'}
  $answer=Read-Host 'Numero (0 cancela)'
  $num=0
  if(-not([int]::TryParse($answer,[ref]$num)) -or $num -lt 1 -or $num -gt $found.Count){throw 'Cancelado.'}
  return $found[$num-1]
}
function MakeBackup([string]$file,[string]$dir,[System.Collections.Generic.List[object]]$entries){
  $exists=Test-Path -LiteralPath $file -PathType Leaf
  $b=''
  $h=''
  if($exists){
    $h=HashOf $file
    $b=Join-Path $dir (('{0:D2}' -f ($entries.Count+1))+'_'+[IO.Path]::GetFileName($file)+'.backup')
    Copy-Item -LiteralPath $file -Destination $b -ErrorAction Stop
    if((HashOf $b) -ne $h){throw 'Erro ao criar backup de '+$file}
  }
  $entries.Add([pscustomobject]@{path=$file;existed=[bool]$exists;backup=$b;hash=$h})
}
function RevertEntries([object[]]$entries){
  foreach($e in $entries){
    if($e.existed){
      if(-not(Test-Path -LiteralPath $e.backup -PathType Leaf)){throw ('Backup nao encontrado: '+$e.backup)}
      if((HashOf $e.backup) -ne $e.hash){throw ('Backup invalido: '+$e.backup)}
    }
  }
  foreach($e in $entries){
    if($e.existed){
      $parent=Split-Path -Parent $e.path
      if(-not(Test-Path -LiteralPath $parent -PathType Container)){New-Item -Path $parent -ItemType Directory -Force | Out-Null}
      Copy-Item -LiteralPath $e.backup -Destination $e.path -Force -ErrorAction Stop
      Say ('[RESTAURADO] '+$e.path) 'Green'
    }else{
      Remove-Item -LiteralPath $e.path -Force -ErrorAction SilentlyContinue
    }
  }
}
function Install {
  $source=FindSource
  if(-not $source){throw 'Nao encontrei o plugin E checkpoints.yml do GULIVE parkour-paradise-3. Nenhum arquivo alterado.'}
  if(-not(Test-Path -LiteralPath (Join-Path $server 'plugins') -PathType Container)){throw 'Servidor BAMBU Paradise 3 ainda nao preparado. Abra uma vez e feche.'}
  $engine=FindEngine
  $main=Join-Path $engine 'servidor.cjs'
  $asset=Join-Path $engine 'hud-layout-assets\custom-parkour-tiktok-hud-bambu.jar'
  $assetYml=Join-Path $engine 'hud-layout-assets\parkour-paradise-3-checkpoints.yml'
  $hook=Join-Path $engine 'bambu-parkour3-hook.cjs'
  if(-not(Test-Path -LiteralPath $asset -PathType Leaf)){throw ('Nao encontrei recurso interno BAMBU: '+$asset)}
  $mainText=[IO.File]::ReadAllText($main)
  $hookPrefix="require('./bambu-parkour3-hook.cjs'); // BAMBU-PARKOUR3-V5"+[Environment]::NewLine
  $sourcesJarHash=HashOf $source.jar
  $sourcesYmlHash=HashOf $source.yml
  Say '' 
  Say 'ORIGEM CORRETA: GULIVE / PARKOUR PARADISE 3' 'Cyan'
  Say ('Plugin: '+$source.jar) 'White'
  Say ('Checkpoints: '+$source.yml) 'White'
  Say ('SHA256 plugin: '+$sourcesJarHash)
  Say ('Motor: '+$engine) 'White'
  Say ('Servidor: '+$server) 'White'
  Say ''
  Say 'Esta V5 atualiza o JAR e checkpoints P3 no motor e no servidor.' 'Yellow'
  Say 'Tambem instala um gancho que reaplica ambos ANTES de iniciar Java.' 'Yellow'
  Say 'Nao modifica o mundo, os saves dos jogadores ou o botao.' 'Green'
  $yes=Read-Host 'BAMBU e SERVIDOR FECHADOS? Digite SIM para instalar'
  if($yes -cne 'SIM'){Say 'Cancelado sem alterar nada.' 'Yellow';return}
  New-Item -Path $backupRoot -ItemType Directory -Force | Out-Null
  $bdir=Join-Path $backupRoot (Get-Date -Format 'yyyyMMdd_HHmmss')
  New-Item -Path $bdir -ItemType Directory -Force | Out-Null
  $entries=New-Object 'System.Collections.Generic.List[object]'
  foreach($file in @($main,$asset,$assetYml,$hook,$targetJar,$targetYml)){
    MakeBackup $file $bdir $entries
  }
  $manifest=Join-Path $bdir 'manifest.json'
  $data=[pscustomobject]@{when=(Get-Date).ToString('s');entries=@($entries.ToArray())}
  [IO.File]::WriteAllText($manifest,($data|ConvertTo-Json -Depth 7),[Text.UTF8Encoding]::new($false))
  [IO.File]::WriteAllText($last,$manifest,[Text.UTF8Encoding]::new($false))
  $hookCode=@'
'use strict';
// BAMBU PARKOUR PARADISE 3 - MOTOR V5
// Antes de iniciar o Java, restaura JAR e checkpoints P3 da copia interna do BAMBU.
(function(){
  if(global.__bambuParkour3V5) return;
  global.__bambuParkour3V5=true;
  const fs=require('node:fs');
  const cp=require('node:child_process');
  const path=require('node:path');
  const a=path.join(__dirname,'hud-layout-assets','custom-parkour-tiktok-hud-bambu.jar');
  const c=path.join(__dirname,'hud-layout-assets','parkour-paradise-3-checkpoints.yml');
  const root=path.join(process.env.APPDATA || '','BAMBU Estudio Launcher Teste','mapas','parkour-paradise-3','servidor-mine','servidor');
  const plug=path.join(root,'plugins');
  const jar=path.join(plug,'custom-parkour-tiktok.jar');
  const yml=path.join(plug,'TParkourParadise','checkpoints.yml');
  function install(){
    if(!fs.existsSync(plug)) throw new Error('Pasta plugins Paradise 3 nao encontrada');
    if(!fs.existsSync(a)||!fs.existsSync(c)) throw new Error('Arquivos internos do Paradise 3 ausentes');
    fs.mkdirSync(path.dirname(yml),{recursive:true});
    fs.copyFileSync(a,jar);
    fs.copyFileSync(c,yml);
    console.log('[BAMBU P3 V5] JAR e checkpoints P3 preparados antes do Java.');
  }
  function isJava(file,args){
    const exe=path.basename(String(file||'')).toLowerCase();
    const more=(Array.isArray(args)?args:[]).map(String).join(' ').toLowerCase();
    if(['java','java.exe','javaw','javaw.exe'].includes(exe)) return more.includes('-jar');
    if(['cmd','cmd.exe','powershell','powershell.exe'].includes(exe)) return /java(?:w)?(?:\.exe)?/.test(more)&&more.includes('-jar');
    return false;
  }
  for(const key of ['spawn','execFile','spawnSync','execFileSync']){
    if(typeof cp[key]!=='function')continue;
    const original=cp[key];
    cp[key]=function(file,args){
      if(isJava(file,args))install();
      return original.apply(this,arguments);
    };
  }
  for(const key of ['exec','execSync']){
    if(typeof cp[key]!=='function')continue;
    const original=cp[key];
    cp[key]=function(command){
      if(/java(?:w)?(?:\.exe)?/i.test(String(command))&&String(command).includes('-jar'))install();
      return original.apply(this,arguments);
    };
  }
})();
'@
  try {
    Copy-Item -LiteralPath $source.jar -Destination $asset -Force -ErrorAction Stop
    Copy-Item -LiteralPath $source.yml -Destination $assetYml -Force -ErrorAction Stop
    [IO.File]::WriteAllText($hook,$hookCode,[Text.UTF8Encoding]::new($false))
    if($mainText -notmatch 'BAMBU-PARKOUR3-V5'){
       [IO.File]::WriteAllText($main,($hookPrefix+$mainText),[Text.UTF8Encoding]::new($false))
    }
    $dir=Split-Path -Parent $targetYml
    if(-not(Test-Path -LiteralPath $dir -PathType Container)){New-Item -ItemType Directory -Path $dir -Force | Out-Null}
    Copy-Item -LiteralPath $source.jar -Destination $targetJar -Force -ErrorAction Stop
    Copy-Item -LiteralPath $source.yml -Destination $targetYml -Force -ErrorAction Stop
    if((HashOf $asset) -ne $sourcesJarHash -or (HashOf $targetJar) -ne $sourcesJarHash -or (HashOf $assetYml) -ne $sourcesYmlHash -or (HashOf $targetYml) -ne $sourcesYmlHash){throw 'Falha SHA256 depois da instalacao.'}
    if(-not([IO.File]::ReadAllText($main).StartsWith("require('./bambu-parkour3-hook.cjs');"))){throw 'Falha ao ligar o gancho ao motor.'}
    Say ''
    Say '[OK] PARKOUR PARADISE 3 INSTALADO NO MOTOR DO BAMBU 0.5.9.' 'Green'
    Say '[OK] JAR E CHECKPOINTS CONFERIDOS COM SHA256.' 'Green'
    Say ('BACKUP: '+$bdir) 'Green'
    Say 'Abra o BAMBU e clique no botao unico Preparar e iniciar servidor.' 'Cyan'
    Say 'Se ainda houver aviso 7/7, pode existir diferenca no mundo do mapa.' 'Yellow'
  }catch{
    Say ('[ERRO] '+$_.Exception.Message) 'Red'
    Say 'Tentando reverter arquivos ...' 'Yellow'
    try{RevertEntries @($entries.ToArray())}catch{Say ('Falha na restauracao automatica: '+$_.Exception.Message) 'Red'}
    throw 'Instalacao interrompida.'
  }
}
function Compare {
  $src=FindSource
  if(-not $src){throw 'GULIVE Paradise 3 nao encontrado com plugin e checkpoints.yml.'}
  Say ('GULIVE P3 JAR: '+(HashOf $src.jar)) 'Cyan'
  Say ('GULIVE P3 CHECKPOINTS: '+(HashOf $src.yml)) 'Cyan'
  $base=Split-Path (Split-Path $src.server -Parent) -Parent
  $jar1=Join-Path $base 'parkour-paradise-1\servidor\plugins\custom-parkour-tiktok.jar'
  if(Test-Path -LiteralPath $jar1 -PathType Leaf){
    Say ('GULIVE P1 JAR: '+(HashOf $jar1))
    if((HashOf $jar1) -eq (HashOf $src.jar)){Say 'AVISO: JAR do P1 e P3 identicos; ajustes podem depender do checkpoints.yml.' 'Yellow'}
  }
  Say ('BAMBU JAR: '+(HashOf $targetJar))
  Say ('BAMBU CHECKPOINTS: '+(HashOf $targetYml))
}
function Restore {
  if(-not(Test-Path -LiteralPath $last -PathType Leaf)){throw 'Nenhum backup V5 foi encontrado.'}
  $manifest=Get-Content -LiteralPath $last -Raw -Encoding UTF8
  $m=Get-Content -LiteralPath $manifest -Raw -Encoding UTF8 | ConvertFrom-Json
  Say ('Backup de: '+$m.when) 'Cyan'
  $yes=Read-Host 'BAMBU e servidor FECHADOS? Digite SIM para restaurar'
  if($yes -cne 'SIM'){Say 'Cancelado.';return}
  RevertEntries @($m.entries)
  Say '[OK] Arquivos anteriores restaurados.' 'Green'
}
try{
  Say '============================================================' 'Cyan'
  Say ' BAMBU STUDIO 0.5.9 - PARKOUR PARADISE 3 - V5' 'Cyan'
  Say ' Plugin + checkpoints P3 dentro do motor do botao unico' 'Cyan'
  Say '============================================================' 'Cyan'
  Say '[1] Instalar correcao do mapa 3 com backup' 'White'
  Say '[2] Comparar arquivos antes/depois (sem alterar)' 'White'
  Say '[3] Restaurar arquivos antes da V5' 'White'
  Say '[0] Sair' 'White'
  $mode=Read-Host 'Escolha'
  switch($mode){
    '1' {Install}
    '2' {Compare}
    '3' {Restore}
    '0' {exit 0}
    default{throw 'Opcao invalida.'}
  }
}catch{Say ('[ERRO] '+$_.Exception.Message) 'Red';exit 1}
