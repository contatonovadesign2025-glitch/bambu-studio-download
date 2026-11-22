@echo off
setlocal
title BAMBU STUDIO 0.5.9 - CORRECAO PARKOUR V2
set "BAMBU_FILE=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$s=[IO.File]::ReadAllText($env:BAMBU_FILE);$m='# BAMBU_V2_POWERSHELL_START';$i=$s.LastIndexOf($m);if($i -lt 0){throw 'Marcador ausente'};& ([scriptblock]::Create($s.Substring($i+$m.Length)))"
echo.
echo Pressione qualquer tecla para fechar...
pause >nul
exit /b

# BAMBU_V2_POWERSHELL_START
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$state=Join-Path $env:LOCALAPPDATA 'BAMBU_PARKOUR_TESTE_V2'
$manifest=Join-Path $state 'ultima_instalacao.json'
$sourcePath=Join-Path $env:LOCALAPPDATA 'GULIVE-Local-1.25.1\servidor-mine\parkour-paradise-1\servidor\plugins\custom-parkour-tiktok.jar'
$templatePath=Join-Path $env:USERPROFILE 'Downloads\BAMBU_STUDIO_TESTE_0_5_9_INTERFACE_RC10_PORTATIL\BAMBU_STUDIO_0_5_9_PORTATIL_INTERFACE_INTEGRADA\resources\app\engine\hud-layout-assets\custom-parkour-tiktok-hud-bambu.jar'
function Say([string]$s,[string]$color='Gray'){ Write-Host $s -ForegroundColor $color }
function Jar-Ok([string]$path){
    $z=$null
    try {
        if(-not(Test-Path -LiteralPath $path -PathType Leaf)){return $false}
        $z=[IO.Compression.ZipFile]::OpenRead($path)
        foreach($e in @('br/com/tparkour/TParkourPlugin.class','br/com/tparkour/ShieldService.class','br/com/tparkour/SetupService.class','br/com/tparkour/JailService.class','br/com/tparkour/Commands.class','plugin.yml')){
            if($null -eq $z.GetEntry($e)){return $false}
        }
        return $true
    }catch{return $false}
    finally{if($z){$z.Dispose()}}
}
function Roots {
    @($env:LOCALAPPDATA,$env:APPDATA,(Join-Path $env:USERPROFILE 'Downloads'),(Join-Path $env:USERPROFILE 'Desktop'),(Join-Path $env:USERPROFILE 'OneDrive')) |
        Where-Object {$_ -and (Test-Path -LiteralPath $_ -PathType Container)} | Select-Object -Unique
}
function Find-Runtime {
    $paths=New-Object 'System.Collections.Generic.List[string]'
    foreach($root in Roots){
        Say ("Procurando plugins de servidor em: "+$root)
        Get-ChildItem -LiteralPath $root -Filter '*parkour*.jar' -File -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.Directory.Name -ieq 'plugins' -and $_.FullName -notmatch '(?i)GULIVE-Local|gift\.live|BACKUP_BAMBU_PARKOUR|BAMBU_PARKOUR_TESTE_V2' } |
            ForEach-Object { $paths.Add($_.FullName) }
    }
    @($paths | Sort-Object -Unique)
}
function Choose([string[]]$items,[string]$label){
    if(-not $items -or $items.Count -eq 0){return $null}
    Say $label 'Cyan'
    for($i=0;$i -lt $items.Count;$i++){Say ("[{0}] {1}" -f ($i+1),$items[$i]) 'White'}
    if($items.Count -eq 1){Say '[OK] Encontrado 1 candidato.' 'Green';return $items[0]}
    $n=Read-Host 'Digite o numero (0 = cancelar)'
    $p=0
    if(-not [int]::TryParse($n,[ref]$p) -or $p -lt 1 -or $p -gt $items.Count){throw 'Opcao cancelada/invalida. Nenhuma alteracao feita.'}
    return $items[$p-1]
}
function Restore {
    if(-not(Test-Path -LiteralPath $manifest -PathType Leaf)){throw 'Backup desta versao nao encontrado.'}
    $data=Get-Content -LiteralPath $manifest -Raw -Encoding UTF8 | ConvertFrom-Json
    $records=@($data.records)
    if($records.Count -eq 0){throw 'Backup vazio.'}
    Say 'BACKUPS QUE SERAO RESTAURADOS:' 'Cyan'
    foreach($r in $records){Say ("  "+$r.destination) 'White'}
    $a=Read-Host 'Fechou servidor e BAMBU? Digite SIM para restaurar'
    if($a -cne 'SIM'){Say 'Restauracao cancelada.' 'Yellow';return}
    foreach($r in $records){
        if(-not(Test-Path -LiteralPath $r.backup -PathType Leaf)){throw ('Backup indisponivel: '+$r.backup)}
        Copy-Item -LiteralPath $r.backup -Destination $r.destination -Force -ErrorAction Stop
        Say ('[OK] Restaurado: '+$r.destination) 'Green'
    }
    Say 'Restauracao concluida. Inicie o BAMBU.' 'Green'
}
try{
    Say '============================================================' 'Cyan'
    Say ' BAMBU 0.5.9 - INSTALADOR V2 / PLUGIN GULIVE (TESTE)' 'Cyan'
    Say ' Busca o plugin real do SERVIDOR, nao so hud-layout-assets' 'Cyan'
    Say '============================================================' 'Cyan'
    Say '[1] Instalar teste com backup' 'White'
    Say '[2] Restaurar arquivos anteriores' 'White'
    Say '[0] Sair' 'White'
    $mode=Read-Host 'Opcao'
    if($mode -eq '0'){exit 0}
    if($mode -eq '2'){Restore;exit 0}
    if($mode -ne '1'){throw 'Opcao invalida.'}

    if(-not(Jar-Ok $sourcePath)){
        Say 'Nao encontrei a origem valida no caminho usado pelo GULIVE.' 'Yellow'
        $entered=Read-Host 'Cole o caminho COMPLETO do custom-parkour-tiktok.jar do GULIVE'
        $sourcePath=$entered.Trim().Trim('"')
        if(-not(Jar-Ok $sourcePath)){throw 'Arquivo origem nao corresponde ao plugin esperado; abortado.'}
    }
    Say ('[OK] Plugin GULIVE: '+$sourcePath) 'Green'
    $runtime=@(Find-Runtime)
    $runtimePath=Choose $runtime 'PLUGINS DE SERVIDOR ENCONTRADOS (ESCOLHA O BAMBU):'

    if(-not $runtimePath){
        Say 'Nao foi encontrado um plugin de servidor do BAMBU.' 'Yellow'
        Say 'O instalador pode atualizar o arquivo de origem embutido no RC10,' 'Yellow'
        Say 'mas NAO podemos garantir que o Minecraft carregara esse arquivo.' 'Yellow'
        if(-not(Test-Path -LiteralPath $templatePath -PathType Leaf)){
            throw 'Nao encontrei nem a pasta real do servidor nem o arquivo do RC10. Nada alterado.'
        }
    }

    $targets=New-Object 'System.Collections.Generic.List[string]'
    if($runtimePath){$targets.Add($runtimePath)}
    if(Test-Path -LiteralPath $templatePath -PathType Leaf){
        $targets.Add($templatePath)
    }else{
        Say 'Pacote RC10 conhecido nao encontrado. Sera atualizado somente o plugin real do servidor.' 'Yellow'
    }
    $targets=@($targets | Sort-Object -Unique)
    if($targets.Count -eq 0){throw 'Nenhum arquivo de destino encontrado. Nada alterado.'}
    Say ''
    Say 'ATENCAO: O GULIVE pode mudar o HUD personalizado do BAMBU.' 'Yellow'
    Say 'O teste apenas troca JARs; nao garante que todas as funcoes funcionem.' 'Yellow'
    Say 'Nao modifica mundos, mapas, saves, ou checkpoints.yml.' 'Green'
    Say 'ORIGEM:' 'Cyan'
    Say ('  '+$sourcePath) 'White'
    Say 'DESTINOS:' 'Cyan'
    foreach($dest in $targets){Say ('  '+$dest) 'White'}
    if(-not $runtimePath){
        Say 'ALERTA: somente o recurso embutido sera atualizado. O servidor nao foi localizado!' 'Yellow'
    }
    $ans=Read-Host 'Servidor e BAMBU FECHADOS? Digite SIM para instalar'
    if($ans -cne 'SIM'){Say 'Cancelado sem alterar nada.' 'Yellow';exit 0}

    New-Item -Path $state -ItemType Directory -Force | Out-Null
    $stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
    $records=New-Object 'System.Collections.Generic.List[object]'
    $n=0
    foreach($dest in $targets){
        if($dest -match '(?i)GULIVE-Local|gift\.live'){throw 'Destino GULIVE bloqueado.'}
        if(-not(Test-Path -LiteralPath $dest -PathType Leaf)){throw 'Arquivo destino deixou de existir. Abortando.'}
        $n++
        $backup=Join-Path $state ($stamp+'_'+$n+'_'+[IO.Path]::GetFileName($dest)+'.backup')
        Copy-Item -LiteralPath $dest -Destination $backup -ErrorAction Stop
        if((Get-Item -LiteralPath $dest).Length -ne (Get-Item -LiteralPath $backup).Length){throw 'Falha ao conferir backup: '+$dest}
        $records.Add([pscustomobject]@{destination=$dest;backup=$backup})
    }
    $data=[pscustomobject]@{installed=(Get-Date).ToString('s');source=$sourcePath;records=@($records.ToArray())}
    $data | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifest -Encoding UTF8
    try{
        foreach($dest in $targets){
            Copy-Item -LiteralPath $sourcePath -Destination $dest -Force -ErrorAction Stop
            if(-not(Jar-Ok $dest)){throw ('Arquivo copiado nao passou validacao: '+$dest)}
            Say ('[OK] Instalado: '+$dest) 'Green'
        }
    }catch{
        Say ('Falha de instalacao. Revertendo: '+$_.Exception.Message) 'Red'
        foreach($r in $records){Copy-Item -LiteralPath $r.backup -Destination $r.destination -Force -ErrorAction SilentlyContinue}
        throw 'Instalacao abortada e backups usados para reversao.'
    }
    Say ''
    Say '[OK] Instalacao de teste concluida!' 'Green'
    Say ('[OK] BACKUP: '+$state) 'Green'
    Say 'Inicie BAMBU, entre no mapa e digite /tparkour configurar' 'Cyan'
    Say 'Se falhar, execute este CMD e escolha 2 para reverter.' 'Yellow'
    if(-not $runtimePath){Say 'ATENCAO: plugin do servidor nao localizado. Verifique o log ao iniciar.' 'Yellow'}
}catch{
    Say ('[ERRO] '+$_.Exception.Message) 'Red'
    exit 1
}
