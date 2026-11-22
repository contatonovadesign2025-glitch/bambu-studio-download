@echo off
setlocal DisableDelayedExpansion
title BAMBU STUDIO 0.5.9 - DIAGNOSTICO SOMENTE LEITURA
set "BAMBU_DIAG_SELF=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$t=[IO.File]::ReadAllText($env:BAMBU_DIAG_SELF);$m='# INICIO_POWERSHELL_DIAGNOSTICO_BAMBU';$i=$t.LastIndexOf($m);if($i -lt 0){throw 'Marcador do diagnostico ausente'};& ([scriptblock]::Create($t.Substring($i+$m.Length)))"
set "BAMBU_DIAG_RC=%ERRORLEVEL%"
echo.
echo Pressione uma tecla para fechar.
pause >nul
exit /b %BAMBU_DIAG_RC%

# INICIO_POWERSHELL_DIAGNOSTICO_BAMBU
$ErrorActionPreference='Stop'
$hashP3='201656BC3CB0462D96BB6E1FDCAEA62417D704168CD3B051CF8C0F3CF1A1F8FF'
$hashP1='D2A65F6E9FD1280C96E1B874641E8829CEE28D62EA7D7E87CCEFDA6F6ED79380'

function Say([string]$value,[string]$color='Gray'){Write-Host $value -ForegroundColor $color}
function Full([string]$p){if(-not $p){return ''};try{return [IO.Path]::GetFullPath($p)}catch{return $p}}
function ExistsDir([string]$p){return [bool]($p -and (Test-Path -LiteralPath $p -PathType Container))}
function HashJar([string]$p){
 if(-not $p -or -not(Test-Path -LiteralPath $p -PathType Leaf)){return 'AUSENTE'}
 try{return (Get-FileHash -LiteralPath $p -Algorithm SHA256 -ErrorAction Stop).Hash.ToUpperInvariant()}
 catch{return 'ERRO_AO_LER'}
}
function PluginStatus([string]$hash){
 if($hash -eq $hashP1){return 'PARADISE_1_ERRADO'}
 if($hash -eq $hashP3){return 'PARADISE_3_CORRETO'}
 if($hash -eq 'AUSENTE'){return 'AUSENTE'}
 return 'OUTRO_OU_DESCONHECIDO'
}
function RootStatus([string]$p){
 if($p -match '(?i)[\\/]BAMBU Estudio Launcher Teste([\\/]|$)'){return 'PROTEGER_DADOS_MINECRAFT'}
 if($p -match '(?i)[\\/]Programs[\\/]BAMBU'){return 'INSTALADO_VERIFICAR_QUAL_USA'}
 if($p -match '(?i)backup|anterior|_ANTERIOR_'){return 'BACKUP_NAO_APAGAR_SEM_CONFERIR'}
 if($p -match '(?i)gerador|NSIS|INSTALADOR_WINDOWS'){return 'FONTE_INSTALADOR_PROTEGER'}
 if($p -match '(?i)RC10|teste|portatil|semifinal'){return 'VERSAO_TESTE_OU_COPIA_ANALISAR'}
 return 'ANALISAR_ANTES_DE_LIMPAR'
}
function FolderStats([string]$path){
 $count=[long]0;$bytes=[long]0;$errors=[int]0
 try{
  Get-ChildItem -LiteralPath $path -File -Recurse -Force -ErrorAction SilentlyContinue |
    ForEach-Object {$count++;$bytes += [long]$_.Length}
 }catch{$errors++}
 return [pscustomobject]@{Count=$count;Bytes=$bytes;ReadErrors=$errors}
}
function ExportRows([object[]]$rows,[string]$name){
 if($rows.Count -gt 0){$rows | Export-Csv -LiteralPath (Join-Path $out $name) -NoTypeInformation -Encoding UTF8}
}

