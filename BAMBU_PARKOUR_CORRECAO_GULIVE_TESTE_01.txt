@echo off
setlocal
title BAMBU STUDIO 0.5.9 - Correcao Parkour TESTE 01
set "BAMBU_SELF=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$c=[System.IO.File]::ReadAllText($env:BAMBU_SELF);$m='# INICIO_CODIGO_POWERSHELL_BAMBU_059';$i=$c.LastIndexOf($m);if($i -lt 0){throw 'Marcador do instalador nao encontrado'};& ([scriptblock]::Create($c.Substring($i+$m.Length)))"
echo.
echo Pressione uma tecla para fechar.
pause >nul
exit /b

# INICIO_CODIGO_POWERSHELL_BAMBU_059
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Say([string]$message, [string]$color = 'Gray') {
    Write-Host $message -ForegroundColor $color
}
function Get-Roots {
    @(
        $env:LOCALAPPDATA
        $env:APPDATA
        (Join-Path $env:USERPROFILE 'Downloads')
        (Join-Path $env:USERPROFILE 'Desktop')
        (Join-Path $env:USERPROFILE 'OneDrive')
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Container) } | Select-Object -Unique
}
function Test-GuliveJar([string]$path) {
    $jar = $null
    try {
        $jar = [System.IO.Compression.ZipFile]::OpenRead($path)
        foreach ($required in @(
            'br/com/tparkour/TParkourPlugin.class',
            'br/com/tparkour/ShieldService.class',
            'br/com/tparkour/SetupService.class',
            'br/com/tparkour/JailService.class',
            'br/com/tparkour/Commands.class',
            'plugin.yml'
        )) {
            if ($null -eq $jar.GetEntry($required)) { return $false }
        }
        return $true
    } catch {
        return $false
    } finally {
        if ($null -ne $jar) { $jar.Dispose() }
    }
}
function Find-Targets {
    $list = New-Object 'System.Collections.Generic.List[object]'
    foreach ($root in Get-Roots) {
        Say ("Procurando BAMBU em: " + $root)
        foreach ($fileName in @('custom-parkour-tiktok-hud-bambu.jar', 'tparkour-parkourparadise.jar')) {
            Get-ChildItem -LiteralPath $root -Filter $fileName -File -Recurse -Force -ErrorAction SilentlyContinue |
                Where-Object { $_.FullName -match '(?i)bambu' -and $_.FullName -notmatch '(?i)GULIVE-Local|gift\.live|BACKUP_BAMBU_PARKOUR' } |
                ForEach-Object { [void]$list.Add($_) }
        }
    }
    @($list | Sort-Object -Property FullName -Unique)
}
function Find-Sources {
    $list = New-Object 'System.Collections.Generic.List[object]'
    $search = @(
        (Join-Path $env:LOCALAPPDATA 'GULIVE-Local-1.25.1')
        (Join-Path $env:USERPROFILE 'Downloads')
        (Join-Path $env:USERPROFILE 'Desktop')
        (Join-Path $env:USERPROFILE 'OneDrive')
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Container) } | Select-Object -Unique
    foreach ($root in $search) {
        Say ("Procurando plugin original em: " + $root)
        Get-ChildItem -LiteralPath $root -Filter '*parkour*.jar' -File -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.Length -gt 120000 -and $_.Length -lt 4000000 -and (Test-GuliveJar $_.FullName) } |
            ForEach-Object { [void]$list.Add($_) }
    }
    @($list | Sort-Object -Property FullName -Unique)
}
function Pick-File([object[]]$files, [string]$what) {
    if (-not $files -or $files.Count -eq 0) { return $null }
    Say ""
    Say $what 'Cyan'
    for ($i = 0; $i -lt $files.Count; $i++) {
        Write-Host ("[{0}] {1}" -f ($i + 1), $files[$i].FullName)
    }
    if ($files.Count -eq 1) { Say 'Selecionado automaticamente: 1' 'Green'; return $files[0] }
    $answer = Read-Host "Digite o numero desejado (Enter = 1)"
    if (-not $answer) { $answer = '1' }
    $number = 0
    if (-not [int]::TryParse($answer, [ref]$number) -or $number -lt 1 -or $number -gt $files.Count) {
        throw 'Opcao invalida. Nenhuma alteracao foi feita.'
    }
    return $files[$number - 1]
}

