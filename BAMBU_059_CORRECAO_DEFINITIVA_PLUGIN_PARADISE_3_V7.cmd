@echo off
setlocal DisableDelayedExpansion
title BAMBU STUDIO 0.5.9 - CORRECAO PARADISE 3 - V7
set "BAMBU_V7_SELF=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$t=[IO.File]::ReadAllText($env:BAMBU_V7_SELF);$m='# INICIO_BAMBU_V7_PS';$i=$t.LastIndexOf($m);if($i -lt 0){throw 'Marcador V7 ausente'};& ([ScriptBlock]::Create($t.Substring($i+$m.Length)))"
set "BAMBU_RC=%ERRORLEVEL%"
echo.
echo Pressione uma tecla para fechar.
pause >nul
exit /b %BAMBU_RC%

# INICIO_BAMBU_V7_PS
$ErrorActionPreference='Stop'
$hashP3='201656BC3CB0462D96BB6E1FDCAEA62417D704168CD3B051CF8C0F3CF1A1F8FF'
$hashP1='D2A65F6E9FD1280C96E1B874641E8829CEE28D62EA7D7E87CCEFDA6F6ED79380'
$server=Join-Path $env:APPDATA 'BAMBU Estudio Launcher Teste\mapas\parkour-paradise-3\servidor-mine\servidor'
$runtime=Join-Path $server 'plugins\custom-parkour-tiktok.jar'
$backupBase=Join-Path $env:LOCALAPPDATA 'BAMBU_P3_V7_BACKUP'
function Say([string]$t,[string]$c='Gray'){Write-Host $t -ForegroundColor $c}
function HasFile([string]$p){return (Test-Path -LiteralPath $p -PathType Leaf)}
function HashFile([string]$p){
 if(-not (HasFile $p)){return 'AUSENTE'}
 return (Get-FileHash -LiteralPath $p -Algorithm SHA256 -ErrorAction Stop).Hash
}
function FindEngines {
 $bases=@(
  (Get-Location).Path,
  (Join-Path $env:USERPROFILE 'Downloads'),
  ([Environment]::GetFolderPath('Desktop')),
  (Join-Path $env:LOCALAPPDATA 'Programs'),
  (Join-Path $env:LOCALAPPDATA 'BAMBU_STUDIO_P3_FINAL')
 ) | Where-Object {$_ -and (Test-Path -LiteralPath $_ -PathType Container)} | Select-Object -Unique
 $found=New-Object 'System.Collections.Generic.List[string]'
 foreach($b in $bases){
  Say ('Procurando aplicativo em: '+$b) 'DarkCyan'
  Get-ChildItem -LiteralPath $b -File -Filter 'servidor.cjs' -Recurse -Depth 7 -ErrorAction SilentlyContinue |
   Where-Object {$_.FullName -match '(?i)[\\/]resources[\\/]app[\\/]engine[\\/]servidor\.cjs$' -and $_.FullName -match '(?i)BAMBU'} |
   ForEach-Object {[void]$found.Add($_.DirectoryName)}
 }
 return @($found.ToArray() | Sort-Object -Unique)
}
function FindSource([string[]]$engines){
 $paths=New-Object 'System.Collections.Generic.List[string]'
 [void]$paths.Add((Join-Path $env:LOCALAPPDATA 'GULIVE-Local-1.25.1\servidor-mine\parkour-paradise-3\servidor\plugins\custom-parkour-tiktok.jar'))
 foreach($eng in $engines){
  [void]$paths.Add((Join-Path $eng 'bambu-paradise3-v6-source.jar'))
  [void]$paths.Add((Join-Path $eng 'bambu-paradise3-v7-source.jar'))
 }
 foreach($b in @((Join-Path $env:USERPROFILE 'Downloads'),([Environment]::GetFolderPath('Desktop')))){
  if(-not (Test-Path -LiteralPath $b -PathType Container)){continue}
  Get-ChildItem -LiteralPath $b -Recurse -Depth 7 -File -Filter 'bambu-paradise3-v6-source.jar' -ErrorAction SilentlyContinue |
   ForEach-Object {[void]$paths.Add($_.FullName)}
 }
 foreach($p in @($paths.ToArray()|Sort-Object -Unique)){
  if((HashFile $p) -eq $hashP3){return $p}
 }
 # Se o ZIP da versao que funcionou ainda existir, extrai apenas o JAR esperado.
 Add-Type -AssemblyName System.IO.Compression
 Add-Type -AssemblyName System.IO.Compression.FileSystem
 foreach($dir in @((Join-Path $env:USERPROFILE 'Downloads'),([Environment]::GetFolderPath('Desktop')))){
  if(-not (Test-Path -LiteralPath $dir -PathType Container)){continue}
  foreach($archive in @(Get-ChildItem -LiteralPath $dir -File -Filter '*GULIVE_MOTOR_CORRIGIDO*.zip' -ErrorAction SilentlyContinue)){
   $zip=$null
   try{
    $zip=[IO.Compression.ZipFile]::OpenRead($archive.FullName)
    $entry=@($zip.Entries | Where-Object {$_.FullName -match '(?i)(^|/)bambu-paradise3-v6-source\.jar$'} | Select-Object -First 1)
    if($entry.Count -eq 0){continue}
    $tmp=Join-Path $env:TEMP ('BAMBU_P3_V7_VERIFICAR_'+[guid]::NewGuid().ToString('N')+'.jar')
    $inputStream=$entry[0].Open()
    try{
     $out=[IO.File]::Create($tmp)
     try{$inputStream.CopyTo($out)}finally{$out.Dispose()}
    }finally{$inputStream.Dispose()}
    if((HashFile $tmp) -eq $hashP3){return $tmp}
    Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
   }catch{Say ('ZIP antigo ignorado: '+$archive.Name+' - '+$_.Exception.Message) 'Yellow'}
   finally{if($zip){$zip.Dispose()}}
  }
 }
 return $null
}
function Snapshot([string]$p,[string]$saveDir,[System.Collections.Generic.List[object]]$records) {
 if(@($records | Where-Object {$_.path -eq $p}).Count -gt 0){return}
 $exists=HasFile $p
 $before=HashFile $p
 $backup=''
 if($exists){
  $backup=Join-Path $saveDir (('{0:D4}' -f ($records.Count+1))+'-'+[IO.Path]::GetFileName($p)+'.bak')
  Copy-Item -LiteralPath $p -Destination $backup -Force -ErrorAction Stop
  if((HashFile $backup) -ne $before){throw ('Backup nao confere: '+$p)}
 }
 [void]$records.Add([pscustomobject]@{path=$p;existed=$exists;oldHash=$before;backup=$backup})
}
function PutJar([string]$src,[string]$dst,[string]$saveDir,[System.Collections.Generic.List[object]]$records) {
 if((HashFile $dst) -eq $hashP3){return}
 Snapshot $dst $saveDir $records
 $parent=Split-Path -Parent $dst
 if(-not (Test-Path -LiteralPath $parent -PathType Container)){New-Item -Path $parent -ItemType Directory -Force | Out-Null}
 Copy-Item -LiteralPath $src -Destination $dst -Force -ErrorAction Stop
 if((HashFile $dst) -ne $hashP3){throw ('Hash P3 incorreto apos copia: '+$dst)}
 Say ('[P3 CORRIGIDO] '+$dst) 'Green'
}
$hook=@'
'use strict';
// BAMBU-PARADISE3-V7: protege o plugin correto antes de abrir o processo Java.
// Os mundos, checkpoints e progresso nao sao modificados aqui.
(function(){
  if(global.__bambuParadise3V7)return;
  global.__bambuParadise3V7=true;
  const fs=require('node:fs');
  const path=require('node:path');
  const crypto=require('node:crypto');
  const cp=require('node:child_process');
  const wanted='201656BC3CB0462D96BB6E1FDCAEA62417D704168CD3B051CF8C0F3CF1A1F8FF';
  const source=path.join(__dirname,'bambu-paradise3-v7-source.jar');
  const server=path.join(process.env.APPDATA||'','BAMBU Estudio Launcher Teste','mapas','parkour-paradise-3','servidor-mine','servidor');
  const dest=path.join(server,'plugins','custom-parkour-tiktok.jar');
  function sha(file){return crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex').toUpperCase();}
  function sync(){
    if(!fs.existsSync(source)||sha(source)!==wanted)throw new Error('[BAMBU P3 V7] Plugin Paradise 3 fonte invalida');
    if(!fs.existsSync(server)){console.warn('[BAMBU P3 V7] Servidor ainda nao existe: '+server);return;}
    fs.mkdirSync(path.dirname(dest),{recursive:true});
    if(!fs.existsSync(dest)||sha(dest)!==wanted)fs.copyFileSync(source,dest);
    if(sha(dest)!==wanted)throw new Error('[BAMBU P3 V7] Nao foi possivel proteger o plugin Paradise 3');
    console.log('[BAMBU P3 V7] Plugin confirmado antes de iniciar Java: '+wanted);
  }
  function launch(file,args) {
    const name=path.basename(String(file||'')).toLowerCase();
    const argv=Array.isArray(args)?args.map(String).join(' '):'';
    if(['java','java.exe','javaw','javaw.exe'].includes(name))return argv.indexOf('-jar')>=0;
    if(['cmd','cmd.exe','powershell','powershell.exe','pwsh','pwsh.exe'].includes(name))
      return /java(?:w)?(?:\.exe)?/i.test(argv)&&argv.indexOf('-jar')>=0;
    return false;
  }
  for(const key of ['spawn','execFile','spawnSync','execFileSync']){
    if(typeof cp[key]!=='function')continue;
    const prev=cp[key];
    cp[key]=function(file,args){if(launch(file,args))sync();return prev.apply(this,arguments);};
  }
  for(const key of ['exec','execSync']){
    if(typeof cp[key]!=='function')continue;
    const prev=cp[key];
    cp[key]=function(command){
      const v=String(command||'');
      if(/java(?:w)?(?:\.exe)?/i.test(v)&&v.indexOf('-jar')>=0)sync();
      return prev.apply(this,arguments);
    };
  }
  try{if(fs.existsSync(server))sync();}catch(e){console.error(e.message);}
})();
'@
function Restore([System.Collections.Generic.List[object]]$records) {
 foreach($r in @($records.ToArray()) | Sort-Object -Property path -Descending){
  try{
   if($r.existed){Copy-Item -LiteralPath $r.backup -Destination $r.path -Force -ErrorAction Stop}
   else{Remove-Item -LiteralPath $r.path -Force -ErrorAction SilentlyContinue}
  }catch{Say ('[ERRO RESTAURAR] '+$r.path+': '+$_.Exception.Message) 'Red'}
 }
}
function Inspect([string[]]$engines) {
 Say '' 
 Say '[DIAGNOSTICO SOMENTE LEITURA]' 'Cyan'
 $h=HashFile $runtime
 Say ('Servidor APPDATA: '+$runtime)
 Say ('HASH: '+$h) $(if($h -eq $hashP3){'Green'}elseif($h -eq $hashP1){'Red'}else{'Yellow'})
 if($h -eq $hashP1){Say '  => Plugin Paradise 1 identificado, incompatibilidade confirmada.' 'Red'}
 foreach($e in $engines){
  Say ('MOTOR: '+$e) 'White'
  Say ('  Plugin V7: '+(HashFile (Join-Path $e 'bambu-paradise3-v7-source.jar')))
  Say ('  Plugin V6: '+(HashFile (Join-Path $e 'bambu-paradise3-v6-source.jar')))
  Say ('  Asset: '+(HashFile (Join-Path $e 'hud-layout-assets\custom-parkour-tiktok-hud-bambu.jar')))
  $c=Join-Path $e 'servidor.cjs'
  $t=[IO.File]::ReadAllText($c)
  Say ('  Hook V7: '+$t.Contains('BAMBU-PARADISE3-V7'))
  Say ('  Hook V6: '+$t.Contains('BAMBU-PARADISE3-V6'))
 }
 Say 'Se o aviso 7/7 persistir mesmo com hash P3 no processo Java, investigar mapa/checkpoints.' 'Yellow'
}
try {
 Say '===========================================================' 'Cyan'
 Say ' BAMBU STUDIO 0.5.9 - CORRECAO PARADISE 3 V7' 'Cyan'
 Say ' Protege MOTOR, COPIAS INTERNAS e PLUGIN DO SERVIDOR' 'Cyan'
 Say ' NAO apaga mundo, progresso, credenciais nem licencas' 'Green'
 Say '===========================================================' 'Cyan'
 $engines=@(FindEngines)
 if($engines.Count -eq 0){throw 'Nao encontrei a pasta resources\app\engine\servidor.cjs. Extraia a pasta do BAMBU e execute novamente.'}
 $src=FindSource $engines
 Say ''
 Say ('ORIGEM P3 VALIDA: '+$(if($src){$src}else{'NAO ENCONTRADA'})) $(if($src){'Green'}else{'Red'})
 Say ('HASH P3 ESPERADO: '+$hashP3)
 Inspect $engines
 Say ''
 Say 'MOTORES ENCONTRADOS:' 'Cyan'
 for($i=0;$i -lt $engines.Count;$i++){
  Say ('['+($i+1)+'] '+$engines[$i]) 'White'
 }
 Say '[D] Diagnosticar apenas, sem alterar'
 Say '[A] Corrigir TODOS os motores listados (so escolha se forem seus BAMBU)'
 Say '[0] Sair'
 $select=Read-Host 'Escolha um numero, A, D ou 0'
 if($select -eq '0' -or $select -eq ''){exit 0}
 if($select -match '^(?i)d$'){exit 0}
 if(-not $src){throw 'Nenhum plugin P3 com SHA-256 correto foi localizado. Nenhum arquivo alterado.'}
 $targets=@()
 if($select -match '^(?i)a$'){$targets=$engines}
 else{
  $choice=0
  if(-not([int]::TryParse($select,[ref]$choice)) -or $choice -lt 1 -or $choice -gt $engines.Count){throw 'Opcao invalida; nada alterado.'}
  $targets=@($engines[$choice-1])
 }
 Say ''
 Say 'DESLIGUE BAMBU E SERVIDOR MINECRAFT ANTES DE PROSSEGUIR.' 'Yellow'
 Say ('Motores a corrigir: '+$targets.Count)
 Say ('Plugin APPDATA: '+$runtime)
 $confirm=Read-Host 'Digite SIM para aplicar com backup'
 if($confirm -cne 'SIM'){Say 'Cancelado. Nada alterado.' 'Yellow';exit 0}
 New-Item -Path $backupBase -ItemType Directory -Force | Out-Null
 $saveDir=Join-Path $backupBase (Get-Date -Format 'yyyyMMdd_HHmmss')
 New-Item -Path $saveDir -ItemType Directory -Force | Out-Null
 $records=New-Object 'System.Collections.Generic.List[object]'
 try{
  foreach($e in $targets){
   $main=Join-Path $e 'servidor.cjs'
   $own=Join-Path $e 'bambu-paradise3-v7-source.jar'
   $hookFile=Join-Path $e 'bambu-paradise3-v7-hook.cjs'
   PutJar $src $own $saveDir $records
   # Corrige cada origem EMBUTIDA com hash comprovadamente igual ao plugin errado P1.
   $appDir=Split-Path -Parent $e
   Get-ChildItem -LiteralPath $appDir -Filter '*.jar' -File -Recurse -ErrorAction SilentlyContinue |
    Where-Object {$_.FullName -ne $own -and (HashFile $_.FullName) -eq $hashP1} |
    ForEach-Object {PutJar $src $_.FullName $saveDir $records}
   Snapshot $hookFile $saveDir $records
   [IO.File]::WriteAllText($hookFile,$hook,[Text.UTF8Encoding]::new($false))
   Snapshot $main $saveDir $records
   $original=[IO.File]::ReadAllText($main)
   if(-not $original.Contains('BAMBU-PARADISE3-V7')){
    [IO.File]::WriteAllText($main,("require('./bambu-paradise3-v7-hook.cjs'); // BAMBU-PARADISE3-V7"+[Environment]::NewLine+$original),[Text.UTF8Encoding]::new($false))
   }
   if(-not [IO.File]::ReadAllText($main).Contains('BAMBU-PARADISE3-V7')){throw ('Hook V7 nao instalado em '+$main)}
   Say ('[OK] MOTOR PROTEGIDO: '+$e) 'Green'
  }
  if(HasFile $runtime){PutJar $src $runtime $saveDir $records}
  $manifest=Join-Path $saveDir 'BACKUP_V7_MANIFEST.json'
  [IO.File]::WriteAllText($manifest,($records.ToArray()|ConvertTo-Json -Depth 7),[Text.UTF8Encoding]::new($false))
  Say ''
  Say '[OK] CORRECAO V7 APLICADA COM BACKUP!' 'Green'
  Say ('BACKUP: '+$saveDir) 'Green'
  Say 'Se corrigiu a PASTA FONTE NSIS, REGENERE O INSTALADOR a partir dela.' 'Yellow'
  Say 'Se corrigiu apenas o aplicativo INSTALADO, isto nao altera o instalador antigo.' 'Yellow'
  Say 'Abra o BAMBU e o Minecraft e verifique se o aviso desapareceu.' 'Cyan'
  Say 'Rode novamente este script e escolha D para checar hashes apos iniciar o servidor.' 'Cyan'
 }catch{
  Say ('[ERRO] '+$_.Exception.Message) 'Red'
  Say 'Restaurando backups da tentativa...' 'Yellow'
  Restore $records
  throw
 }
}catch{
 Say ('[ERRO] '+$_.Exception.Message) 'Red'
 exit 1
}
