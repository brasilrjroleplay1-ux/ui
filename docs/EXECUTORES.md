# Política de suporte

A Conexão Studio 3.5.1 permite **Delta, Wave, Xeno e Solara**. A lista é uma seleção de suporte de nomes conhecidos, sem ranking de segurança nem números de usuários verificados. O projeto não auditou os executáveis desses produtos.

O código verifica o nome informado por `identifyexecutor()` ou `getexecutorname()` antes de inicializar a base visual e novamente a cada `CreateWindow`. Clientes ausentes, desconhecidos ou fora da lista recebem um erro de executor não suportado. O Roblox Studio é liberado como ambiente de desenvolvimento.

A comparação ignora caixa e espaços extras, sem aceitar correspondências apenas por prefixo. Por exemplo, `DELTA` corresponde a Delta; `Delta Clone` e `Delta Runtime` são recusados. A versão deve vir no retorno separado da API de identificação, sem ampliar automaticamente o nome permitido.

`UI.SupportedExecutors` é uma cópia informativa da lista. Mudar essa tabela, criar aliases visuais ou chamar `RegisterExecutorIcon` não altera a política compilada. Para mudar o suporte de uma nova versão, edite a lista revisada em `assets/executors/catalog.json`, reconstrua e execute os testes.

Esta é uma restrição de suporte da biblioteca. O executor controla o ambiente e pode informar um nome falso. Por isso, a checagem não valida a origem, integridade ou segurança do programa instalado.
