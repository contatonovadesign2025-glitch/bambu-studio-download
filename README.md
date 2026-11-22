# BAMBU STUDIO 0.5.9 — distribuição Windows

## Estado verificado em 22/11/2026

**Nome público aprovado:** BAMBU STUDIO 0.5.9 (sem “SEMIFINAL”).

**Base auditada:** arquivo do desenvolvedor `BAMBU_STUDIO_0_5_9_SEMIFINAL_GERADOR_GRATUITO_NSIS (2).zip`, usando instalador NSIS gratuito.

### Auditoria estática concluída

- Arquivo ZIP original foi aberto e a integridade CRC conferida sem erros.
- `APP_BAMBU_0_5_9/` contém **2.810 arquivos**, totalizando **300.908.927 bytes** descompactados.
- **17/17 arquivos críticos** conferidos por SHA-256 contra `MANIFESTO_CRITICOS_SHA256.csv`.
- Identificados os recursos Electron, `Bambu Studio Teste.exe`, `main.cjs`, `preload.cjs`, `cloud-client.cjs`, motor `engine/servidor.cjs`, plugin Minecraft `custom-parkour-tiktok-hud-bambu.jar`, DLLs e ícone.
- A cópia da aplicação foi **preservada sem alteração**. A auditoria estática não demonstra funcionamento das licenças, Minecraft e Windows instalado.

### Gerador NSIS corrigido

Foi preparado na conversa um pacote completo para compilação em Windows: `BAMBU_STUDIO_0_5_9_GERADOR_NSIS_CORRIGIDO.zip`. Ele **não está hospedado neste repositório** e não constitui um instalador final. Preserva os 2.810 arquivos da aplicação e altera apenas os scripts de criação do instalador e documentos de orientação.

O script NSIS agora define:
- `Name "BAMBU STUDIO 0.5.9"`
- `OutFile "SAIDA\\Instalar-BAMBU-STUDIO-0.5.9.exe"`
- Pasta de instalação `%LOCALAPPDATA%\\Programs\\BAMBU Studio 0.5.9`
- Atalhos da Área de Trabalho e menu Iniciar com o nome BAMBU STUDIO 0.5.9.

O instalador antigo `Instalar-BAMBU-STUDIO-0.5.9-SEMIFINAL.exe` **não foi renomeado nem reutilizado**; deve ser recompilado com NSIS no Windows, e testado.

**Atenção:** o arquivo `resources/app/cloud-client.cjs` ainda faz referência ao Worker `bambu-cloud-api-teste.brunoclash1100.workers.dev`. Antes da distribuição comercial, verificar se essa API é a correta para licenças reais. Não alterar licenças, dados ou D1 apenas para corrigir o instalador.

## GitHub Releases

As releases antigas apontam para instaladores de outras versões/produtos e **não devem ser usadas como versão 0.5.9**:

- [BAMBU Cloud Studio 3.0.3](https://github.com/contatonovadesign2025-glitch/bambu-studio-download/releases/tag/v3.0.3-3f159e15e445)
- [BAMBU Studio 2.0](https://github.com/contatonovadesign2025-glitch/bambu-studio-download/releases/tag/v2.0.0)

**Release BAMBU STUDIO 0.5.9: ainda não publicada.** Não anexar o EXE SEMIFINAL existente; depois de compilar e testar o novo `Instalar-BAMBU-STUDIO-0.5.9.exe`, publicá-lo numa release própria (tag sugerida `v0.5.9`) com hash SHA-256.

## Próximos testes antes da publicação ao cliente

1. Compilar o NSIS com `GERAR_INSTALADOR_BAMBU.cmd` no Windows.
2. Instalar em outro Windows 11 x64 limpo e conferir atalhos, ícone, abertura do programa e desinstalação.
3. Validar licenciamento real, motor, Paradise 3 e integração com Minecraft/TikTok.
4. Conferir que nenhum componente depende de caminhos locais do desenvolvedor; calcular hash do EXE.
5. Publicar **o EXE validado**, como ativo de nova GitHub Release do produto 0.5.9.
6. Atualizar o link de download no Cloudflare **somente depois** de validar a release; preservar Worker, licenças, banco D1 e dados existentes.

## Arquivos históricos mantidos no repositório

- [Correção V6.1 do Paradise 3](BAMBU_059_PARKOUR_PARADISE_3_V6_1_CORRIGIDO.cmd): histórico de recuperação, não usar automaticamente na base NSIS.
- [Notas anteriores da RC10/Paradise 3](RELEASE_NOTES_BAMBU_059_RC10_PARADISE_3.md).
- [Lembrança da conversa](LEMBRANCA_CONVERSA_BAMBU_STUDIO_PARADISE_3_2026-11-22.txt).

Não há publicação automática do EXE no Cloudflare neste estágio. O código-fonte completo não deve ser publicado num repositório público sem auditoria de credenciais e direitos de distribuição.
