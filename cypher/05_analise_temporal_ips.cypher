// NGIF-FRAUD-001 — arquivo de RECUPERAÇÃO DOCUMENTAL
// Trechos extraídos do Word, sem validação de execução.
// Alguns trechos podem ser tentativas, consultas parciais ou versões substituídas.
// NÃO executar este arquivo inteiro automaticamente.

// ===== TRECHO 002 | parágrafo Word 1436 | preformatado =====
RETURN
    "NGIF-FRAUD-001" AS projeto,
    "Conexão funcionando" AS status,
    datetime() AS momento;


// ===== TRECHO 027 | parágrafo Word 2084 | preformatado =====
MATCH (c:ContaCliente)-[:INICIOU]->(s:Sessao)-[:UTILIZOU]->(d:Dispositivo)

WITH d, c, s
ORDER BY d.device_id, s.iniciada_em, s.sessao_id

WITH d,
     collect({
         cliente: c.cliente_id,
         momento: s.iniciada_em
     }) AS eventos

WHERE size(eventos) > 1

UNWIND range(1, size(eventos) - 1) AS i

WITH d,
     eventos[i - 1] AS anterior,
     eventos[i] AS atual

WITH d,
     anterior,
     atual,
     duration.inSeconds(
         anterior.momento,
         atual.momento
     ).seconds / 60.0 AS minutos

WITH d,
     count(*) AS transicoes,
     sum(
         CASE
             WHEN anterior.cliente <> atual.cliente
             THEN 1 ELSE 0
         END
     ) AS trocas_conta,
     sum(
         CASE
             WHEN anterior.cliente <> atual.cliente
                  AND minutos <= 60
             THEN 1 ELSE 0
         END
     ) AS trocas_rapidas

RETURN
    count(d) AS dispositivos_analisados,
    sum(trocas_conta) AS total_trocas_conta,
    sum(trocas_rapidas) AS total_trocas_rapidas,
    sum(
        CASE WHEN trocas_rapidas > 0
        THEN 1 ELSE 0 END
    ) AS dispositivos_com_troca_rapida;


// ===== TRECHO 028 | parágrafo Word 2262 | preformatado =====
MATCH (c:ContaCliente)-[:INICIOU]->(s:Sessao)-[:UTILIZOU]->(d:Dispositivo)

WITH d, c, s
ORDER BY d.device_id, s.iniciada_em, s.sessao_id

WITH d,
     collect({
         cliente: c.cliente_id,
         momento: s.iniciada_em
     }) AS eventos

WHERE size(eventos) > 1

UNWIND range(1, size(eventos) - 1) AS i

WITH d,
     eventos[i - 1] AS anterior,
     eventos[i] AS atual

WITH d, anterior, atual,
     duration.inSeconds(
         anterior.momento,
         atual.momento
     ).seconds / 60.0 AS minutos

WHERE anterior.cliente <> atual.cliente
  AND minutos <= 60

RETURN
    d.device_id AS dispositivo,
    count(*) AS trocas_rapidas,
    min(minutos) AS menor_intervalo_min,
    round(avg(minutos), 1) AS intervalo_medio_min

ORDER BY trocas_rapidas DESC,
         menor_intervalo_min ASC
LIMIT 15;


// ===== TRECHO 030 | parágrafo Word 2355 | preformatado =====
MATCH (c:ContaCliente)-[:INICIOU]->(s:Sessao)-[:UTILIZOU]->(d:Dispositivo)
WHERE d.device_id = 'D001219'

WITH c, s
ORDER BY s.iniciada_em, s.sessao_id

WITH collect({
    cliente: c.cliente_id,
    momento: s.iniciada_em
}) AS eventos

UNWIND range(1, size(eventos) - 1) AS i

WITH eventos[i - 1] AS anterior,
     eventos[i] AS atual

WITH anterior, atual,
     duration.inSeconds(
         anterior.momento,
         atual.momento
     ).seconds / 60.0 AS minutos

WHERE anterior.cliente <> atual.cliente
  AND minutos <= 60

RETURN
    anterior.cliente AS cliente_anterior,
    atual.cliente AS cliente_atual,
    anterior.momento AS horario_anterior,
    atual.momento AS horario_atual,
    minutos AS intervalo_minutos

ORDER BY horario_atual;


// ===== TRECHO 031 | parágrafo Word 2421 | preformatado =====
MATCH (c:ContaCliente)-[:INICIOU]->(s:Sessao)-[:UTILIZOU]->(d:Dispositivo)
WHERE d.device_id = 'D001219'

