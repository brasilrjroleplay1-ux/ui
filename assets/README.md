# Identificação visual de terceiros

`delta.png` é a imagem de identificação obtida de https://deltaexploits.gg/assets/favicon.ico em 29/10/2026, convertida de ICO para PNG na resolução original de 256 × 256, sem redesenho. A marca e a arte pertencem aos respectivos titulares; não são licenciadas como código MPL nem indicam vínculo ou endosso à Conexão Studio.

A distribuição incorpora essa mesma imagem em `Features/BrandAssets.luau`. Nos ambientes com `getcustomasset` ou `getsynasset`, ela é carregada de um arquivo local, sem download de imagens. Em ambientes sem essas APIs, a UI usa um símbolo geométrico Δ junto ao nome Delta. A marca só aparece quando o executor identificado contém Delta; outros clientes mantêm seu próprio nome.

O identificador Roblox é um quadrado inclinado com recorte central construído com GuiObjects; não depende de uma imagem externa. Ambos os nomes identificam os respectivos produtos, sem afiliação.
