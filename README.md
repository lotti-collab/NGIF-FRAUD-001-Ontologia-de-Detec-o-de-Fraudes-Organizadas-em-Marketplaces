# NOXTRON | NGIF-FRAUD-001

## O grafo não acusa. O grafo revela relações. A investigação transforma essas relações em perguntas que podem ser testadas.

**Graph Intelligence aplicada à investigação exploratória de padrões relacionais e transacionais em um marketplace sintético.**

> **Natureza:** estudo independente, educacional e inteiramente sintético. Não reproduz dados, sistemas, decisões ou resultados internos de qualquer empresa. **Nenhum participante é classificado como fraudador.**

## 1. A pergunta que iniciou o projeto

Uma transação isolada pode parecer normal. O que muda quando investigamos suas conexões com contas, sessões, dispositivos, endereços IP, pedidos e restaurantes? E como evitar que conexões comuns sejam confundidas com evidências de fraude?

O objetivo foi construir uma investigação **auditável, gradual e cautelosa**, distinguindo observações, hipóteses e conclusões. O projeto não entrega um detector de fraude em produção nem um modelo supervisionado validado.

## 2. Arquitetura e dados

A proposta ontológica completa está documentada no **Contrato Semântico Consolidado** e no **Dicionário Ontológico**. A implementação deste estudo é um **subconjunto** da ontologia proposta, não a implementação integral do contrato.

- **Geração:** Python, seed `42`, 90 dias, 3.000 contas e 120 restaurantes.
- **Eventos:** 17.447 sessões e 17.447 pedidos; 1.709 dispositivos; 1.632 IPs tokenizados observados no grafo.
- **Contas com pedidos:** 2.665.
- **Grafo observado:** 41.355 nós e 104.682 relacionamentos.
- **Tecnologias:** Python, pandas, NumPy, Neo4j, Cypher e Graph Data Science (GDS).

### Subgrafo investigado

```text
(:ContaCliente)-[:INICIOU]->(:Sessao)-[:UTILIZOU]->(:Dispositivo)
                            |
                            +--[:ORIGINOU_DE]->(:EnderecoIP)
                            |
                            +--[:GEROU]->(:Pedido)-[:DESTINADO_A]->(:Restaurante)
(:ContaCliente)-[:REALIZOU]->(:Pedido)
```

**Nota semântica:** `ContaCliente` é uma conta digital, não necessariamente uma pessoa. IPs e dispositivos podem ser legitimamente compartilhados. Pedido registrado não comprova entrega física. A estrutura do grafo não equivale a uma organização criminosa.

## 3. A jornada investigativa

### 3.1 Integridade antes de inferência

Foram verificados 17.447 pedidos e a consistência entre a conta que realizou o pedido e a conta que iniciou a sessão correspondente: **zero divergências** nesse teste. Isso valida uma regra específica de integridade, não a veracidade do mundo real.

### 3.2 Compartilhamento de dispositivos

Dos 1.709 dispositivos, 1.599 apareceram em sessões. Entre esses, 753 foram compartilhados por duas ou mais contas, envolvendo 1.819 contas. Compartilhar dispositivo, por si só, **não é fraude**.

A análise temporal encontrou **5.096 transições consecutivas entre contas diferentes no mesmo dispositivo**, das quais **88 ocorreram em até 60 minutos**. O dispositivo `D001219` foi examinado como estudo de caso descritivo, sem atribuição de culpa às contas conectadas.

### 3.3 Componentes conectados: a armadilha dos hubs

Foram comparadas três projeções exploratórias de componentes fracamente conectados (WCC):

| Projeção | Relações consideradas | Componentes WCC | Maior componente |
|---|---|---:|---:|
| V1 | Conta–Sessão–Dispositivo | 1.599 | 108 nós |
| V2 | V1 + IPs | 569 | 18.974 nós |
| V3 | V2, excluindo da projeção conexões de IPs associados a mais de 20 dispositivos | 1.599 | 109 nós |

**Lição:** incluir IPs de alta conectividade criou um componente gigante, mas isso não demonstra uma rede fraudulenta. A filtragem da V3 foi **exploratória**; nenhum nó precisou ser excluído da base original.

### 3.4 Hipóteses temporais e simulações

Em 54 IPs usados por mais de um dispositivo, houve **2.416 transições consecutivas entre dispositivos diferentes**, das quais **78 ocorreram em até 60 minutos**. Um modelo nulo com reamostragem de horários empíricos produziu média aproximada de **76,97**, com **p empírico ≈ 0,4625**: não houve evidência de excesso agregado de proximidade temporal nesse teste.

Uma observação localizada e selecionada após a exploração não foi tratada como confirmação, por envolver **seleção pós-hoc e múltiplas comparações**.

### 3.5 Similaridade transacional: Jaccard

Foram identificados **1.430 pares únicos de contas que compartilham dispositivo**. Eles foram comparados com **1.430 pares aleatórios de contas com pedidos que não compartilham dispositivo**, no sorteio inicial.

