# Only One — Design

Data: 2026-10-30 · Game jam de um dia, tema **"Only One"**.

## Intenção

Um jogo de memória e atenção. A tela fica preta; quando o jogador clica, o cenário
acende por um instante mostrando vários objetos iguais e **apenas um** ligeiramente
diferente. A luz apaga, o cronômetro começa, e o jogador precisa clicar no escuro
exatamente onde estava o objeto único. Ganha quem fizer o menor tempo.

A competição é entre amigos, **na confiança**: cada um joga no próprio computador o
mesmo tabuleiro (identificado por um ID) e eles comparam os tempos. Sem servidor,
sem cadastro, sem banco de dados online.

## Objetivos

- Uma rodada curta, tensa e fácil de entender sem tutorial.
- Tabuleiros reprodutíveis: o mesmo ID gera exatamente o mesmo tabuleiro em qualquer
  máquina (mesmos objetos, mesmas posições, mesmo item único, mesma dificuldade).
- Dificuldade ajustável por slider.
- Power-ups que ajudam, mas custam tempo — escolhas com trade-off.
- Rodar no navegador (export Web já configurado no projeto) e no editor.

## Não-objetivos

- Multiplayer em rede, contas, ranking online.
- Anti-trapaça (a comparação é na confiança).
- Arte desenhada à mão / assets externos.

## Anti-objetivos (seria fracasso mesmo funcionando)

- O objeto diferente ser **impossível de perceber** quando aceso. Ele deve ser sempre
  identificável olhando com calma; o desafio é achar a tempo e lembrar a posição.
- Dois jogadores com o mesmo ID verem tabuleiros diferentes.
- Clicar aleatoriamente pela tela ser uma estratégia vencedora.

## Constraints

- Godot 4.7, GDScript, renderer Compatibility, viewport 960×540 (`canvas_items` stretch).
- Já existe `res://scenes/main.tscn` (contador "Hello, world" de exemplo) — será
  substituída pelo jogo.
- Export Web (WebGL 2, sem threads) precisa continuar funcionando: `./scripts/export-web`.
- Persistência local em `user://` (no Web vira IndexedDB). Nada de SQLite.

## Layout da tela (decidido pelo usuário)

- **Coluna esquerda:** botão **Reiniciar**, **slider de dificuldade**, e (minha
  chamada) campo do **ID do tabuleiro** + botão **Novo tabuleiro** + recorde local.
- **Centro:** a área de jogo (tela preta / cenário).
- **Coluna direita:** botões de **power-ups**.
- Cronômetro visível (posição a critério do builder, ex.: topo do centro).

## Fluxo da rodada

1. Área central preta, com convite "clique para acender".
2. Clique → cenário acende com N objetos em posições aleatórias (sem sobreposição)
   e um objeto único. Fica aceso pelo tempo da dificuldade.
3. Apaga. **Cronômetro começa ao apagar.**
4. Jogador clica no escuro. Clique errado = **+1 s** de penalidade (e algum feedback
   discreto). Clique dentro da área de acerto do item único = fim.
5. Fim: acende tudo de novo mostrando o item único, mostra tempo final (tempo
   decorrido + penalidades), compara com recorde local daquele ID e salva se for melhor.
6. **Reiniciar** joga o mesmo ID de novo; **Novo tabuleiro** gera outro ID.

## Dificuldade

O slider controla vários parâmetros juntos. Valores iniciais (todos centralizados num
único lugar para ajuste fácil depois de testar):

| Nível   | Objetos | Tempo aceso | Diferença do item único                         | Tolerância de clique |
|---------|---------|-------------|-------------------------------------------------|----------------------|
| Fácil   | 8       | 2,0 s       | cor bem diferente (chama azul entre amarelas)   | generosa             |
| Médio   | 20      | 1,2 s       | cor próxima (laranja) ou chama inclinada        | média                |
| Difícil | 40      | 0,6 s       | detalhe a mais/a menos (sem pavio, gota de cera)| justa                |
| Insano  | 70      | 0,3 s       | detalhe pequeno de alto contraste (pavio torto) | exata                |

Princípio: diferenças que "saltam aos olhos" (cor, inclinação, presença/ausência de
detalhe), **não** diferenças de tamanho. A dificuldade vem mais da quantidade e do
tempo aceso do que de tornar a diferença invisível.

Slider com 4 posições discretas (minha chamada — simplifica o ID e a comparação).

## ID do tabuleiro

- Curto e fácil de ditar (ex.: `X7K2-3`), codificando **semente + dificuldade**.
- O mesmo ID → mesmo tipo de objeto, mesmas posições, mesmo item único, mesma
  variação de diferença, mesma dificuldade. Ao digitar um ID, o slider se ajusta.
- Geração 100% determinística a partir da semente (RNG próprio semeado; nada que
  dependa de frame, tempo ou ordem de iteração não determinística).
- Campo para digitar/colar um ID; ID atual visível e fácil de copiar.

## Objetos

- Desenhados por código (formas simples). Começar com **velas** (corpo, pavio, chama).
- Opcional se der tempo: outros tipos (lâmpadas, olhos...) escolhidos pela semente.

## Power-ups

Cada um pode ser usado **apenas 1 vez por rodada** (eco do tema). Só utilizáveis
depois que a tela apaga.

| Power-up  | Efeito                                                          | Penalidade |
|-----------|-----------------------------------------------------------------|------------|
| Flash     | acende o cenário inteiro por 0,5 s                              | +3 s       |
| Lanterna  | círculo de luz segue o mouse por 4 s                            | +5 s       |
| Radar     | por 3 s, o cursor muda de cor conforme a distância do item (azul longe → vermelho perto) | +4 s |

Radar foi minha escolha entre as opções sugeridas (o usuário gostou de todas);
fácil de trocar. As penalidades entram no tempo final.

## Recordes

- Melhor tempo **por ID** salvo localmente (`user://`, arquivo simples, ex. JSON/ConfigFile).
- Mostrar "seu recorde neste tabuleiro" na coluna esquerda.

## Decisões menores (minhas chamadas, ajustáveis)

- Mexer no slider com um ID carregado mantém a semente, muda a dificuldade e mostra o novo ID.
- Em níveis com duas variações de diferença, a semente escolhe qual.
- Reiniciar / Novo tabuleiro no meio da rodada aborta sem salvar recorde.
- Tolerâncias de clique definidas a partir do tamanho do objeto e ajustadas em playtest.
- +1 s por clique errado é valor inicial; se clicar a esmo compensar no fácil, a
  penalidade aumenta ou cresce a cada erro.

## Deixado para o builder

- Estilo visual exato (paleta, fontes, animações de acender/apagar).
- Feedback de clique errado, som (opcional).
- Formato exato do ID, desde que curto e determinístico.
- Estrutura de cenas/scripts.
