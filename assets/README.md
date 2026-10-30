# Identificação visual de terceiros

O catálogo de suporte inclui somente Delta, Wave, Xeno e Solara. A seleção de nomes conhecidos não é uma auditoria nem um ranking de segurança. Veja a [política de suporte](../docs/EXECUTORES.md). Não há consulta a serviços externos para decidir permissões na execução.

As quatro imagens pertencem aos respectivos titulares e foram obtidas dos ícones dos sites associados aos produtos abaixo. Wave, Xeno e Solara foram convertidas para PNG de 128 × 128 com proporção preservada e margens transparentes removidas. `delta.png` mantém a imagem de 256 × 256 obtida em 29/10/2026. Essas artes não são licenciadas como código MPL e não indicam afiliação ou endosso à Conexão Studio.

`tools/brand_assets.py` incorpora os arquivos em `Features/BrandAssets.luau` e gera `ExecutorCatalog.luau`. O cliente carrega as imagens localmente com `getcustomasset`/`getsynasset`, sem baixar logos. Sem uma API de assets disponível, o executor permitido usa um símbolo geométrico ou inicial junto ao nome. Roblox e Studio usam identificadores vetoriais locais.

| Nome permitido | Fonte da imagem |
| --- | --- |
| Delta | https://deltaexploits.gg/assets/favicon.ico |
| Wave | https://getwave.gg/wave/Logo5.png |
| Xeno | https://www.xeno.now/images/xeno.png |
| Solara | https://getsolara.dev/assets/img/icon-192.png |

`UI:RegisterExecutorIcon` personaliza a imagem de um executor permitido; não concede suporte a outro nome nem comprova a identidade do programa.