try {
 Say '==========================================================' 'Cyan'
 Say ' BAMBU STUDIO 0.5.9 - DIAGNOSTICO SEM EXCLUIR NADA' 'Cyan'
 Say ' Inventario do PC, motores, backups, plugins e atalhos' 'White'
 Say ' Nao remove, move, instala nem altera arquivos do BAMBU.' 'Green'
 Say ' Cria SOMENTE relatorios de diagnostico em Downloads.' 'Green'
 Say '==========================================================' 'Cyan'
 Say ''
 $desktop=[Environment]::GetFolderPath('Desktop')
 $downloads=Join-Path $env:USERPROFILE 'Downloads'
 $local=$env:LOCALAPPDATA
 $roaming=$env:APPDATA
 $server=Join-Path $roaming 'BAMBU Estudio Launcher Teste\mapas\parkour-paradise-3\servidor-mine\servidor'
 $runtime=Join-Path $server 'plugins\custom-parkour-tiktok.jar'
 $serverData=Join-Path $roaming 'BAMBU Estudio Launcher Teste'
 $programs=Join-Path $local 'Programs'
 $p3final=Join-Path $local 'BAMBU_STUDIO_P3_FINAL'
 $rootsToSearch=@($desktop,$downloads,$programs,$p3final) | Where-Object {ExistsDir $_} | Sort-Object -Unique
 $outputBase=if(ExistsDir $downloads){$downloads}elseif(ExistsDir $desktop){$desktop}else{$env:TEMP}
 $out=Join-Path $outputBase ('BAMBU_DIAGNOSTICO_'+(Get-Date -Format 'yyyyMMdd_HHmmss'))
 New-Item -ItemType Directory -Path $out -Force -ErrorAction Stop | Out-Null
 Say ('RELATORIOS: '+$out) 'Green'
 Say ''
 Say '[1/6] Localizando motores do BAMBU...' 'Cyan'
 $engineSet=New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
 foreach($root in $rootsToSearch){
  Say ('  Procurando em: '+$root)
  try {
   Get-ChildItem -LiteralPath $root -Filter 'servidor.cjs' -File -Recurse -Force -ErrorAction SilentlyContinue |
     Where-Object {$_.FullName -match '(?i)[\\/]resources[\\/]app[\\/]engine[\\/]servidor\.cjs$' -and $_.FullName -match '(?i)BAMBU'} |
     ForEach-Object {[void]$engineSet.Add($_.DirectoryName)}
  }catch{Say ('  Aviso de leitura: '+$_.Exception.Message) 'Yellow'}
 }
 $engines=@($engineSet | Sort-Object)
 $enginesInfo=New-Object 'System.Collections.Generic.List[object]'
 $folderSet=New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
 foreach($p in @($serverData,$p3final)){
  if(ExistsDir $p){[void]$folderSet.Add((Full $p))}
 }
 foreach($base in @($desktop,$downloads,$programs)){
  if(-not(ExistsDir $base)){continue}
  try {
   Get-ChildItem -LiteralPath $base -Directory -Force -ErrorAction SilentlyContinue |
      Where-Object {$_.Name -match '(?i)BAMBU'} |
      ForEach-Object {[void]$folderSet.Add((Full $_.FullName))}
  }catch{}
 }
 foreach($e in $engines){
  $app=Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $e))
  if(ExistsDir $app){[void]$folderSet.Add((Full $app))}
  $main=Join-Path $e 'servidor.cjs'
  $body=''
  try{$body=[IO.File]::ReadAllText($main)}catch{}
  $asset=Join-Path $e 'hud-layout-assets\custom-parkour-tiktok-hud-bambu.jar'
  $v6=Join-Path $e 'bambu-paradise3-v6-source.jar'
  $v7=Join-Path $e 'bambu-paradise3-v7-source.jar'
  $assetHash=HashJar $asset
  $v6Hash=HashJar $v6
  $v7Hash=HashJar $v7
  $enginesInfo.Add([pscustomobject]@{
   Aplicacao=$app;Motor=$e;Tipo=(RootStatus $app);
   Plugin_asset_SHA256=$assetHash;Plugin_asset_estado=(PluginStatus $assetHash);
   Plugin_V6_SHA256=$v6Hash;Plugin_V6_estado=(PluginStatus $v6Hash);
   Plugin_V7_SHA256=$v7Hash;Plugin_V7_estado=(PluginStatus $v7Hash);
   Hook_V6=[bool]$body.Contains('BAMBU-PARADISE3-V6');
   Hook_V7=[bool]$body.Contains('BAMBU-PARADISE3-V7')
  })
 }
 ExportRows @($enginesInfo.ToArray()) '01_MOTORES_E_PLUGINS.csv'
 Say ('  Motores encontrados: '+$engines.Count) 'White'
 Say '[2/6] Medindo tamanho das pastas BAMBU (pode demorar)...' 'Cyan'
 $foldersInfo=New-Object 'System.Collections.Generic.List[object]'
 foreach($folder in @($folderSet | Sort-Object)){
  if(-not(ExistsDir $folder)){continue}
  $stat=FolderStats $folder
  $modified=''
  try{$modified=(Get-Item -LiteralPath $folder).LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')}catch{}
  $foldersInfo.Add([pscustomobject]@{
   Tipo=(RootStatus $folder);Pasta=$folder;
   Arquivos=$stat.Count;Tamanho_GB=[math]::Round(($stat.Bytes/1GB),3);
   Bytes=$stat.Bytes;Ultima_modificacao_da_pasta=$modified;
   Observacao='NAO excluir sem revisar; pastas podem se sobrepor'
  })
  Say ('  '+$stat.Count+' arquivos | '+[math]::Round($stat.Bytes/1MB,1)+' MB | '+$folder)
 }
 ExportRows @($foldersInfo.ToArray()) '02_PASTAS_TAMANHOS.csv'
 Say '[3/6] Identificando plugins do servidor atual...' 'Cyan'
 $pluginRows=New-Object 'System.Collections.Generic.List[object]'
 $pluginsDir=Join-Path $server 'plugins'
 if(ExistsDir $pluginsDir){
  foreach($f in @(Get-ChildItem -LiteralPath $pluginsDir -File -Filter '*.jar' -Force -ErrorAction SilentlyContinue)){
   $h=HashJar $f.FullName
   $pluginRows.Add([pscustomobject]@{Arquivo=$f.FullName;Tamanho_MB=[math]::Round($f.Length/1MB,2);SHA256=$h;Classificacao=(PluginStatus $h)})
  }
 }
 foreach($source in @(
  (Join-Path $local 'GULIVE-Local-1.25.1\servidor-mine\parkour-paradise-3\servidor\plugins\custom-parkour-tiktok.jar'),
  (Join-Path $local 'GULIVE-Local-1.25.1\servidor-mine\parkour-paradise-1\servidor\plugins\custom-parkour-tiktok.jar')
 )){
  if(Test-Path -LiteralPath $source -PathType Leaf){
   $h=HashJar $source
   $pluginRows.Add([pscustomobject]@{Arquivo=$source;Tamanho_MB=[math]::Round((Get-Item -LiteralPath $source).Length/1MB,2);SHA256=$h;Classificacao=(PluginStatus $h)})
  }
 }
 ExportRows @($pluginRows.ToArray()) '03_PLUGINS_SERVIDOR_E_ORIGEM.csv'
 Say ('  Hash atual do plugin em APPDATA: '+(HashJar $runtime)) 'White'
 Say '[4/6] Listando ZIPs, EXEs e geradores relacionados ao BAMBU...' 'Cyan'
 $archiveRows=New-Object 'System.Collections.Generic.List[object]'
 foreach($base in @($desktop,$downloads) | Sort-Object -Unique){
  if(-not(ExistsDir $base)){continue}
  try {
   Get-ChildItem -LiteralPath $base -File -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object {$_.Name -match '(?i)BAMBU' -and $_.Extension -in @('.zip','.exe','.rar','.7z','.cmd','.ps1','.msi')} |
    ForEach-Object {
     $archiveRows.Add([pscustomobject]@{Arquivo=$_.FullName;Tamanho_MB=[math]::Round($_.Length/1MB,2);Modificado=$_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss');Observacao='Somente inventario, sem excluir'})
    }
  }catch{}
 }
 ExportRows @($archiveRows.ToArray()) '04_INSTALADORES_E_ARQUIVOS.csv'
 Say '[5/6] Conferindo programas instalados e atalhos BAMBU...' 'Cyan'
 $installedRows=New-Object 'System.Collections.Generic.List[object]'
 $uninstallKeys=@(
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
 )
 foreach($key in $uninstallKeys){
  try {
   Get-ItemProperty -Path $key -ErrorAction SilentlyContinue |
    Where-Object {$_.DisplayName -match '(?i)BAMBU'} |
    ForEach-Object {
     $installedRows.Add([pscustomobject]@{Programa=$_.DisplayName;Versao=$_.DisplayVersion;Local_instalado=$_.InstallLocation;Registro=$key})
    }
  }catch{}
 }
 ExportRows @($installedRows.ToArray()) '05_PROGRAMAS_INSTALADOS.csv'
 $linkRows=New-Object 'System.Collections.Generic.List[object]'
 try{
  $wsh=New-Object -ComObject WScript.Shell
  $linkDirs=@($desktop,(Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'),(Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs')) | Sort-Object -Unique
  foreach($dir in $linkDirs){
   if(-not(ExistsDir $dir)){continue}
   Get-ChildItem -LiteralPath $dir -Filter '*.lnk' -File -Recurse -ErrorAction SilentlyContinue |
    Where-Object {$_.Name -match '(?i)BAMBU'} |
    ForEach-Object {
     try {
      $shortcut=$wsh.CreateShortcut($_.FullName)
      $linkRows.Add([pscustomobject]@{Atalho=$_.FullName;Destino=$shortcut.TargetPath;Existe_destino=(Test-Path -LiteralPath $shortcut.TargetPath)})
     }catch{}
    }
  }
 }catch{Say '  Atalhos: sem acesso ao Windows Script Host; restante do diagnostico preservado.' 'Yellow'}
 ExportRows @($linkRows.ToArray()) '06_ATALHOS.csv'
 Say '[6/6] Gerando resumo...' 'Cyan'
 $processRows=New-Object 'System.Collections.Generic.List[object]'
 try {
  foreach($proc in @(Get-Process -ErrorAction SilentlyContinue | Where-Object {$_.ProcessName -match '(?i)BAMBU|java|electron'})){
   $processRows.Add([pscustomobject]@{Processo=$proc.ProcessName;PID=$proc.Id;Observacao='Java/Electron podem pertencer a outro software'})
  }
 }catch{}
 ExportRows @($processRows.ToArray()) '07_PROCESSOS_EM_EXECUCAO.csv'
 $runtimeHash=HashJar $runtime
 $summary=New-Object 'System.Collections.Generic.List[string]'
 $summary.Add('BAMBU STUDIO 0.5.9 - RELATORIO DE DIAGNOSTICO SOMENTE LEITURA')
 $summary.Add('Gerado em: '+(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
 $summary.Add('NENHUMA pasta do BAMBU foi excluida, movida ou modificada.')
 $summary.Add('A unica gravacao foi a criacao destes arquivos de relatorio.')
 $summary.Add('')
 $summary.Add('MOTORES DETECTADOS: '+$engines.Count)
 $summary.Add('PASTAS CATALOGADAS: '+$foldersInfo.Count)
 $summary.Add('ARQUIVOS ZIP/EXE/CMD ETC: '+$archiveRows.Count)
 $summary.Add('REGISTROS DE PROGRAMAS: '+$installedRows.Count)
 $summary.Add('ATALHOS: '+$linkRows.Count)
 $summary.Add('')
 $summary.Add('PLUGIN DO SERVIDOR ATUAL: '+$runtime)
 $summary.Add('SHA256: '+$runtimeHash)
 $summary.Add('INTERPRETACAO: '+(PluginStatus $runtimeHash))
 $summary.Add('')
 $summary.Add('ITENS QUE NAO DEVEM SER EXCLUIDOS SEM CONFIRMACAO:')
 $summary.Add('- Dados Minecraft, mundos, saves, configs e progresso em %APPDATA%\BAMBU Estudio Launcher Teste.')
 $summary.Add('- Fonte do gerador NSIS / arquivos APP_BAMBU_0_5_9 em uso.')
 $summary.Add('- Arquivos de licenca e configuracoes de login, RCON e integracoes.')
 $summary.Add('- Pelo menos uma copia verificada do plugin correto Paradise 3.')
 $summary.Add('- Programa instalado que esta sendo utilizado pelo usuario.')
 $summary.Add('')
 $summary.Add('AVISOS:')
 $summary.Add('- Tamanhos de pastas que se sobrepoem nao devem ser somados.')
 $summary.Add('- Pastas chamadas BACKUP/TESTE nao sao automaticamente seguras para exclusao.')
 $summary.Add('- Este diagnostico nao identifica com certeza qual atalho o usuario esta abrindo.')
 $summary.Add('- Nao imprime conteudos de tokens, chaves nem senhas.')
 $summary.Add('- Saidas CSV podem conter nome do usuario do Windows nos caminhos. Revise antes de publicar.')
 $summary.Add('')
 $summary.Add('PRINCIPAIS PASTAS POR TAMANHO:')
 foreach($p in @($foldersInfo.ToArray() | Sort-Object Bytes -Descending | Select-Object -First 25)){
  $summary.Add(('{0:N3} GB | {1} arquivos | {2} | {3}' -f $p.Tamanho_GB,$p.Arquivos,$p.Tipo,$p.Pasta))
 }
 $summary.Add('')
 $summary.Add('MOTORES:')
 foreach($e in @($enginesInfo.ToArray())){
  $summary.Add($e.Motor)
  $summary.Add('  Asset: '+$e.Plugin_asset_estado+' | V6: '+$e.Plugin_V6_estado+' | V7: '+$e.Plugin_V7_estado+' | Hook V7: '+$e.Hook_V7)
 }
 $summary.Add('')
 $summary.Add('PROXIMO PASSO: Enviar o arquivo RESUMO.txt e os CSVs ao ChatGPT para triagem. Nao executar comandos de limpeza ainda.')
 $summary | Out-File -LiteralPath (Join-Path $out '00_LEIA_PRIMEIRO_RESUMO.txt') -Encoding UTF8
 Say ''
 Say '==========================================================' 'Green'
 Say ' DIAGNOSTICO CONCLUIDO - NADA FOI APAGADO' 'Green'
 Say '==========================================================' 'Green'
 Say ('RESULTADO: '+$out) 'White'
 Say ('MOTORES: '+$engines.Count+' | PASTAS: '+$foldersInfo.Count+' | INSTALADORES: '+$archiveRows.Count)
 Say ''
 Say 'Envie o arquivo 00_LEIA_PRIMEIRO_RESUMO.txt e, se possivel, todos os CSVs.' 'Cyan'
 Say 'Importante: arquivos do relatorio mostram caminhos com seu nome de usuario.' 'Yellow'
 try{Start-Process -FilePath 'explorer.exe' -ArgumentList ('"'+$out+'"') -ErrorAction SilentlyContinue | Out-Null}catch{}
}catch {
 Say ('ERRO NO DIAGNOSTICO: '+$_.Exception.Message) 'Red'
 Say 'Nao apagamos nem alteramos arquivos do BAMBU.' 'Yellow'
 exit 1
}
