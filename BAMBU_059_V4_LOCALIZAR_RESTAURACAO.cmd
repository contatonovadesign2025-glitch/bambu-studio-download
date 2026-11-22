@echo off
setlocal
title BAMBU 0.5.9 - LOCALIZAR RESTAURACAO DO PLUGIN - V4
set "SELF_FILE=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$s=[IO.File]::ReadAllText($env:SELF_FILE);$m='# BAMBU_ANALISADOR_V4';$i=$s.LastIndexOf($m);if($i -lt 0){throw 'Marcador ausente'};& ([scriptblock]::Create($s.Substring($i+$m.Length)))"
echo.
echo Pressione uma tecla para fechar.
pause >nul
exit /b

# BAMBU_ANALISADOR_V4
$ErrorActionPreference='Stop'
$desktop=[Environment]::GetFolderPath('Desktop')
if(-not $desktop -or -not (Test-Path -LiteralPath $desktop -PathType Container)){$desktop=Join-Path $env:USERPROFILE 'Downloads'}
$report=Join-Path $desktop 'BAMBU_PARKOUR_V4_ORIGEM_DO_PLUGIN.txt'
$runtime=Join-Path $env:APPDATA 'BAMBU Estudio Launcher Teste\mapas\parkour-paradise-3\servidor-mine\servidor\plugins\custom-parkour-tiktok.jar'
$gulive=Join-Path $env:LOCALAPPDATA 'GULIVE-Local-1.25.1\servidor-mine\parkour-paradise-1\servidor\plugins\custom-parkour-tiktok.jar'
$resourceNames=@('custom-parkour-tiktok-hud-bambu.jar','custom-parkour-tiktok.jar','tparkour-parkourparadise.jar')
$lines=New-Object 'System.Collections.Generic.List[string]'
function L([string]$s){[void]$script:lines.Add($s);Write-Host $s}
function GetHash([string]$p){try{(Get-FileHash -LiteralPath $p -Algorithm SHA256 -ErrorAction Stop).Hash}catch{'ERRO'}}
function Scan-Code([string]$path){
    L ("[CODIGO] "+$path)
    $found=0
    try {
        $ln=0
        $prev=New-Object 'System.Collections.Generic.Queue[string]'
        foreach($line in [IO.File]::ReadLines($path)){
            $ln++
            if($prev.Count -ge 2){$null=$prev.Dequeue()}
            if($line -match '(?i)custom-parkour|tparkour-parkour|hud-layout-assets|parkour-tiktok'){
                $found++
                if($found -le 40){
                    L ("LINHA $ln: "+$line.Substring(0,[Math]::Min($line.Length,550)))
                }
            }
            $prev.Enqueue($line)
        }
        if($found -gt 40){L ('... mais '+($found-40)+' ocorrencias neste arquivo')}
    }catch{L ('AVISO leitura: '+$_.Exception.Message)}
}
try{
    L '================================================================'
    L ' DIAGNOSTICO V4 - QUEM RESTAURA O PLUGIN DO BAMBU 0.5.9?'
    L ' Apenas LEITURA. Nao substitui JAR e nao altera o aplicativo.'
    L '================================================================'
    L ('DATA: '+(Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))
    L ''
    $gh='INEXISTENTE'
    $rh='INEXISTENTE'
    if(Test-Path -LiteralPath $gulive -PathType Leaf){$gh=GetHash $gulive}
    if(Test-Path -LiteralPath $runtime -PathType Leaf){$rh=GetHash $runtime}
    L ('GULIVE SHA256: '+$gh)
    L ('BAMBU  SHA256: '+$rh)
    L ('BAMBU RUNTIME: '+$runtime)
    L ''
    L '[1] LISTA DE JARS DO BAMBU E HASHES'
    $archives=New-Object 'System.Collections.Generic.List[object]'
    foreach($r in @((Join-Path $env:USERPROFILE 'Downloads'),(Join-Path $env:USERPROFILE 'Desktop'),$env:APPDATA)){
        if(-not(Test-Path -LiteralPath $r -PathType Container)){continue}
        Write-Host ('Procurando .jar em '+$r) -ForegroundColor Cyan
        Get-ChildItem -LiteralPath $r -Filter '*parkour*.jar' -File -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object {$_.FullName -match '(?i)BAMBU|parkour-paradise-3' -and $_.FullName -notmatch '(?i)BACKUP|GULIVE|gift\.live'} |
        ForEach-Object {[void]$archives.Add($_)}
    }
    $foundArchives=@($archives.ToArray() | Sort-Object FullName -Unique)
    foreach($jar in $foundArchives){
        $h=GetHash $jar.FullName
        $type=if($h -eq $gh){'[GULIVE]'}elseif($h -eq $rh){'[IGUAL AO RUNTIME ANTIGO]'}else{'[OUTRO]'}
        L ($type+' '+$h+' '+$jar.FullName)
    }
    L ''
    L '[2] ARQUIVOS DE CODIGO QUE CITAM O PLUGIN'
    $folders=New-Object 'System.Collections.Generic.List[string]'
    foreach($jar in $foundArchives){
        if($jar.DirectoryName -match '(?i)resources[\\/]app[\\/]engine[\\/]hud-layout-assets'){
            $engine=(Get-Item -LiteralPath $jar.DirectoryName).Parent
            $app=$engine.Parent
            if($app -and (Test-Path -LiteralPath $app.FullName -PathType Container)){[void]$folders.Add($app.FullName)}
        }
    }
    foreach($extra in @(
        (Join-Path $env:APPDATA 'BAMBU Estudio Launcher Teste'),
        (Join-Path $env:APPDATA 'bambu-studio')
    )){
        if(Test-Path -LiteralPath $extra -PathType Container){[void]$folders.Add($extra)}
    }
    $code=New-Object 'System.Collections.Generic.List[object]'
    foreach($folder in @($folders.ToArray() | Sort-Object -Unique)){
        L ('RAIZ DE CODIGO: '+$folder)
        Write-Host ('Inspecionando '+$folder) -ForegroundColor Cyan
        Get-ChildItem -LiteralPath $folder -File -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object {
           $_.Extension -in @('.js','.cjs','.mjs','.json','.cmd','.bat','.ps1') -and
           $_.Length -lt 6MB -and
           $_.FullName -notmatch '(?i)node_modules[\\/]|[\\/]libraries[\\/]|[\\/]logs[\\/]|[\\/]cache[\\/]|[\\/]world[\\/]'
        } | ForEach-Object {[void]$code.Add($_)}
    }
    $all=@($code.ToArray() | Sort-Object FullName -Unique)
    L ('Total de arquivos de codigo candidatos: '+$all.Count)
    $matchFiles=0
    foreach($f in $all){
        try{
            $found=Select-String -LiteralPath $f.FullName -Pattern 'custom-parkour','tparkour-parkour','hud-layout-assets','parkour-tiktok' -SimpleMatch -Quiet -ErrorAction Stop
            if($found){$matchFiles++;Scan-Code $f.FullName}
        }catch{}
    }
    L ('Arquivos de codigo com referencias: '+$matchFiles)
    if($matchFiles -eq 0){
        L 'Nenhuma referencia textual encontrada; o codigo pode estar empacotado em app.asar ou vir de download.'
    }
    L ''
    L '[3] ARQUIVOS DE EMPACOTAMENTO'
    foreach($folder in @($folders.ToArray() | Sort-Object -Unique)){
        Get-ChildItem -LiteralPath $folder -Include '*.asar','*.zip' -File -Recurse -ErrorAction SilentlyContinue |
        Select-Object -First 15 | ForEach-Object { L ('PACOTE: '+$_.FullName+' ('+$_.Length+' bytes)') }
    }
    L ''
    L 'FIM. Nenhum arquivo do jogo foi modificado.'
    $encoding=New-Object System.Text.UTF8Encoding($true)
    [IO.File]::WriteAllLines($report,$lines.ToArray(),$encoding)
    Write-Host ''
    Write-Host ('RELATORIO CRIADO: '+$report) -ForegroundColor Green
    Write-Host 'Envie o TXT ao ChatGPT. Confira antes se contem credenciais.' -ForegroundColor Yellow
} catch{
    Write-Host ('[ERRO] '+$_.Exception.Message) -ForegroundColor Red
    try{[IO.File]::WriteAllLines($report,$lines.ToArray())}catch{}
    exit 1
}
