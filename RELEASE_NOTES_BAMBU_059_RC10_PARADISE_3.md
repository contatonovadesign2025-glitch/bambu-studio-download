# Histórico técnico da 0.5.9 RC10 / Paradise 3

> **Documento histórico da etapa RC10. NÃO é a release final do produto.**

## Nova base de publicação (22/11/2026)

O usuário forneceu o arquivo `BAMBU_STUDIO_0_5_9_SEMIFINAL_GERADOR_GRATUITO_NSIS (2).zip` como a base final de trabalho, com **gerador NSIS**. O nome público deverá ser **BAMBU STUDIO 0.5.9**, sem **SEMIFINAL**.

**Não foi possível ainda auditar o conteúdo interno do ZIP nem validar compilação/instalação.** Portanto, nenhum arquivo EXE da nova base foi publicado em Releases ou no Cloudflare.

Nome sugerido para uma nova release somente após validação: `BAMBU STUDIO 0.5.9`, tag `v0.5.9`.

O gerador V4 antigo, que criava um EXE distinto, foi removido da branch principal por ter sido substituído pela base NSIS. Recuperável pelo histórico Git.

## Correções confirmadas anteriormente

- A correção do motor `BAMBU_059_PARKOUR_PARADISE_3_V6_1_CORRIGIDO.cmd` funcionou no Windows do desenvolvedor.
- O Minecraft mostrou as três perguntas SIM/NÃO em `/tparkour configurar` e `Configuração salva!`.
- Escudo ligado, teto ligado e nível negativo desligado no teste mostrado; HUD presente.
- SHA-256 do JAR testado de Paradise 3: `201656BC3CB0462D96BB6E1FDCAEA62417D704168CD3B051CF8C0F3CF1A1F8FF`.
- **Não presumir** que o ZIP NSIS mais recente contenha os mesmos arquivos sem conferir seu conteúdo.

## Checklist para o novo instalador NSIS (ainda pendente)

- [ ] Inventariar o ZIP NSIS recebido, especialmente `resources`, motor, scripts, plugin, mapa, binários e dependências.
- [ ] Conferir a configuração NSIS, caminhos de origem e saída, atalhos, desinstalador e inclusão integral do executável e recursos.
- [ ] Remover `SEMIFINAL` do nome de produto, nome do EXE e rotulagem do gerador/saída, preservando a versão `0.5.9`.
- [ ] Gerar o instalador NSIS e testá-lo numa máquina Windows limpa, sem arquivos já existentes do desenvolvedor.
- [ ] Verificar aplicativo, mapa, servidor, RCON, eventos e licenciamento sem alterar o banco D1.
- [ ] Calcular SHA-256 do EXE efetivamente distribuído.
- [ ] Publicar esse EXE em uma **nova release 0.5.9** no GitHub e conferir seu download real.
- [ ] Somente depois atualizar o link de download/manifesto no Cloudflare.

## Releases anteriores — não confundir

- `v3.0.3-3f159e15e445` = BAMBU Cloud Studio 3.0.3 (`Instalar-BAMBU-Cloud-3.0.3.exe`).
- `v2.0.0` = BAMBU Studio 2.0 (`Instalar-BAMBU-2.0.0.exe`).

Os executáveis dessas releases pertencem a outros pacotes e **não devem ser apresentados como instalador final do BAMBU STUDIO 0.5.9**.

**Estado:** notas e índice GitHub atualizados. Binário final NSIS, publicação em Releases e deploy Cloudflare ainda pendentes.