WITH c, s
ORDER BY s.iniciada_em, s.sessao_id

WITH collect({
    cliente: c.cliente_id,
    momento: s.iniciada_em
}) AS eventos

UNWIND range(1, size(eventos) - 1) AS i

WITH eventos[i - 1] AS anterior,
     eventos[i] AS atual

WITH anterior, atual,
     duration.inSeconds(
         anterior.momento,
         atual.momento
     ).seconds / 60.0 AS minutos

WITH
    count(*) AS total_transicoes,
    sum(CASE
        WHEN anterior.cliente <> atual THEN 1
        ELSE 0
    END) AS trocas_conta,
    sum(CASE
        WHEN anterior.cliente <> atual
         AND minutos <= 60 THEN 1
        ELSE 0
    END) AS trocas_rapidas

RETURN
    total_transicoes,
    trocas_conta,
    trocas_rapidas,
    round(
        100.0 * trocas_rapidas /
        CASE WHEN trocas_conta = 0 THEN 1 ELSE trocas_conta END,
        2
    ) AS percentual_trocas_rapidas;


// ===== TRECHO 033 | parágrafo Word 2562 | preformatado =====
MATCH (c:ContaCliente)-[:INICIOU]->(s:Sessao)-[:UTILIZOU]->(d:Dispositivo)
WHERE d.device_id = 'D001219'

WITH c, s
ORDER BY s.iniciada_em, s.sessao_id

WITH collect({
    cliente: c.cliente_id,
    sessao: s.sessao_id,
    momento: s.iniciada_em
}) AS eventos

UNWIND range(1, size(eventos) - 1) AS i

WITH eventos[i - 1] AS anterior,
     eventos[i] AS atual

WITH anterior, atual,
     duration.inSeconds(
         anterior.momento,
         atual.momento
     ).seconds / 60.0 AS minutos

RETURN
    count(*) AS total_transicoes,

    sum(CASE
        WHEN anterior.cliente <> atual
        THEN 1 ELSE 0
    END) AS trocas_conta,

    sum(CASE
        WHEN anterior.cliente <> atual
         AND minutos <= 60
        THEN 1 ELSE 0
    END) AS trocas_rapidas,

    min(minutos) AS menor_intervalo_minutos;


// ===== TRECHO 035 | parágrafo Word 2673 | preformatado =====
MATCH (c:ContaCliente)-[:INICIOU]->(s:Sessao)-[:UTILIZOU]->(d:Dispositivo)
WHERE d.device_id = 'D001219'

WITH c, s
ORDER BY s.iniciada_em, s.sessao_id

WITH collect({
    cliente: c.cliente_id,
    sessao: s.sessao_id,
    momento: s.iniciada_em
}) AS eventos

UNWIND range(1, size(eventos) - 1) AS i

WITH eventos[i - 1] AS anterior,
     eventos[i] AS atual

WITH anterior, atual,
     duration.inSeconds(
         anterior.momento,
         atual.momento
     ).seconds / 60.0 AS minutos

RETURN
    count(*) AS total_transicoes,

    sum(CASE
        WHEN anterior.cliente = atual.cliente
        THEN 1 ELSE 0
    END) AS mesma_conta,

    sum(CASE
        WHEN anterior.cliente <> atual.cliente
        THEN 1 ELSE 0
    END) AS contas_diferentes,

    sum(CASE
        WHEN anterior.cliente <> atual.cliente
         AND minutos <= 60
        THEN 1 ELSE 0
    END) AS trocas_rapidas,

    sum(CASE
        WHEN minutos < 0
        THEN 1 ELSE 0
    END) AS intervalos_negativos;


// ===== TRECHO 037 | parágrafo Word 2777 | texto normal =====
UNWIND range(1, size(eventos) - 1) AS i


// ===== TRECHO 038 | parágrafo Word 2847 | preformatado =====
MATCH (c:ContaCliente)-[:INICIOU]->(s:Sessao)-[:UTILIZOU]->(d:Dispositivo)

WITH d, c, s
ORDER BY d.device_id, s.iniciada_em, s.sessao_id

WITH d,
     collect({
         cliente: c.cliente_id,
         momento: s.iniciada_em
     }) AS eventos

WHERE size(eventos) > 1

UNWIND range(1, size(eventos) - 1) AS i

WITH
    d,
    eventos[i - 1] AS anterior,
    eventos[i] AS atual