| Métrica | Compartilham dispositivo | Controle inicial |
|---|---:|---:|
| Pares | 1.430 | 1.430 |
| Jaccard médio tradicional | 0,0964 | 0,0298 |
| Mediana tradicional | 0,0714 | 0,0000 |
| Pares com ao menos um restaurante em comum | 54,13% | 21,33% |

A diferença persistiu descritivamente em cinco faixas de atividade, embora a estratificação por **soma** de restaurantes distintos não controle completamente o perfil individual de cada conta.

### 3.6 Popularidade dos restaurantes e Jaccard ponderado

Os 120 restaurantes foram frequentados por **8 a 406 contas distintas**, com mediana de **93**. Para reduzir a influência de restaurantes muito populares, utilizou-se uma ponderação exploratória do tipo IDF:

\[
w(r)=\ln\left(\frac{N+1}{n_r+1}\right)+1
\]

Em que `N = 2665` é o número de contas com pedidos e `n_r` é o número de contas distintas que frequentaram o restaurante `r`.

O **Jaccard ponderado** é a soma dos pesos dos restaurantes comuns dividida pela soma dos pesos dos restaurantes presentes em pelo menos uma das contas.

| Métrica | Compartilham dispositivo | Controle inicial |
|---|---:|---:|
| Jaccard médio ponderado | **0,0894** | **0,0272** |
| Mediana ponderada | 0,0662 | 0,0000 |
| Percentil 90 ponderado | 0,2343 | 0,1011 |
| Percentil 95 ponderado | 0,2996 | 0,1670 |

O par estudado `C002162`–`C002164` apresentou Jaccard tradicional **0,3243** e ponderado **0,3108**. Esses valores são **similaridades**, não probabilidades de fraude.

### 3.7 Sensibilidade ao sorteio do controle

Foram gerados **100 grupos de controle aleatórios**, cada um com 1.430 pares distintos, excluindo pares que compartilham dispositivos.

| Estatística das médias de controle (Jaccard ponderado) | Valor |
|---|---:|
| Média | 0,0274 |
| Desvio-padrão | 0,0017 |
| Mínimo / máximo | 0,0227 / 0,0312 |
| Percentis 2,5 / 97,5 | 0,0240 / 0,0303 |
| Média observada dos pares que compartilham dispositivo | **0,0894** |

A diferença descritiva persistiu em todos os sorteios. **Isso é uma análise de sensibilidade ao grupo de referência, não um teste confirmatório de hipótese, intervalo de confiança causal ou validação antifraude.**

## 4. O que aprendemos — e o que não demonstramos

**Aprendemos:**

1. A estrutura da ontologia torna as relações rastreáveis e investigáveis.
2. Hubs de IP podem distorcer análises de componentes conectados.
3. Proximidade temporal exige referência comparativa; um padrão visual não basta.
4. Pares que compartilham dispositivos apresentaram maior similaridade transacional **nesta base sintética**; o resultado persistiu sob ponderação por popularidade e diferentes sorteios de controle.
5. Uma análise responsável também registra hipóteses não confirmadas.

**Não demonstramos:** fraude organizada, intenção, causalidade, eficácia operacional de um classificador, generalização para dados reais ou significância confirmatória. O processo gerador sintético, dependência entre pares, diferenças residuais de atividade, popularidade e desenho dos controles podem afetar os resultados. O estudo não dispõe de rótulos de fraude validados.

## 5. Reproduzir a geração sintética

A partir da pasta do Sprint 01, com Python 3.10+:

```bash
python -m pip install -r requirements.txt
python src/generate.py --output data --seed 42 --clients 3000 --restaurants 120 --mean-orders 6 --days 90
python src/validate.py --data data
```

O repositório original do Sprint 01 inclui o gerador, validador e arquivos CSV de base. **As consultas Cypher, projeções GDS, exportações auxiliares e notebooks dos experimentos precisam ser adicionados ao repositório para que a investigação completa seja reproduzível.** Não se deve afirmar reprodutibilidade integral antes dessa inclusão.

## 6. Organização sugerida do repositório

```text
NGIF-FRAUD-001/
├── README.md
├── data/                  # dados sintéticos e documentação dos CSVs
├── src/                   # gerador e validação
├── cypher/                # importação, integridade e projeções GDS
├── notebooks/             # análises temporais, Jaccard e simulações
├── images/                # diagramas e gráficos exportados
├── docs/                  # contrato semântico e dicionário ontológico
└── requirements.txt
```

Os caminhos `cypher/`, `notebooks/` e `images/` representam **estrutura recomendada**; crie-os e preencha-os antes de anunciar que os materiais estão disponíveis.

## 7. Próximos passos possíveis

Investigar, em trabalhos futuros, controles pareados por atividade, modelos nulos que preservem a estrutura do grafo, correção para múltiplos testes, mecanismos sintéticos de fraude com *ground truth* segregado, avaliação de custo de falsos positivos e validação temporal. Essas extensões **não fazem parte das conclusões atuais**.

---

**NOXTRON — Graph Intelligence**  
**NGIF-FRAUD-001 — Ontologia de Detecção de Fraudes Organizadas em Marketplaces**
** Alexandre Lotti **
** <!LOTTI> **

> **O grafo não acusa. O grafo revela relações. A investigação transforma essas relações em perguntas que podem ser testadas.**
