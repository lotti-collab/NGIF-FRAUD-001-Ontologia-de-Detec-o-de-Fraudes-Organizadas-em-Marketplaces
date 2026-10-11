// NGIF-FRAUD-001 — arquivo de RECUPERAÇÃO DOCUMENTAL
// Trechos extraídos do Word, sem validação de execução.
// Alguns trechos podem ser tentativas, consultas parciais ou versões substituídas.
// NÃO executar este arquivo inteiro automaticamente.

// ===== TRECHO 061 | parágrafo Word 4256 | preformatado =====
MATCH (r:Restaurante)
RETURN count(r) AS total_restaurantes;


// ===== TRECHO 063 | parágrafo Word 4294 | preformatado =====
MATCH (p:Pedido)
RETURN
    count(p) AS total_pedidos,
    count(p.criado_em) AS pedidos_com_data,
    count(p.valor_bruto) AS pedidos_com_valor,
    sum(p.valor_bruto) AS valor_bruto_total;


// ===== TRECHO 064 | parágrafo Word 4328 | texto normal =====
MATCH (p:Pedido)
MATCH (c:ContaCliente {cliente_id: p.cliente_id})


// ===== TRECHO 065 | parágrafo Word 4333 | texto normal =====
RETURN count(p) AS pedidos_vinculados;


// ===== TRECHO 066 | parágrafo Word 4344 | texto normal =====
MATCH (:ContaCliente)-[r:REALIZOU]->(:Pedido)
RETURN count(r) AS total_relacionamentos;


// ===== TRECHO 067 | parágrafo Word 4369 | texto normal =====
MATCH (p:Pedido)
MATCH (s:Sessao {sessao_id: p.sessao_id})


// ===== TRECHO 068 | parágrafo Word 4377 | texto normal =====
MATCH (:Sessao)-[r:GEROU]->(:Pedido)
RETURN count(r) AS total_relacionamentos;


// ===== TRECHO 069 | parágrafo Word 4384 | texto normal =====
MATCH (p:Pedido)
MATCH (r:Restaurante {
    restaurante_id: p.restaurante_id
})


// ===== TRECHO 070 | parágrafo Word 4394 | texto normal =====
MATCH (:Pedido)-[r:DESTINADO_A]->(:Restaurante)
RETURN count(r) AS total_relacionamentos;


// ===== TRECHO 073 | parágrafo Word 4468 | preformatado =====
MATCH (c:ContaCliente)-[:REALIZOU]->(p:Pedido)
MATCH (s:Sessao)-[:GEROU]->(p)
MATCH (c_sessao:ContaCliente)-[:INICIOU]->(s)

RETURN
    count(p) AS pedidos_auditados,
    sum(
        CASE
            WHEN c = c_sessao THEN 0
            ELSE 1
        END
    ) AS divergencias;


// ===== TRECHO 075 | parágrafo Word 4528 | preformatado =====
MATCH (c1:ContaCliente)-[:INICIOU]->(:Sessao)
      -[:UTILIZOU]->(d:Dispositivo)

MATCH (c2:ContaCliente)-[:INICIOU]->(:Sessao)
      -[:UTILIZOU]->(d)

WHERE c1.cliente_id < c2.cliente_id

WITH DISTINCT c1, c2

MATCH (c1)-[:REALIZOU]->(:Pedido)
      -[:DESTINADO_A]->(r:Restaurante)

MATCH (c2)-[:REALIZOU]->(:Pedido)
      -[:DESTINADO_A]->(r)

RETURN
    c1.cliente_id AS conta_1,
    c2.cliente_id AS conta_2,
    count(DISTINCT r) AS restaurantes_em_comum

ORDER BY restaurantes_em_comum DESC,
         conta_1,
         conta_2

LIMIT 15;


// ===== TRECHO 077 | parágrafo Word 4626 | texto normal =====
MATCH (c)-[:REALIZOU]->(:Pedido)
      -[:DESTINADO_A]->(r:Restaurante)


