# Agenda 2SAY

Interface de uma página para planejar o conteúdo da 2SAY: o guia editorial fixo à esquerda e a
semana sendo montada ao lado, com banco de ideias e histórico.

Este repositório contém **apenas a interface**. Nenhum conteúdo, dado ou métrica mora aqui.
Tudo é carregado em tempo de execução de um `sistema.json` guardado num repositório privado,
acessado com um token pessoal que fica apenas no navegador de quem usa.

Sem essa conexão, a página abre vazia.

## Origem

Interface derivada de [`andreymarcon/mente-desobediente`](https://github.com/andreymarcon/mente-desobediente),
o sistema de planejamento do Andrey Marcon. Aqui ela carrega a identidade visual da 2SAY
(azul `#003349`, limão `#BFE53A`, Bricolage Grotesque + Schibsted Grotesk) e usa chaves de
`localStorage` próprias, para as duas páginas conviverem no mesmo navegador sem se misturar.

## O `guia` vem do Content Guide

O conteúdo do painel da esquerda é a versão em JSON de
`2SAY/Estratégia/2SAY - Guia de Conteúdo.md` — 3 níveis de funil, 9 quadros, 4 intenções,
a régua de métricas e os padrões fixos de stories.

**O Content Guide manda.** Se o guia mudar, o `sistema.json` é que se atualiza — nunca o contrário.

## Conectar

Clique na pílula de status no topo e informe:

- **Repositório**: `alandeotti/2say-producao`
- **Arquivo**: `sistema.json`
- **Token**: fine-grained token do GitHub com permissão de *Contents* (leitura e escrita)
  restrita a esse único repositório

O token é gravado no `localStorage` e usado só para chamar a API do GitHub. Alterações salvam
sozinhas, com um atraso de 1,4s para agrupar edições seguidas.

## Rodar local

```
python3 -m http.server 8765
```

Arquivo único, sem build e sem dependências. As fontes vêm do Google Fonts.