WITH
    d,
    anterior,
    atual,
    duration.inSeconds(
        anterior.momento,
        atual.momento
    ).seconds / 60.0 AS minutos

RETURN
    count(*) AS total_transicoes,

    sum(CASE
        WHEN anterior.cliente = atual.cliente
        THEN 1 ELSE 0
    END) AS mesma_conta,

    sum(CASE
        WHEN anterior.cliente <> atual.cliente
        THEN 1 ELSE 0
    END) AS contas_diferentes,

    sum(CASE
        WHEN anterior.cliente <> atual.cliente
         AND minutos <= 60
        THEN 1 ELSE 0
    END) AS trocas_rapidas,

    sum(CASE
        WHEN minutos < 0
        THEN 1 ELSE 0
    END) AS intervalos_negativos;


// ===== TRECHO 051 | parágrafo Word 3421 | preformatado =====
MATCH (ip:EnderecoIP)<-[:ORIGINOU_DE]-(s:Sessao)
      -[:UTILIZOU]->(d:Dispositivo)

WITH
    ip,
    count(DISTINCT d) AS dispositivos,
    count(DISTINCT s) AS sessoes,
    min(s.iniciada_em) AS primeira_sessao,
    max(s.iniciada_em) AS ultima_sessao

WHERE dispositivos > 20

RETURN
    ip.ip_token AS ip,
    dispositivos,
    sessoes,
    primeira_sessao,
    ultima_sessao

ORDER BY dispositivos DESC
LIMIT 10;


// ===== TRECHO 052 | parágrafo Word 3471 | preformatado =====
MATCH (ip:EnderecoIP {ip_token: 'IP00012'})
      <-[:ORIGINOU_DE]-(s:Sessao)
      -[:UTILIZOU]->(d:Dispositivo)

WITH s, d
ORDER BY s.iniciada_em, s.sessao_id

WITH collect({
    sessao: s.sessao_id,
    dispositivo: d.device_id,
    instante: s.iniciada_em
}) AS eventos

UNWIND range(1, size(eventos) - 1) AS i

WITH
    eventos[i - 1] AS anterior,
    eventos[i] AS atual

WITH
    anterior,
    atual,
    duration.inSeconds(
        anterior.instante,
        atual.instante
    ).seconds / 60.0 AS intervalo_minutos

RETURN
    count(*) AS transicoes_totais,

    sum(
        CASE WHEN anterior.dispositivo <> atual.dispositivo
        THEN 1 ELSE 0 END
    ) AS transicoes_entre_dispositivos,

    sum(
        CASE WHEN anterior.dispositivo <> atual.dispositivo
                  AND intervalo_minutos <= 60
        THEN 1 ELSE 0 END
    ) AS transicoes_rapidas_60min,

    min(intervalo_minutos) AS menor_intervalo_min,

    sum(
        CASE WHEN intervalo_minutos < 0
        THEN 1 ELSE 0 END
    ) AS intervalos_negativos;


// ===== TRECHO 053 | parágrafo Word 3522 | preformatado =====
MATCH (ip:EnderecoIP {ip_token: 'IP00012'})
      <-[:ORIGINOU_DE]-(s:Sessao)
      -[:UTILIZOU]->(d:Dispositivo)

WITH s, d
ORDER BY s.iniciada_em, s.sessao_id

WITH collect({
    sessao: s.sessao_id,
    dispositivo: d.device_id,
    instante: s.iniciada_em
}) AS eventos

UNWIND range(1, size(eventos) - 1) AS i

WITH
    eventos[i - 1] AS anterior,
    eventos[i] AS atual

WHERE anterior.dispositivo <> atual.dispositivo

RETURN
    anterior.dispositivo AS dispositivo_origem,
    atual.dispositivo AS dispositivo_destino,
    anterior.instante AS horario_anterior,
    atual.instante AS horario_atual,

    duration.inSeconds(
        anterior.instante,
        atual.instante
    ).seconds / 60.0 AS intervalo_minutos

ORDER BY intervalo_minutos ASC
LIMIT 10;


// ===== TRECHO 054 | parágrafo Word 3598 | preformatado =====
MATCH (ip:EnderecoIP)<-[:ORIGINOU_DE]-(s:Sessao)
      -[:UTILIZOU]->(d:Dispositivo)

WITH ip, s, d
ORDER BY ip.ip_token, s.iniciada_em, s.sessao_id

WITH
    ip,
    collect({
        dispositivo: d.device_id,
        instante: s.iniciada_em
    }) AS eventos,
    count(DISTINCT d) AS dispositivos

