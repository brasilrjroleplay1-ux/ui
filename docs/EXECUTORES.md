# Política de suporte

A Conexão Studio 3.7.3 permite **Delta, Wave, Xeno e Solara**. A lista é uma seleção de suporte de nomes conhecidos, sem ranking de segurança nem números de usuários verificados. O projeto não auditou os executáveis desses produtos.

O código consulta as funções `identifyexecutor()` e `getexecutorname()` disponíveis nos ambientes acessíveis antes de inicializar a base visual e novamente a cada `CreateWindow`. Todas as respostas precisam apontar para o mesmo nome permitido. Uma API disponível com erro ou resposta inválida, nomes conflitantes e clientes fora da lista provocam recusa. A ausência de uma das APIs é aceita quando a outra fornece identificação válida. Funções idênticas encontradas em mais de um ambiente são chamadas apenas uma vez.

O Roblox Studio é liberado para desenvolvimento quando não há APIs de executor presentes. Se um executor informar seu nome, ele passa pelas mesmas regras; a exceção de desenvolvimento não libera um nome desconhecido.

A comparação ignora caixa e espaços comuns extras, sem aceitar correspondências apenas por prefixo. Nomes com caracteres de controle ou mais de 64 bytes são recusados. Por exemplo, `DELTA` corresponde a Delta; `Delta Clone` e `Delta Runtime` são recusados. A versão deve vir no retorno separado da API de identificação, sem ampliar automaticamente o nome permitido; texto de versão inválido não é exibido.

`UI.SupportedExecutors` é uma cópia informativa da lista. Mudar essa tabela, criar aliases visuais ou chamar `RegisterExecutorIcon` não altera a política compilada. O catálogo, as regras e os módulos de admissão usam tabelas imutáveis para evitar mudanças acidentais por scripts consumidores. Para mudar o suporte de uma nova versão, edite a lista revisada em `assets/executors/catalog.json`, reconstrua e execute os testes.

Esta é uma restrição de suporte da biblioteca. O executor controla o ambiente e pode informar um nome falso. Por isso, a checagem não valida a origem, integridade ou segurança do programa instalado.

Veja também [proteções e limites de segurança](SEGURANCA.md).
