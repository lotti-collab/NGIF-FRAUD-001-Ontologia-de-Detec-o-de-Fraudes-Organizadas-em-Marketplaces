// NGIF-FRAUD-001 — arquivo de RECUPERAÇÃO DOCUMENTAL
// Trechos extraídos do Word, sem validação de execução.
// Alguns trechos podem ser tentativas, consultas parciais ou versões substituídas.
// NÃO executar este arquivo inteiro automaticamente.

// ===== TRECHO 007 | parágrafo Word 1515 | texto normal =====
RETURN name, value;


// ===== TRECHO 011 | parágrafo Word 1637 | preformatado =====
MATCH (c:ContaCliente)
RETURN count(c) AS total_clientes;


// ===== TRECHO 013 | parágrafo Word 1655 | preformatado =====
MATCH (d:Dispositivo)
RETURN count(d) AS total_dispositivos;


// ===== TRECHO 015 | parágrafo Word 1672 | preformatado =====
MATCH (s:Sessao)
RETURN count(s) AS total_sessoes;


// ===== TRECHO 018 | parágrafo Word 1738 | preformatado =====
MATCH (:ContaCliente)-[r:INICIOU]->(:Sessao)
RETURN count(r) AS total_iniciou;


// ===== TRECHO 019 | parágrafo Word 1742 | preformatado =====
MATCH (:Sessao)-[r:UTILIZOU]->(:Dispositivo)
RETURN count(r) AS total_utilizou;


// ===== TRECHO 020 | parágrafo Word 1753 | preformatado =====
MATCH (c:ContaCliente)-[:INICIOU]->(s:Sessao)-[:UTILIZOU]->(d:Dispositivo)
WHERE d.device_id = 'D000005'
RETURN c, s, d
LIMIT 30;


// ===== TRECHO 021 | parágrafo Word 1772 | preformatado =====
MATCH (c:ContaCliente)-[r1:INICIOU]->(s:Sessao)-[r2:UTILIZOU]->(d:Dispositivo)
RETURN c, r1, s, r2, d
LIMIT 20;


// ===== TRECHO 022 | parágrafo Word 1815 | preformatado =====
MATCH (c:ContaCliente)-[:INICIOU]->(s:Sessao)-[:UTILIZOU]->(d:Dispositivo)

WITH d,
     count(DISTINCT c) AS total_clientes,
     count(s) AS total_sessoes

WHERE total_clientes > 1

RETURN
    d.device_id AS dispositivo,
    total_clientes,
    total_sessoes

ORDER BY total_clientes DESC, total_sessoes DESC
LIMIT 20;


// ===== TRECHO 023 | parágrafo Word 1838 | preformatado =====
MATCH (c:ContaCliente)-[:INICIOU]->(:Sessao)-[:UTILIZOU]->(d:Dispositivo)

WITH d, count(DISTINCT c) AS quantidade_clientes

RETURN
    quantidade_clientes,
    count(d) AS quantidade_dispositivos

ORDER BY quantidade_clientes;


// ===== TRECHO 024 | parágrafo Word 1853 | preformatado =====
MATCH (c:ContaCliente)-[:INICIOU]->(:Sessao)-[:UTILIZOU]->(d:Dispositivo)

WITH d, count(DISTINCT c) AS total_clientes

WHERE total_clientes = 4

ORDER BY d.device_id
LIMIT 1

MATCH (c:ContaCliente)-[r1:INICIOU]->(s:Sessao)-[r2:UTILIZOU]->(d)

RETURN c, r1, s, r2, d
LIMIT 50;


// ===== TRECHO 025 | parágrafo Word 1982 | preformatado =====
MATCH (c:ContaCliente)-[:INICIOU]->(s:Sessao)-[:UTILIZOU]->(d:Dispositivo)

WITH d,
     count(DISTINCT c) AS total_clientes

WHERE total_clientes >= 3

ORDER BY total_clientes DESC, d.device_id
LIMIT 1

MATCH (c:ContaCliente)-[:INICIOU]->(s:Sessao)-[:UTILIZOU]->(d)

RETURN
    d.device_id AS dispositivo,
    c.cliente_id AS cliente,
    s.iniciada_em AS inicio_sessao

ORDER BY inicio_sessao
LIMIT 30;


// ===== TRECHO 026 | parágrafo Word 2034 | preformatado =====
MATCH (c:ContaCliente)-[:INICIOU]->(s:Sessao)-[:UTILIZOU]->(d:Dispositivo)
WHERE c.cliente_id IN ['C000034', 'C000035', 'C000036']

RETURN
    c.cliente_id AS cliente,
    d.device_id AS dispositivo,
    count(s) AS total_sessoes,
    min(s.iniciada_em) AS primeira_sessao,
    max(s.iniciada_em) AS ultima_sessao

ORDER BY dispositivo, cliente;


// ===== TRECHO 029 | parágrafo Word 2335 | preformatado =====
MATCH (c:ContaCliente)-[:INICIOU]->(s:Sessao)-[:UTILIZOU]->(d:Dispositivo)
WHERE d.device_id = 'D001219'

