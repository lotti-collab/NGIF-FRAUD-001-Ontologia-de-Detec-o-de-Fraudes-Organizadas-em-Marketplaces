// NGIF-FRAUD-001 — arquivo de RECUPERAÇÃO DOCUMENTAL
// Trechos extraídos do Word, sem validação de execução.
// Alguns trechos podem ser tentativas, consultas parciais ou versões substituídas.
// NÃO executar este arquivo inteiro automaticamente.

// ===== TRECHO 039 | parágrafo Word 2950 | preformatado =====
RETURN gds.version() AS versao_gds;


// ===== TRECHO 040 | parágrafo Word 2993 | preformatado =====
CALL gds.wcc.stream('ngif_identity_graph')
YIELD nodeId, componentId

WITH componentId,
     gds.util.asNode(nodeId) AS n

RETURN
    componentId,
    count(*) AS total_nos,

    count(CASE
        WHEN n:ContaCliente THEN 1
    END) AS contas,

    count(CASE
        WHEN n:Sessao THEN 1
    END) AS sessoes,

    count(CASE
        WHEN n:Dispositivo THEN 1
    END) AS dispositivos

ORDER BY total_nos DESC
LIMIT 15;


// ===== TRECHO 044 | parágrafo Word 3123 | preformatado =====
MATCH (source)-[r:INICIOU|UTILIZOU|ORIGINOU_DE]->(target)

WITH gds.graph.project(
    'ngif_identity_v2',
    source,
    target,
    {},
    {
        undirectedRelationshipTypes: ['*']
    }
) AS g

RETURN
    g.graphName AS grafo,
    g.nodeCount AS total_nos,
    g.relationshipCount AS total_relacionamentos;


// ===== TRECHO 045 | parágrafo Word 3146 | preformatado =====
CALL gds.wcc.stats('ngif_identity_v2')
YIELD componentCount, componentDistribution

RETURN
    componentCount AS total_componentes,
    componentDistribution AS distribuicao;


// ===== TRECHO 046 | parágrafo Word 3200 | preformatado =====
CALL gds.wcc.stream('ngif_identity_v2')
YIELD nodeId, componentId

WITH gds.util.asNode(nodeId) AS ip,
     componentId

WHERE ip:EnderecoIP
  AND componentId = 0

MATCH (ip)<-[:ORIGINOU_DE]-(s:Sessao)
      -[:UTILIZOU]->(d:Dispositivo)

MATCH (c:ContaCliente)-[:INICIOU]->(s)

RETURN
    ip.ip_token AS ip,
    count(DISTINCT d) AS dispositivos_distintos,
    count(DISTINCT c) AS contas_distintas,
    count(DISTINCT s) AS sessoes

ORDER BY dispositivos_distintos DESC,
         contas_distintas DESC
LIMIT 15;


// ===== TRECHO 047 | parágrafo Word 3267 | preformatado =====
MATCH (source)-[r:INICIOU|UTILIZOU|ORIGINOU_DE]->(target)

WHERE type(r) <> 'ORIGINOU_DE'
   OR EXISTS {
       MATCH (target)<-[:ORIGINOU_DE]-(:Sessao)
             -[:UTILIZOU]->(d:Dispositivo)
       WITH count(DISTINCT d) AS qtd_dispositivos
       WHERE qtd_dispositivos <= 20
       RETURN 1
   }

WITH gds.graph.project(
    'ngif_identity_v3',
    source,
    target,
    {},
    {
        undirectedRelationshipTypes: ['*']
    }
) AS g

RETURN
    g.graphName AS grafo,
    g.nodeCount AS total_nos,
    g.relationshipCount AS total_relacionamentos;


// ===== TRECHO 048 | parágrafo Word 3295 | preformatado =====
CALL gds.wcc.stats('ngif_identity_v3')
YIELD componentCount, componentDistribution

RETURN
    componentCount AS total_componentes,
    componentDistribution AS distribuicao;