WHERE dispositivos > 20

UNWIND range(1, size(eventos) - 1) AS i

WITH
    ip,
    dispositivos,
    eventos[i - 1] AS anterior,
    eventos[i] AS atual

WITH
    ip,
    dispositivos,
    anterior,
    atual,
    duration.inSeconds(
        anterior.instante,
        atual.instante
    ).seconds / 60.0 AS minutos

WITH
    ip,
    dispositivos,
    count(*) AS transicoes,
    sum(
        CASE
            WHEN anterior.dispositivo <> atual.dispositivo
            THEN 1 ELSE 0
        END
    ) AS transicoes_entre_dispositivos,
    sum(
        CASE
            WHEN anterior.dispositivo <> atual.dispositivo
             AND minutos >= 0
             AND minutos <= 60
            THEN 1 ELSE 0
        END
    ) AS rapidas_60min

RETURN
    ip.ip_token AS ip,
    dispositivos,
    transicoes,
    transicoes_entre_dispositivos,
    rapidas_60min,
    round(
        100.0 * rapidas_60min /
        CASE
            WHEN transicoes_entre_dispositivos = 0
            THEN 1
            ELSE transicoes_entre_dispositivos
        END,
        2
    ) AS percentual_rapidas

ORDER BY percentual_rapidas DESC, rapidas_60min DESC
LIMIT 15;


// ===== TRECHO 055 | parágrafo Word 3702 | preformatado =====
MATCH (ip:EnderecoIP)<-[:ORIGINOU_DE]-(s:Sessao)
      -[:UTILIZOU]->(d:Dispositivo)

WITH ip, s, d
ORDER BY ip.ip_token, s.iniciada_em, s.sessao_id

WITH ip,
     count(DISTINCT d) AS dispositivos,
     collect({
         device: d.device_id,
         instante: s.iniciada_em
     }) AS eventos

WHERE dispositivos > 20

UNWIND range(1, size(eventos) - 1) AS i

WITH
    eventos[i - 1] AS anterior,
    eventos[i] AS atual

WITH
    anterior,
    atual,
    duration.inSeconds(
        anterior.instante,
        atual.instante
    ).seconds / 60.0 AS minutos

WHERE anterior.device <> atual.device

RETURN
    count(*) AS transicoes_entre_dispositivos,

    sum(CASE WHEN minutos >= 0 AND minutos <= 15
        THEN 1 ELSE 0 END) AS ate_15min,

    sum(CASE WHEN minutos >= 0 AND minutos <= 30
        THEN 1 ELSE 0 END) AS ate_30min,

    sum(CASE WHEN minutos >= 0 AND minutos <= 60
        THEN 1 ELSE 0 END) AS ate_60min,

    round(
        100.0 * sum(
            CASE WHEN minutos >= 0 AND minutos <= 60
            THEN 1 ELSE 0 END
        ) / count(*), 2
    ) AS percentual_60min,

    sum(CASE WHEN minutos < 0
        THEN 1 ELSE 0 END) AS intervalos_negativos;


// ===== TRECHO 056 | parágrafo Word 3801 | preformatado =====
MATCH (ip:EnderecoIP)<-[:ORIGINOU_DE]-(s:Sessao)
      -[:UTILIZOU]->(d:Dispositivo)

WITH
    ip,
    count(DISTINCT d) AS dispositivos

WHERE dispositivos > 20

MATCH (ip)<-[:ORIGINOU_DE]-(s:Sessao)
      -[:UTILIZOU]->(d:Dispositivo)

RETURN
    ip.ip_token AS ip,
    s.sessao_id AS sessao_id,
    d.device_id AS dispositivo,
    s.iniciada_em AS instante

ORDER BY ip, instante, sessao_id;


// ===== TRECHO 057 | parágrafo Word 3841 | preformatado =====
MATCH (ip:EnderecoIP)<-[:ORIGINOU_DE]-(s:Sessao)
      -[:UTILIZOU]->(d:Dispositivo)

WITH ip, count(DISTINCT d) AS dispositivos
WHERE dispositivos > 20

MATCH (ip)<-[:ORIGINOU_DE]-(s:Sessao)
      -[:UTILIZOU]->(d:Dispositivo)

RETURN
    ip.ip_token AS ip,
    s.sessao_id AS sessao_id,
    d.device_id AS dispositivo,
    toString(s.iniciada_em) AS instante

ORDER BY ip, instante, sessao_id;

