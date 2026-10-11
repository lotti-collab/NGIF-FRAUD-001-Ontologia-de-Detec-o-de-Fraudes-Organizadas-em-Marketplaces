// NGIF-FRAUD-001 — arquivo de RECUPERAÇÃO DOCUMENTAL
// Trechos extraídos do Word, sem validação de execução.
// Alguns trechos podem ser tentativas, consultas parciais ou versões substituídas.
// NÃO executar este arquivo inteiro automaticamente.

// ===== TRECHO 001 | parágrafo Word 1312 | preformatado =====
# Relações únicas entre clientes e dispositivoscliente_dispositivo = (    sessoes[["cliente_id", "device_id"]]    .drop_duplicates())# Número de contas por dispositivoqtd_contas = (    cliente_dispositivo.groupby("device_id")["cliente_id"]    .nunique()    .rename("contas_no_dispositivo"))# Associar a contagem às relaçõescliente_dispositivo = cliente_dispositivo.merge(    qtd_contas,    on="device_id",    how="left")# Feature por clientefeatures_dispositivo = (    cliente_dispositivo.groupby("cliente_id")    .agg(        max_contas_dispositivo=(            "contas_no_dispositivo", "max"        ),        dispositivos_distintos=("device_id", "nunique")    )    .reset_index())display(features_dispositivo.head(10))


// ===== TRECHO 008 | parágrafo Word 1523 | texto normal =====
LOAD CSV WITH HEADERS
FROM 'file:///clientes.csv' AS row
RETURN row
LIMIT 5;


// ===== TRECHO 009 | parágrafo Word 1570 | preformatado =====
LOAD CSV WITH HEADERS
FROM 'file:///clientes.csv' AS row
RETURN row.cliente_id AS cliente
LIMIT 5;


// ===== TRECHO 010 | parágrafo Word 1626 | preformatado =====
LOAD CSV WITH HEADERS
FROM 'file:///clientes.csv' AS row

WITH row
WHERE row.cliente_id IS NOT NULL

MERGE (c:ContaCliente {
    cliente_id: row.cliente_id
});


// ===== TRECHO 012 | parágrafo Word 1644 | preformatado =====
LOAD CSV WITH HEADERS
FROM 'file:///dispositivos.csv' AS row

WITH row
WHERE row.device_id IS NOT NULL

MERGE (d:Dispositivo {
    device_id: row.device_id
})
SET d.device_type = row.device_type;


// ===== TRECHO 014 | parágrafo Word 1660 | preformatado =====
LOAD CSV WITH HEADERS
FROM 'file:///sessoes.csv' AS row

WITH row
WHERE row.sessao_id IS NOT NULL

MERGE (s:Sessao {
    sessao_id: row.sessao_id
})
SET s.iniciada_em = datetime(row.iniciada_em),
    s.ip_token = row.ip_token;


// ===== TRECHO 016 | parágrafo Word 1704 | preformatado =====
LOAD CSV WITH HEADERS
FROM 'file:///sessoes.csv' AS row

MATCH (c:ContaCliente {
    cliente_id: row.cliente_id
})

MATCH (s:Sessao {
    sessao_id: row.sessao_id
})

MERGE (c)-[:INICIOU]->(s);


// ===== TRECHO 017 | parágrafo Word 1723 | preformatado =====
LOAD CSV WITH HEADERS
FROM 'file:///sessoes.csv' AS row

MATCH (s:Sessao {
    sessao_id: row.sessao_id
})

MATCH (d:Dispositivo {
    device_id: row.device_id
})

MERGE (s)-[:UTILIZOU]->(d);


// ===== TRECHO 042 | parágrafo Word 3072 | preformatado =====
MATCH (s:Sessao)
WHERE s.ip_token IS NOT NULL
  AND trim(s.ip_token) <> ''

MERGE (ip:EnderecoIP {ip_token: s.ip_token})
MERGE (s)-[:ORIGINOU_DE]->(ip);


// ===== TRECHO 060 | parágrafo Word 4237 | preformatado =====
LOAD CSV WITH HEADERS FROM 'file:///pedidos.csv' AS row

WITH DISTINCT row.restaurante_id AS restaurante_id

MERGE (r:Restaurante {
    restaurante_id: restaurante_id
})

RETURN count(r) AS restaurantes_processados;


// ===== TRECHO 062 | parágrafo Word 4269 | preformatado =====
LOAD CSV WITH HEADERS FROM 'file:///pedidos.csv' AS row

MERGE (p:Pedido {pedido_id: row.pedido_id})

SET
    p.cliente_id = row.cliente_id,
    p.restaurante_id = row.restaurante_id,
    p.sessao_id = row.sessao_id,
    p.criado_em = datetime(row.criado_em),
    p.valor_bruto = toFloat(row.valor_bruto),
    p.moeda = row.moeda

RETURN count(p) AS pedidos_processados;


// ===== TRECHO 072 | parágrafo Word 4426 | preformatado =====
MATCH (p:Pedido)
MATCH (r:Restaurante {
    restaurante_id: p.restaurante_id
})
MERGE (p)-[:DESTINADO_A]->(r)
RETURN count(p) AS pedidos_vinculados;

