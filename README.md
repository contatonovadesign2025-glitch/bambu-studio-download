# BAMBU STUDIO — arquivos essenciais

Repositório de scripts e documentação do **BAMBU STUDIO 0.5.9 RC10 — Parkour Paradise 3**.

## Arquivos mantidos

- **[BAMBU_059_PARKOUR_PARADISE_3_V6_1_CORRIGIDO.cmd](BAMBU_059_PARKOUR_PARADISE_3_V6_1_CORRIGIDO.cmd)** — correção **confirmada funcionando** no Windows do desenvolvedor: plugin correto do Paradise 3, configuração ESCUDO/TETO/NEGATIVO, HUD e inicialização.
- **[BAMBU_STUDIO_059_GERAR_INSTALADOR_COM_ATALHO_V4.cmd](BAMBU_STUDIO_059_GERAR_INSTALADOR_COM_ATALHO_V4.cmd)** — gerador de pacote e instalador **mais recente, mas ainda NÃO validado em instalação real**. Foi escrito para criar atalhos na Área de Trabalho e no menu Iniciar.
- **[LEMBRANCA_CONVERSA_BAMBU_STUDIO_PARADISE_3_2026-11-22.txt](LEMBRANCA_CONVERSA_BAMBU_STUDIO_PARADISE_3_2026-11-22.txt)** — histórico técnico, caminhos, hashes, testes e pendências.

## Estado atual

- O plugin **Paradise 3** foi verificado pelo SHA-256: `201656BC3CB0462D96BB6E1FDCAEA62417D704168CD3B051CF8C0F3CF1A1F8FF`.
- O V6.1 foi testado no BAMBU com a configuração SIM/NÃO em Minecraft.
- **O gerador V4 ainda precisa de teste de compilação e instalação**. Não enviar a clientes sem validar.
- **Não há publicação automática via Cloudflare neste repositório**; criar um instalador local não atualiza o Cloudflare nem computadores dos clientes.
- O aplicativo completo em ZIP e os arquivos de produção não estão hospedados neste repositório; os scripts dependem da pasta funcional local.

## Limpeza

Em 22/11/2026, foram removidos da branch `main` os scripts experimentais, versões substituídas e duplicatas. **Eles permanecem recuperáveis pelo histórico Git**, sem alterar o motor funcional ou os arquivos instalados nos PCs.

**Atenção:** não alterar o banco D1, licenças, mundos existentes nem o motor já testado sem backup e validação.
