@echo off
setlocal
title BAMBU 0.5.9 - PARKOUR PARADISE 3 - V6
set "BAMBU_V6_SELF=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$s=[IO.File]::ReadAllText($env:BAMBU_V6_SELF);$m='# INICIO_POWERSHELL_BAMBU_V6';$p=$s.LastIndexOf($m);if($p -lt 0){throw 'Marcador V6 ausente'};& ([scriptblock]::Create($s.Substring($p+$m.Length)))"
echo.
echo Pressione uma tecla para fechar.
pause >nul
exit /b

# INICIO_POWERSHELL_BAMBU_V6
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$backupRoot=Join-Path $env:LOCALAPPDATA 'BAMBU_PARKOUR_PARADISE_3_V6_BACKUP'
$lastFile=Join-Path $backupRoot 'ultimo_manifesto.txt'
$server=Join-Path $env:APPDATA 'BAMBU Estudio Launcher Teste\mapas\parkour-paradise-3\servidor-mine\servidor'
$runtimeJar=Join-Path $server 'plugins\custom-parkour-tiktok.jar'
$runtimeYml=Join-Path $server 'plugins\TParkourParadise\checkpoints.yml'
function Info([string]$s,[string]$c='Gray'){Write-Host $s -ForegroundColor $c}
function HashArquivoV6([string]$p){
 if(-not(Test-Path -LiteralPath $p -PathType Leaf)){return 'AUSENTE'}
 return (Get-FileHash -LiteralPath $p -Algorithm SHA256 -ErrorAction Stop).Hash
}
function ValidJar([string]$p){
 if(-not(Test-Path -LiteralPath $p -PathType Leaf)){return $false}
 $z=$null
 try{
  $z=[IO.Compression.ZipFile]::OpenRead($p)
  return ($null -ne $z.GetEntry('plugin.yml'))
 }catch{return $false}finally{if($z){$z.Dispose()}}
}
function FindGulive {
 foreach($base in @(
  (Join-Path $env:LOCALAPPDATA 'GULIVE-Local-1.25.1'),
  (Join-Path $env:USERPROFILE 'Desktop\GULIVE-Local-1.25.1'),
  (Join-Path $env:USERPROFILE 'Downloads\GULIVE-Local-1.25.1')
 )){
   $p3=Join-Path $base 'servidor-mine\parkour-paradise-3\servidor'
   $jar=Join-Path $p3 'plugins\custom-parkour-tiktok.jar'
   if(-not (ValidJar $jar)){continue}
   $p1=Join-Path $base 'servidor-mine\parkour-paradise-1\servidor\plugins\custom-parkour-tiktok.jar'
   $check=$null
   foreach($rel in @(
    'plugins\TParkourParadise\checkpoints.yml',
    'plugins\tparkourparadise\checkpoints.yml',
    'plugins\custom-parkour-tiktok\checkpoints.yml',
    'plugins\ParkourParadise\checkpoints.yml'
   )){
    $test=Join-Path $p3 $rel
    if((Test-Path -LiteralPath $test -PathType Leaf) -and ((Get-Item -LiteralPath $test).Length -gt 10)){
     $check=$test
     break
    }
   }
   return [pscustomobject]@{jar=$jar;p1=$p1;checkpoints=$check;server=$p3}
 }
 return $null
}
function FindEngine {
 $dirs=New-Object 'System.Collections.Generic.List[string]'
 foreach($base in @((Join-Path $env:USERPROFILE 'Downloads'),(Join-Path $env:USERPROFILE 'Desktop'))){
  if(-not(Test-Path -LiteralPath $base -PathType Container)){continue}
  Info ('Procurando motor: '+$base) 'Cyan'
  Get-ChildItem -LiteralPath $base -Filter 'servidor.cjs' -File -Recurse -ErrorAction SilentlyContinue |
   Where-Object {
    $_.FullName -match '(?i)(0_5_9|059)' -and
    $_.FullName -match '(?i)resources[\\/]app[\\/]engine[\\/]servidor\.cjs$' -and
    $_.FullName -match '(?i)BAMBU'
   } | ForEach-Object {[void]$dirs.Add($_.DirectoryName)}
 }
 $all=@($dirs.ToArray() | Sort-Object -Unique)
 if($all.Count -eq 0){throw 'Nao achei resources\app\engine\servidor.cjs da BAMBU 0.5.9 extraida.'}
 if($all.Count -eq 1){Info ('Motor encontrado: '+$all[0]) 'Green';return $all[0]}
 Info 'Escolha a pasta da BAMBU 0.5.9 que voce ABRE:' 'Yellow'
 for($i=0;$i -lt $all.Count;$i++){Info ("[$($i+1)] "+$all[$i]) 'White'}
 $v=Read-Host 'Numero (0 cancela)'
 $n=0
 if(-not([int]::TryParse($v,[ref]$n)) -or $n -lt 1 -or $n -gt $all.Count){throw 'Cancelado. Nenhum arquivo alterado.'}
 return $all[$n-1]
}
function Bkp([string]$p,[string]$dir,[System.Collections.Generic.List[object]]$records){
 $was=Test-Path -LiteralPath $p -PathType Leaf
 $back='';$h=''
 if($was){
  $h=HashArquivoV6 $p
  $back=Join-Path $dir (('{0:D2}' -f ($records.Count+1))+'_'+[IO.Path]::GetFileName($p)+'.bak')
  Copy-Item -LiteralPath $p -Destination $back -ErrorAction Stop
  if((HashArquivoV6 $back) -ne $h){throw 'Backup falhou: '+$p}
 }
 [void]$records.Add([pscustomobject]@{path=$p;was=$was;backup=$back;hash=$h})
}
function Revert([object[]]$records){
 foreach($r in $records){
  if($r.was -and ((-not(Test-Path -LiteralPath $r.backup -PathType Leaf)) -or ((HashArquivoV6 $r.backup) -ne $r.hash))){
   throw ('Backup ausente ou corrompido: '+$r.backup)
  }
 }
 foreach($r in $records){
  if($r.was){
   $dir=Split-Path -Parent $r.path
   if(-not(Test-Path -LiteralPath $dir -PathType Container)){New-Item -ItemType Directory -Path $dir -Force | Out-Null}
   Copy-Item -LiteralPath $r.backup -Destination $r.path -Force -ErrorAction Stop
   Info ('[RESTAURADO] '+$r.path) 'Green'
  }else{Remove-Item -LiteralPath $r.path -Force -ErrorAction SilentlyContinue}
 }
}
function RunInstall{
 $src=FindGulive
 if(-not $src){throw 'Plugin P3 do GULIVE nao localizado. Nenhum arquivo alterado.'}
 if(-not(Test-Path -LiteralPath (Join-Path $server 'plugins') -PathType Container)){
  throw 'Servidor BAMBU P3 nao preparado. Abra uma vez e feche, sem aplicar outros patches.'
 }
 $p3hash=HashArquivoV6 $src.jar
 $p1hash=HashArquivoV6 $src.p1
 Info ''
 Info ('PLUGIN GULIVE PARADISE 3: '+$src.jar) 'Cyan'
 Info ('SHA256 P3: '+$p3hash)
 Info ('SHA256 P1: '+$p1hash)
 if($src.checkpoints){Info ('CHECKPOINTS P3 ENCONTRADOS: '+$src.checkpoints) 'Green'}
 else{Info 'AVISO: GULIVE P3 nao tem checkpoints.yml no local esperado.' 'Yellow';Info 'A V6 NAO vai inventar coordenadas nem apagar checkpoints atuais.' 'Yellow'}
 if($p1hash -eq $p3hash -and -not $src.checkpoints){
  Info ''
  Info '[PAROU SEM ALTERAR] Os JARs de P1 e P3 sao identicos e nao ha checkpoints P3.' 'Red'
  Info 'Copiar novamente nao resolveria o aviso 7/7. Precisamos dos checkpoints corretos.' 'Yellow'
  return
 }
 $engine=FindEngine
 $main=Join-Path $engine 'servidor.cjs'
 $oldAsset=Join-Path $engine 'hud-layout-assets\custom-parkour-tiktok-hud-bambu.jar'
 $ownJar=Join-Path $engine 'bambu-paradise3-v6-source.jar'
 $ownYml=Join-Path $engine 'bambu-paradise3-v6-checkpoints.yml'
 $hook=Join-Path $engine 'bambu-paradise3-v6-hook.cjs'
 if(-not(Test-Path -LiteralPath $oldAsset -PathType Leaf)){throw 'Recurso interno original BAMBU ausente: '+$oldAsset}
 $header="require('./bambu-paradise3-v6-hook.cjs'); // BAMBU-PARADISE3-V6"+[Environment]::NewLine
 $originalText=[IO.File]::ReadAllText($main)
 Info ''
 Info 'O motor P3 sera protegido contra a recriacao do plugin antigo.' 'Cyan'
 Info ('MOTOR: '+$engine) 'White'
 Info 'Copia do GULIVE P3 sera guardada em arquivo proprio, dentro do motor.' 'White'
 Info 'Os arquivos checkpoint so serao atualizados se existirem no GULIVE P3.' 'White'
 Info 'A V6 NAO modifica mundos, mapas, saves nem o botao unico.' 'Green'
 Info 'Pode alterar o HUD fornecido pelo plugin, como nas versoes anteriores.' 'Yellow'
 $yes=Read-Host 'Com BAMBU e SERVIDOR fechados, digite SIM para instalar'
 if($yes -cne 'SIM'){Info 'Cancelado.' 'Yellow';return}
 New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
 $dir=Join-Path $backupRoot (Get-Date -Format 'yyyyMMdd_HHmmss')
 New-Item -ItemType Directory -Path $dir -Force | Out-Null
 $records=New-Object 'System.Collections.Generic.List[object]'
 $files=@($main,$oldAsset,$ownJar,$hook,$runtimeJar)
 if($src.checkpoints){$files+=@($ownYml,$runtimeYml)}
 foreach($p in $files){Bkp $p $dir $records}
 $manifest=Join-Path $dir 'manifest.json'
 $m=[pscustomobject]@{when=(Get-Date).ToString('s');items=@($records.ToArray())}
 [IO.File]::WriteAllText($manifest,($m | ConvertTo-Json -Depth 7),[Text.UTF8Encoding]::new($false))
 [IO.File]::WriteAllText($lastFile,$manifest,[Text.UTF8Encoding]::new($false))
 $hookCode=@'
'use strict';
// BAMBU P3 V6: restaura o plugin especifico do Paradise 3 antes de abrir o Java.
(function(){
 if(global.__bambuParadise3V6) return;
 global.__bambuParadise3V6 = true;
 const fs = require('node:fs');
 const path = require('node:path');
 const cp = require('node:child_process');
 const source=path.join(__dirname,'bambu-paradise3-v6-source.jar');
 const sourceYml=path.join(__dirname,'bambu-paradise3-v6-checkpoints.yml');
 const server=path.join(process.env.APPDATA || '','BAMBU Estudio Launcher Teste','mapas','parkour-paradise-3','servidor-mine','servidor');
 const plugins=path.join(server,'plugins');
 const destination=path.join(plugins,'custom-parkour-tiktok.jar');
 const yml=path.join(plugins,'TParkourParadise','checkpoints.yml');
 function sync(){
   if(!fs.existsSync(source)) throw new Error('[BAMBU V6] Plugin Paradise 3 ausente');
   if(!fs.existsSync(plugins)) throw new Error('[BAMBU V6] Servidor ainda nao foi preparado');
   fs.copyFileSync(source,destination);
   if(fs.existsSync(sourceYml)){
     fs.mkdirSync(path.dirname(yml),{recursive:true});
     fs.copyFileSync(sourceYml,yml);
   }
   console.log('[BAMBU V6] Plugin Paradise 3 aplicado antes da inicializacao do Java.');
 }
 function isJava(file,args){
   const name=path.basename(String(file || '')).toLowerCase();
   const joined=Array.isArray(args) ? args.map(String).join(' ').toLowerCase() : '';
   if(['java','java.exe','javaw','javaw.exe'].includes(name))return joined.includes('-jar');
   if(['cmd','cmd.exe','powershell.exe','powershell'].includes(name))
      return /java(?:w)?(?:\.exe)?/i.test(joined)&&joined.includes('-jar');
   return false;
 }
 for(const name of ['spawn','execFile','spawnSync','execFileSync']){
   if(typeof cp[name]!=='function')continue;
   const previous=cp[name];
   cp[name]=function(file,args){if(isJava(file,args))sync();return previous.apply(this,arguments);};
 }
 for(const name of ['exec','execSync']){
   if(typeof cp[name]!=='function')continue;
   const previous=cp[name];
   cp[name]=function(command){const s=String(command||'');if(/java(?:w)?(?:\.exe)?/i.test(s)&&s.includes('-jar'))sync();return previous.apply(this,arguments);};
 }
})();
'@
 try{
  Copy-Item -LiteralPath $src.jar -Destination $ownJar -Force -ErrorAction Stop
  Copy-Item -LiteralPath $src.jar -Destination $oldAsset -Force -ErrorAction Stop
  [IO.File]::WriteAllText($hook,$hookCode,[Text.UTF8Encoding]::new($false))
  if(-not $originalText.Contains('BAMBU-PARADISE3-V6')){
   [IO.File]::WriteAllText($main,($header+$originalText),[Text.UTF8Encoding]::new($false))
  }
  Copy-Item -LiteralPath $src.jar -Destination $runtimeJar -Force -ErrorAction Stop
  if($src.checkpoints){
   Copy-Item -LiteralPath $src.checkpoints -Destination $ownYml -Force -ErrorAction Stop
   $p=Split-Path -Parent $runtimeYml
   if(-not(Test-Path -LiteralPath $p -PathType Container)){New-Item -ItemType Directory -Path $p -Force | Out-Null}
   Copy-Item -LiteralPath $src.checkpoints -Destination $runtimeYml -Force -ErrorAction Stop
  }
  if((HashArquivoV6 $ownJar) -ne $p3hash -or (HashArquivoV6 $oldAsset) -ne $p3hash -or (HashArquivoV6 $runtimeJar) -ne $p3hash){throw 'Hash do plugin nao confere depois da copia.'}
  if($src.checkpoints -and ((HashArquivoV6 $ownYml) -ne (HashArquivoV6 $src.checkpoints) -or (HashArquivoV6 $runtimeYml) -ne (HashArquivoV6 $src.checkpoints))){throw 'Hash dos checkpoints nao confere.'}
  Info ''
  Info '[OK] PLUGIN PARADISE 3 INSTALADO NO MOTOR E NO SERVIDOR.' 'Green'
  Info '[OK] Copia independente protegida e gancho ligado ao motor.' 'Green'
  Info ('BACKUP: '+$dir) 'Green'
  Info 'Abra BAMBU pelo botao unico e teste o aviso dos checkpoints.' 'Cyan'
  if(-not $src.checkpoints){Info 'ATENCAO: Sem checkpoints P3 na origem, a correção das coordenadas ainda precisa ser validada.' 'Yellow'}
 }catch{
  Info ('[ERRO] '+$_.Exception.Message) 'Red'
  Info 'Tentando restaurar backups...' 'Yellow'
  try{Revert $records.ToArray()}catch{Info ('Falha ao restaurar: '+$_.Exception.Message) 'Red'}
  throw 'Instalacao V6 interrompida.'
 }
}
function Compare {
 $src=FindGulive
 if(-not $src){throw 'Plugin GULIVE P3 nao encontrado.'}
 Info ('GULIVE P3: '+(HashArquivoV6 $src.jar)) 'Cyan'
 Info ('GULIVE P1: '+(HashArquivoV6 $src.p1)) 'Cyan'
 Info ('BAMBU SERVIDOR: '+(HashArquivoV6 $runtimeJar)) 'Cyan'
 if($src.checkpoints){
  Info ('GULIVE P3 checkpoints: '+(HashArquivoV6 $src.checkpoints))
  Info ('BAMBU checkpoints: '+(HashArquivoV6 $runtimeYml))
 }else{Info 'GULIVE P3 nao possui checkpoints.yml no local previsto.' 'Yellow'}
}
function Restore{
 if(-not(Test-Path -LiteralPath $lastFile -PathType Leaf)){throw 'Sem backup V6 para restaurar.'}
 $manifest=Get-Content -LiteralPath $lastFile -Raw -Encoding UTF8
 $data=Get-Content -LiteralPath $manifest -Raw -Encoding UTF8 | ConvertFrom-Json
 $yes=Read-Host 'BAMBU e servidor FECHADOS? Digite SIM para restaurar'
 if($yes -cne 'SIM'){Info 'Cancelado.' 'Yellow';return}
 Revert @($data.items)
 Info '[OK] V6 restaurada para os arquivos anteriores.' 'Green'
}
try{
 Info '============================================================' 'Cyan'
 Info ' BAMBU 0.5.9 - PARADISE 3 - V6' 'Cyan'
 Info ' Nao exige checkpoints.yml para usar plugin P3' 'Cyan'
 Info '============================================================' 'Cyan'
 Info '[1] Instalar plugin P3 com backup' 'White'
 Info '[2] Comparar hashes P1, P3 e BAMBU (nao altera)' 'White'
 Info '[3] Restaurar arquivos de antes da V6' 'White'
 Info '[0] Sair' 'White'
 $mode=Read-Host 'Escolha'
 switch($mode){
  '1'{RunInstall}
  '2'{Compare}
  '3'{Restore}
  '0'{exit 0}
  default{throw 'Opcao invalida.'}
 }
}catch{Info ('[ERRO] '+$_.Exception.Message) 'Red';exit 1}
