@echo off
setlocal
title BAMBU STUDIO 0.5.9 RC10 - GERADOR FINAL V4 COM ATALHOS
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
$stagingRoot=$desktop
$staging=Join-Path $stagingRoot 'BAMBU_FINAL_P3'
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
 Note ' Cria pasta, ZIP e instalador EXE COM ATALHOS em uma execucao' 'Cyan'
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
 if(Test-Path -LiteralPath $staging -PathType Container){
   $saved=Join-Path $desktop ('BAMBU_FINAL_P3_ANTERIOR_'+$stamp)
   Move-Item -LiteralPath $staging -Destination $saved -ErrorAction Stop
   Note ('Pasta anterior preservada: '+$saved) 'Yellow'
 }
 Note 'Copiando o aplicativo completo (executavel, recursos, motor e plugins)...' 'Cyan'
 New-Item -ItemType Directory -Path $appDest -Force | Out-Null
 RobocopyChecked $appSource $appDest @('/XD','logs','crash-reports','.git','BACKUP','BACKUPS','/XF','.env','.env.*','*.pem','*.p12','*.key')
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
PACOTE FINAL BAMBU STUDIO 0.5.9 RC10 + PARKOUR PARADISE 3
=================================================================
ESTRUTURA:
BAMBU_FINAL_P3\
  BAMBU_STUDIO\                Aplicativo completo e motor corrigido
  MAPA_PARADISE_3_BASE\        Mundo e servidor base sem dados pessoais
  INICIAR_BAMBU_FINAL.cmd      Abrir diretamente SEM instalar
  INSTALAR_BAMBU_FINAL.cmd     Instalar copia em AppData (sem apagar mundos)
  GERAR_INSTALADOR_EXE.cmd     Gerar instalador .exe com Inno Setup 6 opcional
  BAMBU_INSTALADOR_FINAL_P3.iss  Projeto do instalador .exe
  LEIA-ME_BAMBU_FINAL.txt
  MANIFESTO_FINAL.json

PARA USAR:
1) Clique duas vezes em INICIAR_BAMBU_FINAL.cmd, dentro de BAMBU_FINAL_P3.
2) No BAMBU clique no botao unico Preparar e iniciar servidor.
3) Entre no Minecraft 26.2 e use a configuracao SIM/NAO.

PARA INSTALAR NO WINDOWS:
Execute INSTALAR_BAMBU_FINAL.cmd (faz copia da pasta completa em AppData).
Opcional: se o Inno Setup 6 estiver instalado, use GERAR_INSTALADOR_EXE.cmd
para produzir o instalador .exe dentro da pasta INSTALADOR_EXE.
Nao e necessario instalar Inno Setup para jogar ou usar o BAMBU.

INTEGRIDADE:
Motor BAMBU RC10 integrado ao plugin especifico do GULIVE Paradise 3.
SHA256 esperado do JAR: 201656BC3CB0462D96BB6E1FDCAEA62417D704168CD3B051CF8C0F3CF1A1F8FF
O ZIP final e verificado apos a geracao.

DADOS PESSOAIS E PROGRESSO:
A base do mapa nao inclui ops.json, usercache, senha RCON nem progresso
individual dos jogadores. O iniciador nao substitui o mundo ja existente.
Mantenha copia da versao anterior em funcionamento.

VALIDACAO PENDENTE:
Embora o plugin carregue e as tres perguntas SIM/NAO funcionem,
os 100 checkpoints e todos os presentes precisam de teste de partida completa.
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

 $installer=@'
