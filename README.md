# BAMBU STUDIO 0.5.9 — distribuição para Windows

## Estado atual (22/11/2026)

**NOVA BASE FINAL DO DESENVOLVEDOR:** `BAMBU_STUDIO_0_5_9_SEMIFINAL_GERADOR_GRATUITO_NSIS (2).zip` (arquivo fornecido na conversa).

**Nome comercial solicitado:** `BAMBU STUDIO 0.5.9`, sem a palavra **SEMIFINAL** na interface, no instalador, nos caminhos de saída e na release.

**IMPORTANTE: o conteúdo interno desse ZIP ainda NÃO foi auditado ou compilado aqui.** NÃO presumir que o programa, dependências e gerador NSIS estejam corretos apenas pelo nome do arquivo. A publicação do instalador final está pendente de verificação dos arquivos reais e de testes em máquina limpa.

## Releases atualmente existentes

| Release | Instalador | Pertence à nova base 0.5.9 NSIS? |
| --- | --- | --- |
| [BAMBU Cloud Studio 3.0.3](https://github.com/contatonovadesign2025-glitch/bambu-studio-download/releases/tag/v3.0.3-3f159e15e445) | `Instalar-BAMBU-Cloud-3.0.3.exe` | **NÃO** |
| [BAMBU Studio 2.0](https://github.com/contatonovadesign2025-glitch/bambu-studio-download/releases/tag/v2.0.0) | `Instalar-BAMBU-2.0.0.exe` | **NÃO** |

**Ainda não há uma release publicada do BAMBU STUDIO 0.5.9 gerado pelo projeto NSIS recebido.** O arquivo correto deverá ser anexado em uma nova release, somente depois dos testes. Não reutilizar a release Cloud Studio para o produto 0.5.9.

## Fluxo correto para clientes

1. Conferir o ZIP NSIS recebido: programa principal, `resources`, Electron, módulo do motor, mapa/servidor e dependências exigidas, gerador NSIS, caminhos relativos, atalhos, desinstalador e arquivos de licença **sem incluir segredos**.
2. Remover `SEMIFINAL` do nome do aplicativo, do instalador, da saída e da identificação exibida na instalação; manter a versão **0.5.9**.
3. Gerar **um instalador EXE completo** e instalar num Windows limpo, sem depender de outras pastas do computador do desenvolvedor.
4. Testar abrir pelo atalho da Área de Trabalho e menu Iniciar, executar servidor/mapa e verificar integração, dados do usuário e desinstalação.
5. Calcular tamanho e SHA-256 do EXE final.
6. Criar nova GitHub Release **BAMBU STUDIO 0.5.9** (tag sugerida `v0.5.9`) com o instalador EXE validado como asset. O executável distribuível fica nos arquivos da Release, não misturado a scripts experimentais na branch `main`.
7. Só então alterar links públicos e o download no Cloudflare para essa release correta. Nunca apontar o site para instalador que não foi testado.

## Artefatos técnicos mantidos temporariamente

- [Correção validada do motor Paradise 3 (V6.1)](BAMBU_059_PARKOUR_PARADISE_3_V6_1_CORRIGIDO.cmd): histórico de recuperação; não executar no novo projeto NSIS sem verificar compatibilidade.
- [Notas técnicas da RC10/Paradise 3](RELEASE_NOTES_BAMBU_059_RC10_PARADISE_3.md): histórico e testes anteriores; não equivale à release final NSIS.
- [Lembrança/continuidade](LEMBRANCA_CONVERSA_BAMBU_STUDIO_PARADISE_3_2026-11-22.txt): dados de correções já realizadas.

Os geradores antigos substituídos foram removidos da branch principal e permanecem recuperáveis pelo histórico Git. **Não publicar V3/V4 como instaladores finais**: o novo ZIP NSIS é a referência atual.

## Cloudflare

**Deploy ainda não realizado.** O repositório não contém um mecanismo de distribuição/atualização automática pronto e não há um canal Cloudflare de escrita conectado nesta conversa. Atualizar o banco D1, as licenças, as credenciais ou os dados do usuário **não faz parte** da simples atualização do instalador.

Depois que houver URL pública e hash do EXE validado, verificar Worker/site e atualizar somente a configuração necessária de download, sem alterar licenças e registros existentes.
