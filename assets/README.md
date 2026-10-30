# Identificação visual de terceiros

O catálogo de nomes usa uma fotografia dos metadados públicos de https://weao.xyz/api/status/exploits consultada em 30/10/2026. Não há consulta a esse serviço na execução da library. O catálogo identifica o nome do cliente; não atesta compatibilidade, disponibilidade, qualidade ou segurança de um executor.

As 21 imagens foram obtidas dos ícones dos sites associados aos produtos listados abaixo. Elas foram convertidas para PNG e ajustadas para uma tela de 128 × 128 com proporção preservada e margens transparentes removidas. `delta.png` preserva a imagem original de 256 × 256 obtida em 29/10/2026. As marcas e artes pertencem aos respectivos titulares; não são licenciadas como código MPL e não indicam afiliação ou endosso à Conexão Studio.

`tools/brand_assets.py` incorpora esses mesmos arquivos em `Features/BrandAssets.luau`, e gera `ExecutorCatalog.luau`. O cliente carrega as imagens localmente com `getcustomasset`/`getsynasset`, sem baixar logos. Sem uma imagem ou API de assets disponível, a UI usa um símbolo geométrico ou inicial junto ao nome. Roblox e Studio usam identificadores vetoriais locais.

| Nome | Imagem incluída | Fonte |
| --- | --- | --- |
| Potassium | Sim | https://www.potassium.pro/favicon.ico |
| Matcha | Inicial | https://matcha-latte.win/ |
| Xeno | Sim | https://www.xeno.now/images/xeno.png |
| Photon | Sim | https://photons.solutions/logo.png |
| DX9WARE V2 | Sim | https://cultofintellect.com/favicon.png |
| SirHurt | Inicial | https://sirhurt.net |
| Seliware | Sim | https://seliware.com/apple-touch-icon.png |
| Volt | Inicial | https://voltbz.net/ |
| Velocity | Sim | https://realvelocity.xyz/favicon.ico |
| Solara | Sim | https://getsolara.dev/assets/img/icon-192.png |
| Matrix Hub | Sim | https://matrixhubs.shop/image/logo.png |
| Wave | Sim | https://getwave.gg/wave/Logo5.png |
| Delta | Sim | https://deltaexploits.gg/assets/favicon.ico |
| Volcano | Inicial | https://volcano.wtf |
| Serotonin | Sim | https://www.serotonin.win/favicon.ico?favicon.6af32af9.ico |
| Melatonin | Inicial | https://melatonin.win/ |
| Synapse Z | Sim | https://z.synapse.do/favicon.ico |
| MacSploit | Sim | https://www.raptor.fun/favicon.ico |
| Vega X | Inicial | https://www.vegax.gg |
| Opiumware | Inicial | https://use.opiumware.today/ |
| Lynx | Sim | https://getlynx.gg/apple-icon.png?apple-icon.2yw97huui0ivu.png |
| Madium | Sim | https://getmadium.net/favicon.png |
| Lumen | Inicial | https://getlumen.net/ |
| Real | Sim | https://realest.gg/apple-touch-icon.png |
| Axis | Sim | https://useaxis.cc/public/axisico.ico |
| Isaeva | Sim | https://isaeva.xyz/isaeva-logo-white.png |
| Madius | Sim | https://madius.dev/assets/madius-logo.png |
| Lucid | Sim | https://getlucid.gg/assets/images/brand/favicon.png |
| Codex | Sim | https://codex.lol/apple-touch-icon.png |

O script pode registrar outras imagens com `UI:RegisterExecutorIcon(nome, assetIdOuUriLocal, aliases)` antes de criar a janela. O nome completo do executor continua visível quando ele não faz parte do catálogo.