// ===== TRECHO 078 | parágrafo Word 4654 | texto normal =====
MATCH (c:ContaCliente)-[:REALIZOU]->(p:Pedido)
WHERE c.cliente_id IN ['C002162', 'C002164']


// ===== TRECHO 079 | parágrafo Word 4703 | preformatado =====
MATCH (c1:ContaCliente)-[:INICIOU]->(:Sessao)
      -[:UTILIZOU]->(d:Dispositivo)
      <-[:UTILIZOU]-(:Sessao)<-[:INICIOU]-(c2:ContaCliente)
WHERE c1.cliente_id < c2.cliente_id

WITH DISTINCT c1, c2

OPTIONAL MATCH (c1)-[:REALIZOU]->(:Pedido)
               -[:DESTINADO_A]->(r1:Restaurante)
WITH c1, c2,
     collect(DISTINCT r1.restaurante_id) AS restaurantes1

OPTIONAL MATCH (c2)-[:REALIZOU]->(:Pedido)
               -[:DESTINADO_A]->(r2:Restaurante)
WITH c1, c2, restaurantes1,
     collect(DISTINCT r2.restaurante_id) AS restaurantes2

WITH c1, c2, restaurantes1, restaurantes2,
     [r IN restaurantes1 WHERE r IN restaurantes2] AS comuns

WITH c1, c2,
     size(restaurantes1) AS n1,
     size(restaurantes2) AS n2,
     size(comuns) AS intersecao

WITH c1, c2, intersecao,
     n1 + n2 - intersecao AS uniao

WITH c1, c2, intersecao,
     CASE
         WHEN uniao = 0 THEN null
         ELSE toFloat(intersecao) / uniao
     END AS jaccard

RETURN
    count(*) AS total_pares,
    count(jaccard) AS pares_com_jaccard_definido,
    sum(CASE WHEN intersecao > 0 THEN 1 ELSE 0 END)
        AS pares_com_restaurantes_em_comum,
    round(avg(jaccard), 4) AS jaccard_medio,
    round(percentileCont(jaccard, 0.50), 4) AS mediana,
    round(percentileCont(jaccard, 0.90), 4) AS p90,
    round(percentileCont(jaccard, 0.95), 4) AS p95,
    round(max(jaccard), 4) AS jaccard_maximo;


// ===== TRECHO 080 | parágrafo Word 4791 | preformatado =====
MATCH (c1:ContaCliente)-[:INICIOU]->(:Sessao)
      -[:UTILIZOU]->(:Dispositivo)
      <-[:UTILIZOU]-(:Sessao)<-[:INICIOU]-(c2:ContaCliente)
WHERE c1.cliente_id < c2.cliente_id

WITH DISTINCT c1, c2

MATCH (c1)-[:REALIZOU]->(:Pedido)-[:DESTINADO_A]->(r1:Restaurante)
WITH c1, c2, collect(DISTINCT r1.restaurante_id) AS a

MATCH (c2)-[:REALIZOU]->(:Pedido)-[:DESTINADO_A]->(r2:Restaurante)
WITH c1, c2, a, collect(DISTINCT r2.restaurante_id) AS b

WITH c1, c2, a, b,
     [r IN a WHERE r IN b] AS comuns

WHERE size(a) + size(b) - size(comuns) > 0

WITH c1, c2, a, b, comuns,
     toFloat(size(comuns)) /
     (size(a) + size(b) - size(comuns)) AS jaccard

RETURN
    c1.cliente_id AS conta_1,
    c2.cliente_id AS conta_2,
    size(a) AS restaurantes_1,
    size(b) AS restaurantes_2,
    size(comuns) AS restaurantes_comuns,
    round(jaccard, 4) AS jaccard

ORDER BY jaccard DESC, restaurantes_comuns DESC
LIMIT 10;