WITH d,
     count(DISTINCT c) AS total_clientes,
     count(s) AS total_sessoes,
     min(s.iniciada_em) AS primeira_sessao,
     max(s.iniciada_em) AS ultima_sessao

RETURN
    d.device_id AS dispositivo,
    total_clientes,
    total_sessoes,
    primeira_sessao,
    ultima_sessao;


// ===== TRECHO 032 | parágrafo Word 2541 | preformatado =====
MATCH (c:ContaCliente)-[:INICIOU]->(s:Sessao)-[:UTILIZOU]->(d:Dispositivo)
WHERE d.device_id = 'D001219'

WITH s.iniciada_em AS horario,
     count(*) AS quantidade_sessoes,
     collect({
         cliente: c.cliente_id,
         sessao: s.sessao_id
     }) AS registros

WHERE quantidade_sessoes > 1

RETURN
    horario,
    quantidade_sessoes,
    registros

ORDER BY horario;


// ===== TRECHO 034 | parágrafo Word 2633 | preformatado =====
MATCH (c:ContaCliente)-[:INICIOU]->(s:Sessao)-[:UTILIZOU]->(d:Dispositivo)
WHERE d.device_id = 'D001219'

RETURN
    c.cliente_id AS cliente,
    count(s) AS total_sessoes,
    min(s.iniciada_em) AS primeira_sessao,
    max(s.iniciada_em) AS ultima_sessao

ORDER BY total_sessoes DESC;


// ===== TRECHO 036 | parágrafo Word 2764 | texto normal =====
MATCH (c:ContaCliente)-[:INICIOU]->(s:Sessao)-[:UTILIZOU]->(d:Dispositivo)


// ===== TRECHO 043 | parágrafo Word 3082 | preformatado =====
MATCH (ip:EnderecoIP)
OPTIONAL MATCH (s:Sessao)-[:ORIGINOU_DE]->(ip)

RETURN
    count(DISTINCT ip) AS total_ips,
    count(DISTINCT s) AS sessoes_com_ip,
    count(*) AS relacionamentos_ip;


// ===== TRECHO 049 | parágrafo Word 3341 | preformatado =====
MATCH (ip:EnderecoIP)<-[:ORIGINOU_DE]-(s:Sessao)
      -[:UTILIZOU]->(d:Dispositivo)

WITH
    ip,
    count(DISTINCT d) AS dispositivos

RETURN
    CASE
        WHEN dispositivos <= 20 THEN 'Até 20 dispositivos'
        ELSE 'Mais de 20 dispositivos'
    END AS faixa,
    count(*) AS total_ips,
    sum(CASE WHEN dispositivos > 1 THEN 1 ELSE 0 END)
        AS ips_multiplos_dispositivos,
    max(dispositivos) AS max_dispositivos

ORDER BY faixa;


// ===== TRECHO 050 | parágrafo Word 3362 | preformatado =====
MATCH (ip:EnderecoIP)<-[:ORIGINOU_DE]-(s:Sessao)
      -[:UTILIZOU]->(d:Dispositivo)

WITH
    ip,
    count(DISTINCT d) AS dispositivos

WHERE dispositivos > 1
  AND dispositivos <= 20

RETURN
    count(*) AS ips_compartilhados_preservados,
    sum(dispositivos) AS soma_dispositivos_associados,
    max(dispositivos) AS maior_compartilhamento;


// ===== TRECHO 071 | parágrafo Word 4417 | preformatado =====
MATCH ()-[r]->()
RETURN type(r) AS relacionamento,
       count(r) AS quantidade
ORDER BY relacionamento;


// ===== TRECHO 074 | parágrafo Word 4501 | preformatado =====
MATCH (c1:ContaCliente)-[:INICIOU]->(:Sessao)
      -[:UTILIZOU]->(d:Dispositivo)

MATCH (c2:ContaCliente)-[:INICIOU]->(:Sessao)
      -[:UTILIZOU]->(d)

WHERE c1.cliente_id < c2.cliente_id

WITH
    c1,
    c2,
    count(DISTINCT d) AS dispositivos_compartilhados

RETURN
    c1.cliente_id AS conta_1,
    c2.cliente_id AS conta_2,
    dispositivos_compartilhados

ORDER BY dispositivos_compartilhados DESC,
         conta_1,
         conta_2

LIMIT 15;


// ===== TRECHO 076 | parágrafo Word 4623 | texto normal =====
MATCH (c:ContaCliente)
WHERE c.cliente_id IN ['C002162', 'C002164']


// ===== TRECHO 081 | parágrafo Word 4930 | preformatado =====
MATCH (c1:ContaCliente)-[:INICIOU]->(:Sessao)
      -[:UTILIZOU]->(:Dispositivo)
      <-[:UTILIZOU]-(:Sessao)<-[:INICIOU]-(c2:ContaCliente)

WHERE c1.cliente_id < c2.cliente_id

RETURN DISTINCT
    c1.cliente_id AS conta_1,
    c2.cliente_id AS conta_2

ORDER BY conta_1, conta_2;

