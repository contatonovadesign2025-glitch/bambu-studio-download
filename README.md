# BAMBU STUDIO — Downloads, versões e continuidade

Este repositório contém **scripts de manutenção do BAMBU STUDIO** e também mantém releases históricas de aplicativos BAMBU. **Não misture instaladores de produtos/versões diferentes**.

## Releases publicadas no GitHub

| Release | Produto | Instalador anexado | Estado |
| --- | --- | --- | --- |
| [v3.0.3-3f159e15e445](../../releases/tag/v3.0.3-3f159e15e445) | **BAMBU Cloud Studio 3.0.3** | `Instalar-BAMBU-Cloud-3.0.3.exe` | Publicada anteriormente; **não é o instalador da RC10** |
| [v2.0.0](../../releases/tag/v2.0.0) | **BAMBU Studio 2.0** | `Instalar-BAMBU-2.0.0.exe` | Publicada anteriormente; **não é o instalador da RC10** |
| [0.5.9 RC10 — Paradise 3](RELEASE_NOTES_BAMBU_059_RC10_PARADISE_3.md) | **BAMBU STUDIO 0.5.9 RC10** | **Não anexado** | **Candidata; aguardando EXE V4 validado** |

**Importante:** o item RC10 na tabela é apenas documentação de preparação, **não é uma release do GitHub publicada**. Não anunciar aos clientes que já existe um instalador RC10 neste repositório.

## Arquivos mantidos após a limpeza

- **[BAMBU_059_PARKOUR_PARADISE_3_V6_1_CORRIGIDO.cmd](BAMBU_059_PARKOUR_PARADISE_3_V6_1_CORRIGIDO.cmd)** — correção de motor/plug-in **testada funcionando** no computador do desenvolvedor.
- **[BAMBU_STUDIO_059_GERAR_INSTALADOR_COM_ATALHO_V4.cmd](BAMBU_STUDIO_059_GERAR_INSTALADOR_COM_ATALHO_V4.cmd)** — gerador **mais recente**, escrito para criar atalho na Área de Trabalho visível e no menu Iniciar. **Ainda não aprovado por teste real de instalação**.
- **[RELEASE_NOTES_BAMBU_059_RC10_PARADISE_3.md](RELEASE_NOTES_BAMBU_059_RC10_PARADISE_3.md)** — notas da próxima release e checklist de qualidade.
- **[LEMBRANCA_CONVERSA_BAMBU_STUDIO_PARADISE_3_2026-11-22.txt](LEMBRANCA_CONVERSA_BAMBU_STUDIO_PARADISE_3_2026-11-22.txt)** — histórico técnico do projeto.
- **README.md** — este índice.

## BAMBU STUDIO 0.5.9 RC10 / Paradise 3

Base funcional no Windows do desenvolvedor: `Downloads\BAMBU_STUDIO_059_RC10_GULIVE_MOTOR_CORRIGIDO`.

O plugin correto do mapa **Parkour Paradise 3** tem SHA-256:

`201656BC3CB0462D96BB6E1FDCAEA62417D704168CD3B051CF8C0F3CF1A1F8FF`

**Funcionalidade confirmada:** carregamento do plugin, HUD e `/tparkour configurar` com as três perguntas SIM/NÃO; a configuração foi salva. **Pendente:** testes completos de checkpoints, 100 níveis e eventos TikTok.

O gerador V3 produziu um EXE local de cerca de 293,9 MB, mas ele **não criou atalhos**. A V4 corrige o código desses atalhos, porém **não temos o arquivo V4 compilado/testado no GitHub**. O EXE esperado é:

`Instalar_BAMBU_STUDIO_059_PARKOUR_P3_V4_COM_ATALHO.exe`

**Não publique o V3 em lugar da V4 e não vincule o script CMD como se fosse instalador para clientes.**

## Publicação segura da próxima versão

1. Gerar a V4 a partir da base funcional e testar a instalação em outro perfil/computador.
2. Conferir criação dos atalhos, início do BAMBU, servidor e integração do Paradise 3.
3. Calcular SHA-256 do EXE final e registrar na release.
4. Publicar uma **nova release própria** da 0.5.9 RC10 (`v0.5.9-rc10-p3` é uma sugestão), anexando o EXE validado.
5. Manter os instaladores antigos do Cloud Studio 3.0.3 e BAMBU Studio 2.0 em suas releases originais.
6. Atualizar downloads no site e implementar eventual mecanismo de atualização automática Cloudflare separadamente.

## Cloudflare / licenças

Os scripts deste repositório **não fazem deploy no Cloudflare** e não atualizam automaticamente aplicativos já instalados. Qualquer migração de Worker, D1, licenças ou atualizador remoto exige desenvolvimento e validação próprios. **Nenhuma alteração de licenças, banco D1 ou Cloudflare foi feita nesta atualização de documentação.**

## Histórico

Em 22/11/2026 foram removidos da branch `main` 12 scripts experimentais, duplicados ou substituídos. Eles permanecem disponíveis no histórico Git. Essa limpeza não modificou arquivos instalados no computador.
