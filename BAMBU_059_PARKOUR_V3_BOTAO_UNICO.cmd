@echo off
setlocal
title BAMBU 0.5.9 - PARKOUR V3 BOTAO UNICO
set "SCRIPT_BAMBU=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$c=[IO.File]::ReadAllText($env:SCRIPT_BAMBU);$m='# CODIGO_BAMBU_V3';$p=$c.LastIndexOf($m);if($p -lt 0){throw 'Falha ao iniciar V3'};& ([scriptblock]::Create($c.Substring($p+$m.Length)))"
echo.
echo Pressione qualquer tecla para fechar.
pause >nul
exit /b

# CODIGO_BAMBU_V3
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = Join-Path $env:LOCALAPPDATA 'BAMBU_PARKOUR_V3_BACKUP'
$manifest = Join-Path $root 'registro.json'
$original = Join-Path $env:LOCALAPPDATA 'GULIVE-Local-1.25.1\servidor-mine\parkour-paradise-1\servidor\plugins\custom-parkour-tiktok.jar'
$runtime1 = Join-Path $env:APPDATA 'BAMBU Estudio Launcher Teste\mapas\parkour-paradise-3\servidor-mine\servidor\plugins\custom-parkour-tiktok.jar'
$runtime2 = Join-Path $env:APPDATA 'bambu-studio\servidor-mine\servidor\plugins\custom-parkour-tiktok.jar'

