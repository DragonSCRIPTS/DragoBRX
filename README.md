BRX novo modelo AI
RobloxAI - DragoBRX
Bem-vindo ao RobloxAI, uma ferramenta de inteligência artificial que fornece scripts e soluções para o Roblox Studio com base em perguntas dos usuários. Este projeto é open source e pode ser executado em ambientes como o Google Colab ou localmente com Node.js. Com esta versão, você pode digitar sua pergunta diretamente no prompt interativo, sem precisar editar o código.
Pré-requisitos
Para usar o RobloxAI, você precisa dos seguintes itens:

Node.js (versão 14 ou superior) instalado localmente, se for executar fora do Google Colab.
Módulo node-fetch: Necessário para requisições HTTP. Será instalado automaticamente nos exemplos abaixo.
Acesso à internet: O script baixa arquivos do repositório público https://github.com/DragonSCRIPTS/DragoBRX.

Nenhuma chave ou autenticação é necessária, pois o projeto é totalmente open source.
Como Usar no Google Colab
O Google Colab é uma plataforma online gratuita que permite executar código JavaScript/Node.js. Siga os passos abaixo para usar o RobloxAI no Colab:

Abra o Google Colab:

Acesse Google Colab e crie um novo notebook.


Adicione uma célula de código:

Cole o seguinte código em uma célula e execute-a:
%%bash
npm install node-fetch
curl -o robloxAI.js https://raw.githubusercontent.com/DragonSCRIPTS/DragoBRX/main/robloxAI.js
node robloxAI.js




Digite sua pergunta:

Após executar a célula, uma mensagem aparecerá na saída: Digite sua pergunta sobre Roblox Studio (ou "sair" para encerrar):.
Clique na saída da célula e digite sua pergunta (exemplo: Quero um sistema de loja GUI para jogador).
Pressione Enter, e a resposta será exibida.
Digite outra pergunta ou "sair" para encerrar.



Exemplo de Uso:

Execute o código acima no Colab.
Na saída, digite: Quero um script de teleporte para jogadores.
A IA responderá com o código ou mensagem relevante.
Digite outra pergunta, como Como criar um NPC que dá missões?, ou "sair" para parar.

Nota no Colab:

No Google Colab, o prompt interativo pode ser um pouco limitado devido à interface. Você precisa clicar na saída da célula para digitar. Para uma experiência mais fluida, considere usar localmente (veja abaixo).

Como Usar Localmente (com Node.js)
Para uma experiência mais interativa, execute o RobloxAI em seu computador com Node.js:

Instale o Node.js:

Baixe e instale o Node.js em nodejs.org (recomenda-se a versão LTS).
Verifique a instalação com:node --version
npm --version




Crie uma pasta para o projeto:

Crie uma pasta (exemplo: roblox-ai) e navegue até ela no terminal:mkdir roblox-ai
cd roblox-ai




Baixe o script robloxAI.js:

Use o comando abaixo para baixar o script:curl -o robloxAI.js https://raw.githubusercontent.com/DragonSCRIPTS/DragoBRX/main/robloxAI.js




Instale a dependência node-fetch:

Na pasta do projeto, instale o módulo node-fetch:npm install node-fetch




Execute o script:

Inicie o script com:node robloxAI.js


Um prompt aparecerá: Digite sua pergunta sobre Roblox Studio (ou "sair" para encerrar):.
Digite sua pergunta (exemplo: Quero um sistema de loja GUI para jogador) e pressione Enter.
A resposta será exibida, e você pode digitar outra pergunta ou "sair" para encerrar.



Exemplo Completo (Terminal):
mkdir roblox-ai
cd roblox-ai
curl -o robloxAI.js https://raw.githubusercontent.com/DragonSCRIPTS/DragoBRX/main/robloxAI.js
npm install node-fetch
node robloxAI.js


No prompt, digite: Quero um script de teleporte para jogadores.
Após a resposta, digite outra pergunta ou "sair".

Estrutura do Repositório
Os seguintes arquivos são necessários para o funcionamento do RobloxAI e estão hospedados no repositório https://github.com/DragonSCRIPTS/DragoBRX:

robloxAI.js: O script principal que processa as perguntas e retorna respostas.
file_list.json: Lista os arquivos JSON da pasta respostas (exemplo: ["respostas/resposta1.json", "respostas/resposta2.json"]).
perguntas_roblox_studio.json: Contém perguntas pré-definidas para o Roblox Studio.
Pasta respostas/: Contém arquivos JSON com os dados de treinamento (scripts e respostas).

Certifique-se de que o repositório é público para que os arquivos sejam acessíveis via URLs raw.
Dicas para Formular Perguntas

Seja específico: Perguntas claras, como "Quero um sistema de loja GUI para jogador", produzem melhores resultados.
Use termos do Roblox: Inclua palavras-chave como NPC, GUI, script, teleport, animation, etc.
Exemplos de perguntas:
"Quero um script para um NPC que dá missões."
"Como criar uma interface de inventário?"
"Quero um sistema de checkpoint para salvar progresso."



Solução de Problemas

Erro: "Cannot find module 'node-fetch'":
Execute npm install node-fetch antes de rodar o script.


Erro: "Nenhum código encontrado":
Reformule a pergunta para ser mais específica ou use termos do Roblox Studio.
Verifique se file_list.json e perguntas_roblox_studio.json estão no repositório.


Prompt não aparece no Colab:
Clique na saída da célula para ativar o campo de entrada.
Se o Colab for instável, use o script localmente com Node.js.


Erro ao baixar o script:
Confirme que o repositório é público e a URL https://raw.githubusercontent.com/DragonSCRIPTS/DragoBRX/main/robloxAI.js está acessível.


Execução lenta:
O script baixa arquivos do GitHub. Certifique-se de que sua conexão está estável.



Sobre o Projeto
O RobloxAI é uma ferramenta open source que ajuda desenvolvedores do Roblox Studio a obter scripts e soluções. Ele usa dados de treinamento hospedados no repositório público DragonSCRIPTS/DragoBRX e não requer chaves, permitindo uso ilimitado. Com o prompt interativo, você pode digitar perguntas diretamente, tornando o uso mais prático.
Se tiver dúvidas ou sugestões, abra uma issue no repositório ou entre em contato com o desenvolvedor.
Desenvolvido por DragonSCRIPTSÚltima atualização: Junho de 2025