@echo off
setlocal
title INSTALADOR BAMBU STUDIO FINAL - PARKOUR PARADISE 3
echo ==========================================================
echo BAMBU STUDIO 0.5.9 - INSTALADOR WINDOWS
echo Instalacao local sem apagar progresso do Minecraft
echo ==========================================================
echo.
if not exist "%~dp0BAMBU_STUDIO\Bambu Studio Teste.exe" (
 echo [ERRO] O aplicativo nao esta ao lado deste instalador.
 pause
 exit /b 1
)
if not exist "%~dp0MAPA_PARADISE_3_BASE\world\level.dat" (
 echo [ERRO] A pasta do mapa Paradise 3 nao esta completa.
 pause
 exit /b 1
)
set "DEST=%LOCALAPPDATA%\BAMBU_STUDIO_P3_FINAL"
echo Destino: "%DEST%"
echo O servidor e o progresso ja existentes nao serao apagados.
choice /M "Instalar BAMBU STUDIO FINAL"
if errorlevel 2 exit /b 0
if not exist "%DEST%" mkdir "%DEST%"
robocopy "%~dp0" "%DEST%" /E /R:2 /W:1 /NP /NFL /NDL /NJH /NJS /XD "INSTALADOR_EXE"
if errorlevel 8 (
 echo [ERRO] Falha na copia do aplicativo. Nao execute a instalacao incompleta.
 pause
 exit /b 1
)
if not exist "%DEST%\BAMBU_STUDIO\resources\app\engine\bambu-paradise3-v6-source.jar" (
 echo [ERRO] Plugin P3 ausente apos a copia.
 pause
 exit /b 1
)
echo.
echo [OK] BAMBU instalado em: "%DEST%"
echo Execute "%DEST%\INICIAR_BAMBU_FINAL.cmd"
echo Nenhum mundo preexistente foi sobrescrito pelo instalador.
pause
exit /b 0
'@
 $inno=@'
