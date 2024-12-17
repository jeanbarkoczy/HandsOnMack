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