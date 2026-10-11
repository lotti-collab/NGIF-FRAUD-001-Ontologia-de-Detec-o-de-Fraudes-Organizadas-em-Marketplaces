// NGIF-FRAUD-001 — arquivo de RECUPERAÇÃO DOCUMENTAL
// Trechos extraídos do Word, sem validação de execução.
// Alguns trechos podem ser tentativas, consultas parciais ou versões substituídas.
// NÃO executar este arquivo inteiro automaticamente.

// ===== TRECHO 003 | parágrafo Word 1462 | preformatado =====
CREATE CONSTRAINT cliente_id_unique IF NOT EXISTS
FOR (c:ContaCliente)
REQUIRE c.cliente_id IS UNIQUE;


// ===== TRECHO 004 | parágrafo Word 1466 | preformatado =====
CREATE CONSTRAINT sessao_id_unique IF NOT EXISTS
FOR (s:Sessao)
REQUIRE s.sessao_id IS UNIQUE;


// ===== TRECHO 005 | parágrafo Word 1470 | preformatado =====
CREATE CONSTRAINT device_id_unique IF NOT EXISTS
FOR (d:Dispositivo)
REQUIRE d.device_id IS UNIQUE;


// ===== TRECHO 006 | parágrafo Word 1476 | preformatado =====
SHOW CONSTRAINTS;


// ===== TRECHO 041 | parágrafo Word 3068 | preformatado =====
CREATE CONSTRAINT endereco_ip_token_unique IF NOT EXISTS
FOR (ip:EnderecoIP)
REQUIRE ip.ip_token IS UNIQUE;


// ===== TRECHO 058 | parágrafo Word 4181 | texto normal =====
CREATE CONSTRAINT pedido_id_unique IF NOT EXISTS
FOR (p:Pedido)
REQUIRE p.pedido_id IS UNIQUE;


// ===== TRECHO 059 | parágrafo Word 4185 | texto normal =====
CREATE CONSTRAINT restaurante_id_unique IF NOT EXISTS
FOR (r:Restaurante)
REQUIRE r.restaurante_id IS UNIQUE;