try {
    Say '============================================================' 'Cyan'
    Say ' BAMBU STUDIO 0.5.9 - TESTE DO PLUGIN ORIGINAL GULIVE' 'Cyan'
    Say ' Backup antes da troca e opcao de reverter' 'Cyan'
    Say '============================================================' 'Cyan'
    Say 'Este TESTE substitui SOMENTE o plugin .jar escolhido.' 'Yellow'
    Say 'Nao altera mapas, mundos, checkpoints.yml ou saves.' 'Green'
    Say 'Pode mudar temporariamente o HUD personalizado do BAMBU.' 'Yellow'
    Say 'Feche BAMBU e servidor Minecraft ANTES de continuar.' 'Yellow'
    Say ''
    Say '[1] Instalar plugin do GULIVE (teste)' 'White'
    Say '[2] Restaurar plugin original BAMBU (backup)' 'White'
    Say '[0] Sair' 'White'
    $mode = Read-Host 'Escolha'
    if ($mode -eq '0') { exit 0 }
    if ($mode -notin @('1', '2')) { throw 'Opcao invalida.' }

    $targets = @(Find-Targets)
    $target = Pick-File $targets 'ARQUIVOS DO BAMBU ENCONTRADOS:'
    if ($null -eq $target) {
        Say 'Nao encontrei o plugin BAMBU automaticamente.' 'Yellow'
        $manual = (Read-Host 'Cole o CAMINHO COMPLETO do plugin .jar do BAMBU').Trim('"')
        if (-not (Test-Path -LiteralPath $manual -PathType Leaf)) {
            throw 'Plugin de destino nao encontrado. Nenhuma alteracao foi feita.'
        }
        if ($manual -match '(?i)GULIVE-Local|gift\.live') {
            throw 'Este caminho pertence ao GULIVE, nao ao BAMBU. Abortado.'
        }
        $target = Get-Item -LiteralPath $manual
    }

    $parent = Split-Path -Parent $target.FullName
    $backupDir = Join-Path $parent 'BACKUP_BAMBU_PARKOUR'
    if ($mode -eq '2') {
        if (-not (Test-Path -LiteralPath $backupDir)) {
            throw 'Nenhum backup encontrado para este arquivo.'
        }
        $backups = @(Get-ChildItem -LiteralPath $backupDir -Filter '*.original.jar' -File |
            Sort-Object -Property LastWriteTime -Descending)
        $backup = Pick-File $backups 'BACKUPS DISPONIVEIS:'
        if ($null -eq $backup) { throw 'Nenhum backup disponivel.' }
        Copy-Item -LiteralPath $backup.FullName -Destination $target.FullName -Force
        Say ('[OK] Plugin original restaurado em: ' + $target.FullName) 'Green'
        Say '[OK] Agora inicie o servidor BAMBU.' 'Green'
        exit 0
    }

    $sources = @(Find-Sources | Where-Object { $_.FullName -ne $target.FullName })
    $source = Pick-File $sources 'PLUGINS DO GULIVE ENCONTRADOS:'
    if ($null -eq $source) {
        Say 'Nao encontrei automaticamente o .jar do GULIVE.' 'Yellow'
        $manual = (Read-Host 'Cole o caminho completo de custom-parkour-tiktok(1).jar').Trim('"')
        if (-not (Test-Path -LiteralPath $manual -PathType Leaf)) {
            throw 'Original do GULIVE nao encontrado. Nenhuma alteracao foi feita.'
        }
        $source = Get-Item -LiteralPath $manual
    }
    if (-not (Test-GuliveJar $source.FullName)) {
        throw 'O arquivo selecionado NAO contem as classes de escudo, configuracao e prisao esperadas. Abortado.'
    }
    if ($target.FullName -eq $source.FullName) {
        throw 'Origem e destino sao iguais. Abortado.'
    }

    Say ''
    Say ('ORIGEM GULIVE : ' + $source.FullName) 'Cyan'
    Say ('DESTINO BAMBU : ' + $target.FullName) 'Cyan'
    Say ('Tamanho novo  : ' + $source.Length + ' bytes') 'Cyan'
    Say ''
    $ok = Read-Host 'Servidor fechado? Confirmar a troca experimental (digite SIM)'
    if ($ok -ne 'SIM') {
        Say 'Cancelado sem alteracoes.' 'Yellow'
        exit 0
    }

    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $backupPath = Join-Path $backupDir ($stamp + '_' + $target.BaseName + '.original.jar')
    Copy-Item -LiteralPath $target.FullName -Destination $backupPath -ErrorAction Stop
    if ((Get-Item -LiteralPath $backupPath).Length -ne $target.Length) {
        throw 'Falha ao conferir o backup. Destino original intacto.'
    }
    $tmp = Join-Path $parent ('bambu_teste_' + $stamp + '.tmp')
    try {
        Copy-Item -LiteralPath $source.FullName -Destination $tmp -ErrorAction Stop
        if (-not (Test-GuliveJar $tmp)) {
            throw 'Falha ao conferir a copia do plugin GULIVE.'
        }
        Copy-Item -LiteralPath $tmp -Destination $target.FullName -Force -ErrorAction Stop
    } catch {
        Copy-Item -LiteralPath $backupPath -Destination $target.FullName -Force
        throw ('Nao foi possivel instalar. Backup restaurado. ' + $_.Exception.Message)
    } finally {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
    $hash = (Get-FileHash -LiteralPath $target.FullName -Algorithm SHA256).Hash
    Set-Content -LiteralPath (Join-Path $backupDir 'ULTIMA_INSTALACAO.txt') -Value @(
        'BAMBU TESTE 01'
        ('Destino: ' + $target.FullName)
        ('Origem: ' + $source.FullName)
        ('Backup: ' + $backupPath)
        ('SHA256 instalado: ' + $hash)
    ) -Encoding UTF8
    Say ''
    Say '[OK] Plugin GULIVE instalado no local selecionado!' 'Green'
    Say ('[OK] BACKUP ORIGINAL: ' + $backupPath) 'Green'
    Say '[TESTE] Abra BAMBU e inicie o Minecraft.' 'Cyan'
    Say '[TESTE] No chat: /tparkour configurar' 'Cyan'
    Say '[TESTE] Verifique escudos, teto99 e negativo.' 'Cyan'
    Say '[TESTE] No console: tparkour escudo brunexttk' 'Cyan'
    Say '[TESTE] No console: tparkour libertar brunexttk' 'Cyan'
    Say '[AVISO] Se nao funcionar, execute este mesmo CMD e escolha 2.' 'Yellow'
} catch {
    Say ''
    Say ('[ERRO] ' + $_.Exception.Message) 'Red'
    exit 1
}
