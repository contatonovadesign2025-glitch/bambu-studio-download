# BAMBU STUDIO 0.5.9 RC10 — Parkour Paradise 3

**Estado: preparação de release. NÃO publicada nem aprovada para distribuição.**

> Não confundir com a release já publicada BAMBU Cloud Studio 3.0.3. Não substituir seu instalador.

## O que foi confirmado no aplicativo funcional

- Motor do BAMBU STUDIO 0.5.9 RC10 preservado com o plugin GULIVE do Parkour Paradise 3.
- Correção que funcionou: [V6.1 — Paradise 3](BAMBU_059_PARKOUR_PARADISE_3_V6_1_CORRIGIDO.cmd).
- O Minecraft apresentou as três perguntas SIM/NÃO em `/tparkour configurar` e exibiu **Configuração salva!**.
- Configuração observada: **Escudo LIGADO**, **Teto LIGADO**, **Nível negativo DESLIGADO**.
- HUD de tempo e nível exibido nas capturas finais.
- SHA-256 do JAR Paradise 3: `201656BC3CB0462D96BB6E1FDCAEA62417D704168CD3B051CF8C0F3CF1A1F8FF`.

## Instalador Windows candidato à distribuição

Gerador: [V4 com atalhos](BAMBU_STUDIO_059_GERAR_INSTALADOR_COM_ATALHO_V4.cmd).

Nome de saída esperado no Windows: `Instalar_BAMBU_STUDIO_059_PARKOUR_P3_V4_COM_ATALHO.exe`.

A V4 foi escrita para criar atalhos na Área de Trabalho visível (inclusive OneDrive) e no menu Iniciar.
**Não existe confirmação de instalação bem-sucedida da V4.** O gerador V3 foi executado e produziu um EXE de aproximadamente 293,9 MB, mas o instalador V3 não criava atalhos. NÃO distribuir V3 como versão final.

**O EXE V4 não está anexado ao repositório nem a uma release** e seu SHA-256 precisa ser calculado a partir do próprio arquivo real.

## Checklist para publicação

- [ ] Gerar a V4 no computador com o motor funcional.
- [ ] Conferir nome, tamanho e SHA-256 do instalador EXE.
- [ ] Testar em outro computador/perfil sem o GULIVE instalado.
- [ ] Confirmar ícones na Área de Trabalho visível e no menu Iniciar.
- [ ] Abrir o app pelo ícone e usar o botão **Preparar e iniciar servidor**.
- [ ] Confirmar Paradise 3, `/tparkour configurar`, persistência e inicialização.
- [ ] Testar checkpoints, progressão, eventos TikTok, RCON e dados do usuário.
- [ ] Validar reinstalação e eventuais licenças, sem modificar o banco Cloudflare D1.
- [ ] Publicar uma **release separada** e anexar o EXE validado, não só o CMD.
- [ ] Atualizar o link público e o Cloudflare somente após validação.

## Identificação sugerida da release FUTURA (não publicada)

- Tag: `v0.5.9-rc10-p3`.
- Título: `BAMBU STUDIO 0.5.9 RC10 — Parkour Paradise 3`.
- Asset previsto: `Instalar_BAMBU_STUDIO_059_PARKOUR_P3_V4_COM_ATALHO.exe` (somente se validado).
- Publicar SHA-256 do EXE real e manter os releases já publicados `v3.0.3-3f159e15e445` (BAMBU Cloud Studio) e `v2.0.0` (BAMBU Studio 2.0).

## Cloudflare e atualização

Os geradores locais não fazem deploy e não implementam atualização automática dos clientes.
Manifesto remoto, download versionado e integração do aplicativo/Cloudflare ainda são pendências.
Nenhum deploy, alteração de licenças/D1 ou substituição de asset de release foi realizado ao preparar esta documentação.
