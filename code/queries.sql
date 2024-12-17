SELECT * FROM dim_grupo dg LIMIT 10;


-- Criação da Tabela DIM_TEMPO
CREATE TABLE DIM_TEMPO (
    ID_TEMPO SERIAL PRIMARY KEY,
    damesano VARCHAR(7) NOT NULL, -- Ano e mês no formato YYYY-MM
    ano INT NOT NULL,
    mes INT NOT NULL
);

-- Criação da Tabela DIM_ENTIDADE
CREATE TABLE DIM_ENTIDADE (
    ID_ENTIDADE SERIAL PRIMARY KEY,
    codenti INT NOT NULL, -- Código da entidade
    nome_entidade VARCHAR(255) NOT NULL -- Nome da entidade
);

-- Criação da Tabela DIM_RAMO
CREATE TABLE DIM_RAMO (
    ID_RAMO SERIAL PRIMARY KEY,
    codramo INT NOT NULL, -- Código do ramo
    nome_ramo VARCHAR(255) NOT NULL -- Nome do ramo
);

-- Criação da Tabela DIM_GRUPO
CREATE TABLE DIM_GRUPO (
    ID_GRUPO SERIAL PRIMARY KEY,
    codgrupo INT NOT NULL, -- Código do grupo econômico
    nome_grupo VARCHAR(255) NOT NULL -- Nome do grupo econômico
);


-- Populando a DIM_TEMPO
INSERT INTO DIM_TEMPO (damesano, ano, mes)
SELECT DISTINCT damesano, 
       CAST(SPLIT_PART(damesano::TEXT, '-', 1) AS INT) AS ano, 
       CAST(SPLIT_PART(damesano::TEXT, '-', 2) AS INT) AS mes
FROM ref_ses_seguros
WHERE damesano IS NOT NULL 
  AND damesano::TEXT ~ '^[0-9]{4}-[0-9]{2}$'; -- Garante que está no formato YYYY-MM



-- Populando a DIM_ENTIDADE
INSERT INTO DIM_ENTIDADE (codenti, nome_entidade)
SELECT DISTINCT CAST(FLOOR(CAST(coenti AS NUMERIC)) AS INTEGER) AS codenti,
       noenti AS nome_entidade
FROM ref_ses_cias
WHERE coenti IS NOT NULL AND TRIM(coenti) <> '' 
      AND coenti ~ '^[0-9]+(\.[0-9]+)?$'; -- Filtra apenas valores numéricos válidos



-- Populando a DIM_RAMO
INSERT INTO DIM_RAMO (codramo, nome_ramo)
SELECT DISTINCT CAST(FLOOR(CAST(coramo AS NUMERIC)) AS INTEGER) AS codramo, 
       noramo AS nome_ramo
FROM ref_ses_ramos
WHERE coramo IS NOT NULL 
  AND coramo ~ '^[0-9]+(\.[0-9]+)?$'; -- Aceita valores inteiros ou decimais

  -- Populando a DIM_GRUPO
INSERT INTO DIM_GRUPO (codgrupo, nome_grupo)
SELECT DISTINCT cogrupo AS codgrupo, nogrupo AS nome_grupo
FROM ref_grupos_economicos
WHERE cogrupo IS NOT NULL AND nogrupo IS NOT NULL;


--fato
-- Criação da Tabela FATO_SEGUROS
CREATE TABLE FATO_SEGUROS (
    ID_FATO SERIAL PRIMARY KEY,
    ID_TEMPO INT REFERENCES DIM_TEMPO(ID_TEMPO),
    ID_ENTIDADE INT REFERENCES DIM_ENTIDADE(ID_ENTIDADE),
    ID_RAMO INT REFERENCES DIM_RAMO(ID_RAMO),
    ID_GRUPO INT REFERENCES DIM_GRUPO(ID_GRUPO),
    premio_direto NUMERIC,
    premio_retido NUMERIC,
    sinistro_direto NUMERIC,
    sinistro_retido NUMERIC,
    desp_comercial NUMERIC
);


-- Inserir dados na Tabela FATO_SEGUROS
INSERT INTO FATO_SEGUROS (
    ID_TEMPO, ID_ENTIDADE, ID_RAMO, ID_GRUPO, 
    premio_direto, premio_retido, sinistro_direto, sinistro_retido, desp_comercial
)
SELECT 
    T.ID_TEMPO,
    E.ID_ENTIDADE,
    R.ID_RAMO,
    G.ID_GRUPO,
    SUM(CAST(REPLACE(S.premio_direto, ',', '.') AS NUMERIC)) AS premio_direto,
    SUM(CAST(REPLACE(S.premio_retido, ',', '.') AS NUMERIC)) AS premio_retido,
    SUM(CAST(REPLACE(S.sinistro_direto, ',', '.') AS NUMERIC)) AS sinistro_direto,
    SUM(CAST(REPLACE(S.sinistro_retido, ',', '.') AS NUMERIC)) AS sinistro_retido,
    SUM(CAST(REPLACE(S.desp_com, ',', '.') AS NUMERIC)) AS desp_comercial