function Out([string]$msg,[string]$color='Gray'){Write-Host $msg -ForegroundColor $color}
function Sha([string]$p){ (Get-FileHash -LiteralPath $p -Algorithm SHA256 -ErrorAction Stop).Hash }
function Test-Plugin([string]$p){
    $z=$null
    try{
        if(-not(Test-Path -LiteralPath $p -PathType Leaf)){return $false}
        $z=[IO.Compression.ZipFile]::OpenRead($p)
        foreach($name in @('plugin.yml','br/com/tparkour/Commands.class','br/com/tparkour/SetupService.class','br/com/tparkour/ShieldService.class','br/com/tparkour/JailService.class','br/com/tparkour/TParkourPlugin.class')){
            if(-not $z.GetEntry($name)){return $false}
        }
        return $true
    }catch{return $false}
    finally{if($z){$z.Dispose()}}
}
function Locate-Embedded {
    $found=New-Object 'System.Collections.Generic.List[string]'
    foreach($folder in @((Join-Path $env:USERPROFILE 'Downloads'),(Join-Path $env:USERPROFILE 'Desktop'),(Join-Path $env:USERPROFILE 'OneDrive'))){
        if(-not(Test-Path -LiteralPath $folder -PathType Container)){continue}
        Out ('Procurando recurso interno: '+$folder)
        Get-ChildItem -LiteralPath $folder -Filter 'custom-parkour-tiktok-hud-bambu.jar' -File -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object {$_.FullName -match '(?i)BAMBU_STUDIO' -and $_.FullName -match '(?i)0_5_9' -and $_.FullName -match '(?i)resources[\\/]app[\\/]engine[\\/]hud-layout-assets'} |
            ForEach-Object {[void]$found.Add($_.FullName)}
    }
    @($found.ToArray() | Sort-Object -Unique)
}
function Locate-Targets {
    $items=New-Object 'System.Collections.Generic.List[string]'
    foreach($p in @($runtime1,$runtime2)){
        if(Test-Path -LiteralPath $p -PathType Leaf){[void]$items.Add($p)}
    }
    foreach($p in @(Locate-Embedded)){
        if(Test-Path -LiteralPath $p -PathType Leaf){[void]$items.Add($p)}
    }
    @($items.ToArray() | Sort-Object -Unique)
}
function Check {
    if(-not(Test-Plugin $original)){throw 'Plugin GULIVE nao encontrado ou invalido. Nenhum arquivo foi alterado.'}
    $h=Sha $original
    Out ('GULIVE: '+$h) 'Cyan'
    $targets=@(Locate-Targets)
    if($targets.Count -eq 0){Out '[ERRO] Nao encontrei os arquivos da BAMBU 0.5.9.' 'Red';return}
    Out ''
    Out 'ARQUIVOS BAMBU / COMPARACAO:' 'Cyan'
    foreach($p in $targets){
        $status=if((Sha $p) -eq $h){'[IGUAL AO GULIVE]'}else{'[DIFERENTE]'}
        Out ($status+' '+$p) $(if($status -eq '[IGUAL AO GULIVE]'){'Green'}else{'Yellow'})
    }
    Out ''
    Out 'Se ficar DIFERENTE apos abrir pelo botao unico, o launcher esta' 'Yellow'
    Out 'recriando o .jar de outra origem. Nao repita a troca no escuro.' 'Yellow'
}
function Install {
    if(-not(Test-Plugin $original)){throw 'Nao encontrei o plugin GULIVE valido. Nada foi alterado.'}
    $targets=@(Locate-Targets)
    if($targets.Count -eq 0){throw 'Nao encontrei arquivos BAMBU 0.5.9. Nada foi alterado.'}
    $h=Sha $original
    Out ''
    Out 'A V3 altera SOMENTE estes arquivos .jar:' 'Cyan'
    foreach($p in $targets){
        $status=if((Sha $p) -eq $h){'JA IGUAL'}else{'SERA ATUALIZADO'}
        Out ('['+$status+'] '+$p) 'White'
    }
    Out ''
    Out 'O botao unico do BAMBU nao sera modificado.' 'Green'
    Out 'O plugin GULIVE pode mudar o HUD personalizado BAMBU.' 'Yellow'
    Out 'Feche BAMBU e servidor antes de continuar.' 'Yellow'
    $answer=Read-Host 'Digite SIM para fazer backup e substituir os .jar'
    if($answer -cne 'SIM'){Out '[CANCELADO] Nada alterado.' 'Yellow';return}

    New-Item -ItemType Directory -Path $root -Force | Out-Null
    $stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
    $records=New-Object 'System.Collections.Generic.List[object]'
    $counter=0
    foreach($p in $targets){
        $old=Sha $p
        if($old -eq $h){continue}
        $counter++
        $backup=Join-Path $root ($stamp+'_'+$counter+'.jar.bak')
        Copy-Item -LiteralPath $p -Destination $backup -ErrorAction Stop
        if((Sha $backup) -ne $old){throw ('Backup nao confere. Abortado: '+$p)}
        $records.Add([pscustomobject]@{destination=$p;backup=$backup;original_hash=$old})
    }
    if($records.Count -eq 0){
        Out '[OK] Todos os arquivos encontrados ja sao iguais ao GULIVE.' 'Green'
        Out 'Se no jogo configurar nao funcionar, o BAMBU usa outro arquivo ou o comando tem outra implementacao.' 'Yellow'
        return
    }
    if(Test-Path -LiteralPath $manifest -PathType Leaf){
        $prior=Join-Path $root ('registro_anterior_'+$stamp+'.json')
        Copy-Item -LiteralPath $manifest -Destination $prior
    }
    $data=[pscustomobject]@{date=(Get-Date).ToString('s');GuliveHash=$h;records=@($records.ToArray())}
    [IO.File]::WriteAllText($manifest,($data | ConvertTo-Json -Depth 6),(New-Object Text.UTF8Encoding($false)))
    try{
        foreach($r in $records){
            $tmp=$r.destination+'.v3-temp'
            try{
                Copy-Item -LiteralPath $original -Destination $tmp -ErrorAction Stop
                if((Sha $tmp) -ne $h){throw 'Erro ao copiar arquivo temporario.'}
                Copy-Item -LiteralPath $tmp -Destination $r.destination -Force -ErrorAction Stop
                if((Sha $r.destination) -ne $h){throw 'Falha na verificacao depois da troca.'}
            }finally{
                Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
            }
            Out ('[OK] '+$r.destination) 'Green'
        }
    }catch{
        foreach($r in $records){Copy-Item -LiteralPath $r.backup -Destination $r.destination -Force -ErrorAction SilentlyContinue}
        throw ('Instalacao falhou. Tentativa de reversao aplicada. '+$_.Exception.Message)
    }
    Out ''
    Out '[OK] Todas as copias selecionadas atualizadas e verificadas!' 'Green'
    Out ('BACKUP: '+$root) 'Green'
    Out 'Agora use o seu BOTAO UNICO normalmente, entre no jogo e teste /tparkour configurar.' 'Cyan'
    Out 'Se aparecer subcomando desconhecido, rode V3 opcao 2 apos abrir o BAMBU.' 'Yellow'
}
function Restore{
    if(-not(Test-Path -LiteralPath $manifest -PathType Leaf)){throw 'Nenhum registro de backup V3 encontrado.'}
    $data=Get-Content -LiteralPath $manifest -Raw -Encoding UTF8 | ConvertFrom-Json
    Out 'ARQUIVOS QUE VOLTARAO AO ORIGINAL ANTES DA V3:' 'Cyan'
    foreach($r in @($data.records)){Out ('  '+$r.destination) 'White'}
    $answer=Read-Host 'BAMBU e servidor fechados? Digite SIM para restaurar'
    if($answer -cne 'SIM'){Out 'Cancelado.';return}
    foreach($r in @($data.records)){
        if(-not(Test-Path -LiteralPath $r.backup -PathType Leaf)){throw ('Backup ausente: '+$r.backup)}
        if((Sha $r.backup) -ne [string]$r.original_hash){throw ('Backup invalido: '+$r.backup)}
    }
    foreach($r in @($data.records)){
        Copy-Item -LiteralPath $r.backup -Destination $r.destination -Force -ErrorAction Stop
        Out ('[RESTAURADO] '+$r.destination) 'Green'
    }
    Out '[OK] Reversao concluida. Pode abrir o BAMBU.' 'Green'
}
try{
    Out '============================================================' 'Cyan'
    Out ' BAMBU 0.5.9 - PARKOUR V3 / BOTAO UNICO' 'Cyan'
    Out ' Corrige copias do plugin + backup, SEM mudar o botao' 'Cyan'
    Out '============================================================' 'Cyan'
    Out '[1] Corrigir plugin com backup' 'White'
    Out '[2] Verificar hashes antes/depois de iniciar BAMBU' 'White'
    Out '[3] Restaurar arquivos antes da V3' 'White'
    Out '[0] Sair' 'White'
    $mode=Read-Host 'Escolha'
    switch($mode){
        '1' {Install}
        '2' {Check}
        '3' {Restore}
        '0' {exit 0}
        default {throw 'Opcao invalida.'}
    }
}catch{
    Out ('[ERRO] '+$_.Exception.Message) 'Red'
    exit 1
}