#define AppName "BAMBU STUDIO Parkour Paradise 3"
#define AppVersion "0.5.9"
[Setup]
AppId={{B8F76537-4C5E-4463-95AC-420B58C15573}
AppName={#AppName}
AppVersion={#AppVersion}
DefaultDirName={localappdata}\BAMBU_STUDIO_P3_FINAL
DefaultGroupName=BAMBU STUDIO
PrivilegesRequired=lowest
OutputDir=INSTALADOR_EXE
OutputBaseFilename=Instalar_BAMBU_STUDIO_059_PARKOUR_P3
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayName=BAMBU STUDIO Parkour Paradise 3
[Files]
Source: "BAMBU_STUDIO\*"; DestDir: "{app}\BAMBU_STUDIO"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "MAPA_PARADISE_3_BASE\*"; DestDir: "{app}\MAPA_PARADISE_3_BASE"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "INICIAR_BAMBU_FINAL.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "LEIA-ME_BAMBU_FINAL.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "MANIFESTO_FINAL.json"; DestDir: "{app}"; Flags: ignoreversion
[Icons]
Name: "{autoprograms}\BAMBU STUDIO - Paradise 3"; Filename: "{cmd}"; Parameters: "/C ""{app}\INICIAR_BAMBU_FINAL.cmd"""; WorkingDir: "{app}"
Name: "{autodesktop}\BAMBU STUDIO - Paradise 3"; Filename: "{cmd}"; Parameters: "/C ""{app}\INICIAR_BAMBU_FINAL.cmd"""; WorkingDir: "{app}"; Tasks: desktopicon
[Tasks]
Name: "desktopicon"; Description: "Criar atalho na Area de Trabalho"; GroupDescription: "Atalhos:"
'@
 $makeExe=@'
@echo off
setlocal
title GERAR INSTALADOR EXE DO BAMBU FINAL
cd /d "%~dp0"
set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if not exist "%ISCC%" set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if not exist "%ISCC%" (
 for /f "delims=" %%I in ('where ISCC.exe 2^>nul') do if not defined FOUND_ISCC set "FOUND_ISCC=%%I"
 if defined FOUND_ISCC set "ISCC=%FOUND_ISCC%"
)
if not exist "%ISCC%" (
 echo [AVISO] Inno Setup 6 nao esta instalado no Windows.
 echo O BAMBU ja esta pronto para uso pelo INICIAR_BAMBU_FINAL.cmd
 echo e para instalar pelo INSTALAR_BAMBU_FINAL.cmd.
 echo Para gerar um .EXE, instale Inno Setup 6 e rode este arquivo novamente.
 pause
 exit /b 2
)
echo Compilando instalador oficial Inno Setup...
"%ISCC%" "%~dp0BAMBU_INSTALADOR_FINAL_P3.iss"
if errorlevel 1 (
 echo [ERRO] Compilacao do instalador EXE falhou.
 pause
 exit /b 1
)
echo [OK] Instalador EXE na pasta INSTALADOR_EXE.
pause
'@
 [IO.File]::WriteAllText((Join-Path $staging 'INSTALAR_BAMBU_FINAL.cmd'),$installer,$utf8)
 [IO.File]::WriteAllText((Join-Path $staging 'GERAR_INSTALADOR_EXE.cmd'),$makeExe,$utf8)
 [IO.File]::WriteAllText((Join-Path $staging 'BAMBU_INSTALADOR_FINAL_P3.iss'),$inno,$utf8)
 Note '[OK] Instalador CMD e gerador EXE opcional incluidos.' 'Green'

 Note 'Compactando ZIP final com TAR do Windows (caminhos relativos curtos)...' 'Cyan'
 if(-not(Get-Command 'tar.exe' -ErrorAction SilentlyContinue)){
   throw 'O tar.exe do Windows nao esta disponivel. A PASTA PRONTA foi preservada na Area de Trabalho.'
 }
 & tar.exe -a -c -f $destZip -C $desktop 'BAMBU_FINAL_P3'
 if($LASTEXITCODE -ne 0){
   throw ('Compactacao TAR retornou codigo '+$LASTEXITCODE+'. A PASTA PRONTA continua completa: '+$staging)
 }
 $z=[IO.Compression.ZipFile]::OpenRead($destZip)
 try{
   foreach($required in @(
     ('BAMBU_FINAL_P3/INICIAR_BAMBU_FINAL.cmd'),
     ('BAMBU_FINAL_P3/BAMBU_STUDIO/resources/app/engine/bambu-paradise3-v6-source.jar'),
     ('BAMBU_FINAL_P3/BAMBU_STUDIO/resources/app/engine/bambu-paradise3-v6-hook.cjs'),
     ('BAMBU_FINAL_P3/INSTALAR_BAMBU_FINAL.cmd'),
     ('BAMBU_FINAL_P3/GERAR_INSTALADOR_EXE.cmd'),
     ('BAMBU_FINAL_P3/BAMBU_INSTALADOR_FINAL_P3.iss'),
     ('BAMBU_FINAL_P3/MAPA_PARADISE_3_BASE/world/level.dat')
   )){
     if(-not $z.GetEntry($required)){throw ('Arquivo ausente no ZIP gerado: '+$required)}
   }
 } finally {$z.Dispose()}

 Note ''
 Note 'Gerando o instalador EXE automaticamente com o compilador do Windows...' 'Cyan'
 $compilerOptions = @(
   (Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'),
   (Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe')
 )
 $csc = @($compilerOptions | Where-Object {Test-Path -LiteralPath $_ -PathType Leaf} | Select-Object -First 1)
 if($csc.Count -eq 0){
   throw 'Compilador nativo do .NET Framework nao encontrado. A pasta pronta e o ZIP permanecem na Area de Trabalho.'
 }
 $installerExe=Join-Path $desktop 'Instalar_BAMBU_STUDIO_059_PARKOUR_P3_V4_COM_ATALHO.exe'
 if(Test-Path -LiteralPath $installerExe -PathType Leaf){
   $savedExe=Join-Path $desktop ('Instalar_BAMBU_STUDIO_059_PARKOUR_P3_ANTERIOR_'+$stamp+'.exe')
   Move-Item -LiteralPath $installerExe -Destination $savedExe -ErrorAction Stop
   Note ('Backup do instalador anterior: '+$savedExe) 'Yellow'
 }
 $csPath=Join-Path $env:TEMP ('BambuFinalInstaller_'+$stamp+'.cs')
 $installerCode=@'
using System;
using System.IO;
using System.IO.Compression;
using System.Diagnostics;
using System.Reflection;
using System.Windows.Forms;

internal static class BambuStudioInstaller
{
    [STAThread]
    private static void Main()
    {
        try
        {
            DialogResult confirm = MessageBox.Show(
                "Instalar BAMBU STUDIO 0.5.9 RC10 - Parkour Paradise 3?\n\n" +
                "Inclui o aplicativo, servidor base e mapa.\n" +
                "O progresso ja existente do Minecraft nao sera apagado.\n\n" +
                "Feche o BAMBU e o servidor antes de instalar.",
                "BAMBU STUDIO - Instalador Final",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);
            if (confirm != DialogResult.Yes) return;

            string dest = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "BAMBU_STUDIO_P3_FINAL");
            string destFull = Path.GetFullPath(dest).TrimEnd(Path.DirectorySeparatorChar);
            string safePrefix = destFull + Path.DirectorySeparatorChar;
            Directory.CreateDirectory(destFull);

            using (Stream payload = Assembly.GetExecutingAssembly().GetManifestResourceStream("BambuPayload"))
            {
                if (payload == null) throw new IOException("Pacote interno nao encontrado no instalador.");
                using (ZipArchive zip = new ZipArchive(payload, ZipArchiveMode.Read))
                {
                    foreach (ZipArchiveEntry entry in zip.Entries)
                    {
                        string rel = entry.FullName.Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar);
                        if (String.IsNullOrWhiteSpace(rel)) continue;
                        string outPath = Path.GetFullPath(Path.Combine(destFull, rel));
                        if (!outPath.StartsWith(safePrefix, StringComparison.OrdinalIgnoreCase))
                            throw new IOException("Caminho invalido no pacote: " + entry.FullName);
                        if (String.IsNullOrEmpty(entry.Name))
                        {
                            Directory.CreateDirectory(outPath);
                            continue;
                        }
                        Directory.CreateDirectory(Path.GetDirectoryName(outPath));
                        using (Stream read = entry.Open())
                        using (FileStream write = new FileStream(outPath, FileMode.Create, FileAccess.Write, FileShare.None))
                            read.CopyTo(write);
                    }
                }
            }

            string start = Path.Combine(destFull, "BAMBU_FINAL_P3", "INICIAR_BAMBU_FINAL.cmd");
            if (!File.Exists(start)) throw new IOException("Inicializador do BAMBU nao encontrado depois de instalar.");
            string appIcon = Path.Combine(destFull, "BAMBU_FINAL_P3", "BAMBU_STUDIO", "Bambu Studio Teste.exe");
            if (!File.Exists(appIcon)) throw new IOException("Executavel do BAMBU nao encontrado apos a instalacao.");

            // DesktopDirectory resolve a verdadeira Area de Trabalho, inclusive quando redirecionada ao OneDrive.
            string desktop = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
            string programs = Environment.GetFolderPath(Environment.SpecialFolder.Programs);
            if (String.IsNullOrWhiteSpace(desktop) || String.IsNullOrWhiteSpace(programs))
                throw new IOException("Nao foi possivel localizar a Area de Trabalho ou o menu Iniciar.");
            Directory.CreateDirectory(desktop);
            string menuFolder = Path.Combine(programs, "BAMBU STUDIO");
            Directory.CreateDirectory(menuFolder);
            CreateShortcut(Path.Combine(desktop, "BAMBU STUDIO.lnk"), start, appIcon);
            CreateShortcut(Path.Combine(menuFolder, "BAMBU STUDIO.lnk"), start, appIcon);
            if (!File.Exists(Path.Combine(desktop, "BAMBU STUDIO.lnk")))
                throw new IOException("Falha ao criar o atalho do Desktop.");
            if (!File.Exists(Path.Combine(menuFolder, "BAMBU STUDIO.lnk")))
                throw new IOException("Falha ao criar o atalho do menu Iniciar.");

            DialogResult open = MessageBox.Show(
                "BAMBU STUDIO instalado com sucesso!\n\n" +
                "Icones criados na Area de Trabalho e menu Iniciar.\n" +
                "Pasta: " + destFull + "\n\n" +
                "Deseja abrir o BAMBU agora?",
                "BAMBU STUDIO - Instalacao concluida",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Information);
            if (open == DialogResult.Yes)
            {
                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = "cmd.exe";
                psi.Arguments = "/c \"\"" + start + "\"\"";
                psi.WorkingDirectory = Path.GetDirectoryName(start);
                psi.UseShellExecute = true;
                Process.Start(psi);
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show("A instalacao nao foi concluida.\n\n" + ex.Message +
                "\n\nFeche BAMBU e Minecraft e tente novamente. O mundo existente nao foi apagado.",
                "BAMBU STUDIO - Erro no instalador",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
        }
    }

    private static void CreateShortcut(string linkPath, string target, string iconFile)
    {
        Type shellType = Type.GetTypeFromProgID("WScript.Shell");
        if (shellType == null) throw new IOException("Windows Script Host indisponivel para criar atalhos.");
        dynamic shell = Activator.CreateInstance(shellType);
        dynamic shortcut = shell.CreateShortcut(linkPath);
        shortcut.TargetPath = target;
        shortcut.WorkingDirectory = Path.GetDirectoryName(target);
        shortcut.IconLocation = iconFile + ",0";
        shortcut.Description = "BAMBU STUDIO 0.5.9 RC10 - Parkour Paradise 3";
        shortcut.Save();
    }
}
'@
 try{
   [IO.File]::WriteAllText($csPath,$installerCode,$utf8)
   $compilerArgs=@(
     '/nologo',
     '/target:winexe',
     '/platform:anycpu',
     '/optimize+',
     ('/out:'+ $installerExe),
     ('/resource:'+ $destZip + ',BambuPayload'),
     '/reference:System.dll',
     '/reference:System.Core.dll',
     '/reference:System.IO.Compression.dll',
     '/reference:System.IO.Compression.FileSystem.dll',
     '/reference:System.Windows.Forms.dll',
     '/reference:Microsoft.CSharp.dll',
     $csPath
   )
   & $csc[0] @compilerArgs
   if($LASTEXITCODE -ne 0 -or -not(Test-Path -LiteralPath $installerExe -PathType Leaf)){
      throw 'O compilador .NET nao conseguiu gerar o instalador EXE. A pasta pronta e ZIP foram preservados.'
   }
   if((Get-Item -LiteralPath $installerExe).Length -le (Get-Item -LiteralPath $destZip).Length){
      throw 'O instalador EXE nao contem o pacote completo: tamanho inesperado.'
   }
   $installerMb=[Math]::Round((Get-Item -LiteralPath $installerExe).Length / 1MB,1)
   Note ('[OK] INSTALADOR EXE GERADO: '+$installerExe) 'Green'
   Note ('[OK] TAMANHO: '+$installerMb+' MB') 'Green'
 } finally {
   Remove-Item -LiteralPath $csPath -Force -ErrorAction SilentlyContinue
 }

 $size=[Math]::Round((Get-Item -LiteralPath $destZip).Length / 1MB,1)
 Note ''
 Note '=================================================================' 'Green'
 Note '[OK] PASTA + ZIP + INSTALADOR V4 COM ATALHOS GERADOS!' 'Green'
 Note ('PASTA PRONTA: '+$staging) 'White'
 Note ('ZIP: '+$destZip) 'White'
 Note ('INSTALADOR: '+$installerExe) 'White'
 Note ('TAMANHO: '+$size+' MB') 'White'
 Note 'O aplicativo original NAO foi modificado pela geracao do ZIP.' 'Green'
 Note 'Pode abrir INICIAR_BAMBU_FINAL.cmd DIRETO DA PASTA PRONTA.' 'Cyan'
 Note 'Abra Instalar_BAMBU_STUDIO_059_PARKOUR_P3_V4_COM_ATALHO.exe para instalar.' 'Cyan'
 Note 'Esta versao cria o icone no Desktop e no menu Iniciar automaticamente.' 'Green'
 Note 'Nao precisa instalar Inno Setup nem executar outro gerador.' 'Cyan'
 Note '=================================================================' 'Green'
} catch {
 Note ''
 Note ('[ERRO] '+$_.Exception.Message) 'Red'
 Note 'O aplicativo original nao foi alterado.' 'Yellow'
 exit 1
} finally {
 # NUNCA apague a pasta Desktop nem o pacote pronto.
}