FROM ref_ses_seguros S
    INNER JOIN DIM_TEMPO T ON CAST(S.damesano AS TEXT) = T.damesano
    INNER JOIN DIM_ENTIDADE E ON CAST(S.coenti AS TEXT) = CAST(E.codenti AS TEXT)
    INNER JOIN DIM_RAMO R ON CAST(FLOOR(CAST(REPLACE(S.coramo, ',', '.') AS NUMERIC)) AS INTEGER) = R.codramo
    INNER JOIN DIM_GRUPO G ON CAST(S.cogrupo AS TEXT) = CAST(G.codgrupo AS TEXT)
WHERE S.premio_direto IS NOT NULL 
   OR S.premio_retido IS NOT NULL 
   OR S.sinistro_direto IS NOT NULL
   OR S.sinistro_retido IS NOT NULL
   OR S.desp_com IS NOT NULL
GROUP BY T.ID_TEMPO, E.ID_ENTIDADE, R.ID_RAMO, G.ID_GRUPO;


---- wide table 
CREATE TABLE SES_SEGUROS_WIDE (
    diamesano           VARCHAR(7),      -- formato YYYY-MM
    ano                 INT,             -- Ano
    mes                 INT,             -- Mês
    trimestre           INT,             -- Trimestre
    ID_ENTIDADE         INT,             -- Identificador da entidade
    codenti             INT,             -- Código da entidade
    nome_entidade       VARCHAR(255),    -- Nome da entidade
    ID_GRUPO            INT,             -- Identificador do grupo
    codgrupo            INT,             -- Código do grupo
    nome_grupo          VARCHAR(255),    -- Nome do grupo
    ID_RAMO             INT,             -- Identificador do ramo
    codramo             INT,             -- Código do ramo
    nome_ramo           VARCHAR(255),    -- Nome do ramo
    premio_direto       NUMERIC,         -- Prêmio direto
    premio_de_seguros   NUMERIC,         -- Prêmio de seguros
    premio_retido       NUMERIC,         -- Prêmio retido
    premio_ganho        NUMERIC,         -- Prêmio ganho
    sinistro_direto     NUMERIC,         -- Sinistro direto
    sinistro_retido     NUMERIC,         -- Sinistro retido
    desp_com            NUMERIC,         -- Despesa comercial
    premio_emitido2     NUMERIC,         -- Prêmio emitido adicional
    premio_emitido_cap  NUMERIC,         -- Prêmio emitido CAP
    despesa_resseguros  NUMERIC,         -- Despesa de resseguros
    sinistro_ocorrido   NUMERIC,         -- Sinistro ocorrido
    receita_resseguro   NUMERIC,         -- Receita de resseguros
    sinistros_ocorridos_cap NUMERIC,     -- Sinistros ocorridos CAP
    recuperacao_sinistros NUMERIC,       -- Recuperação de sinistros
    rvne                NUMERIC,         -- RVNE
    conveniodpvat       NUMERIC,         -- Convênio DPVAT
    consorciosefundos   NUMERIC          -- Consórcios e Fundos
);




INSERT INTO SES_SEGUROS_WIDE (
    diamesano, ano, mes, trimestre, 
    ID_ENTIDADE, codenti, nome_entidade, 
    ID_GRUPO, codgrupo, nome_grupo, 
    ID_RAMO, codramo, nome_ramo, 
    premio_direto, premio_de_seguros, premio_retido, 
    premio_ganho, sinistro_direto, sinistro_retido, 
    desp_com, premio_emitido2, premio_emitido_cap, 
    sinistro_ocorrido, receita_resseguro, 
    sinistros_ocorridos_cap, recuperacao_sinistros, rvne, 
    conveniodpvat, consorciosefundos
)
SELECT 
    T.damesano AS diamesano,
    T.ano,
    T.mes,
    CEIL(T.mes / 3.0) AS trimestre, -- Calcula o trimestre
    E.ID_ENTIDADE,
    E.codenti,
    E.nome_entidade,
    G.ID_GRUPO,
    G.codgrupo,
    G.nome_grupo,
    R.ID_RAMO,
    R.codramo,
    R.nome_ramo,
    F.premio_direto,
    F.premio_direto AS premio_de_seguros, -- Ajuste duplicado se necessário
    F.premio_retido,
    F.premio_retido AS premio_ganho,
    F.sinistro_direto,
    F.sinistro_retido,
    F.desp_comercial AS desp_com,
    F.premio_direto AS premio_emitido2, -- Valores placeholder
    F.premio_direto AS premio_emitido_cap,
    F.sinistro_direto AS sinistro_ocorrido,
    0 AS receita_resseguro, -- Valores inexistentes assumidos como 0
    0 AS sinistros_ocorridos_cap, 
    0 AS recuperacao_sinistros, 
    0 AS rvne,
    0 AS conveniodpvat,
    0 AS consorciosefundos
FROM FATO_SEGUROS F
    INNER JOIN DIM_TEMPO T ON F.ID_TEMPO = T.ID_TEMPO
    INNER JOIN DIM_ENTIDADE E ON F.ID_ENTIDADE = E.ID_ENTIDADE
    INNER JOIN DIM_GRUPO G ON F.ID_GRUPO = G.ID_GRUPO
    INNER JOIN DIM_RAMO R ON F.ID_RAMO = R.ID_RAMO;
