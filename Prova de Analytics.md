 
# OLTP X OLAP

| Critério            | OLTP (Transacional)                                  | OLAP (Analítico)                                      |
|---------------------|------------------------------------------------------|-------------------------------------------------------|
| **Foco**            | Registro de transações individuais e atuais          | Análise de tendências, padrões e histórico            |
| **Volume de Dados** | Recupera apenas alguns registros por vez             | Processa milhares ou milhões de registros             |
| **Frequência**      | Milhares de consultas por hora                       | Execução pouco frequente por grupos menores           |
| **Nível de Detalhe**| Dados atômicos (pedidos, transações)                 | Dados **agregados** e consolidados                    |
| **Velocidade**      | Respostas em milissegundos ou poucos segundos        | Pode levar vários segundos devido à complexidade      |
• **Leitura em OLTP:** As operações de leitura são otimizadas para localizar **registros específicos** de forma rápida, geralmente para suportar funções operacionais (como verificar o status de um pedido).

• **Leitura em OLAP:** Exige a leitura de **grandes blocos de dados** para realizar varreduras extensas em tabelas de fatos e dimensões. Para otimizar esse processo, costuma-se usar formatos **colunares** (como Parquet) e técnicas de **particionamento**, que reduzem a quantidade de dados lidos (pruning) durante a consulta.

• **Agregação:** No OLTP, as agregações são raras e evitadas para não comprometer a performance transacional. Já no OLAP, a **agregação é o objetivo principal**, permitindo agrupar registros por períodos, regiões ou categorias para extrair _insights_ úteis.

**Contexto Arquitetural**

Os sistemas OLTP funcionam como as **fontes de origem** (Source of Record). Para que a análise ocorra sem sobrecarregar a operação, os dados são movidos através de processos de **ETL (Extração, Transformação e Carregamento)** para sistemas OLAP, como os **Data Warehouses**. Nestes ambientes, utiliza-se frequentemente o design de **esquema em estrela** (_star schema_), onde tabelas de fatos armazenam métricas numéricas e tabelas de dimensões armazenam dados mestres, facilitando as junções (_joins_) e agregações analíticas.

A **Modelagem Analítica Dimensional** é uma técnica de design de banco de dados otimizada para a recuperação de dados e análise em larga escala, sendo a base dos **Data Warehouses** e **Data Marts**. Diferente do modelo relacional tradicional (OLTP), ela organiza os dados de forma a facilitar o consumo por ferramentas de Business Intelligence (BI) e usuários de negócio.

Abaixo, detalho os conceitos fundamentais, boas práticas e justificativas de uso:

**1. Componentes da Modelagem Dimensional**

• **Tabelas de Fatos:** São utilizadas para armazenar números ou **métricas** relacionadas a transações ou eventos de negócio, como o preço de um produto ou a quantidade vendida.

• **Tabelas de Dimensões:** Contêm os dados mestres e cadastrais que descrevem o contexto do fato, como informações de clientes, produtos ou tempo.

• **Granularidade:** Refere-se ao nível de detalhe armazenado em uma tabela de fatos (ex: uma linha por venda por dia ou uma linha por item por minuto).

• **Chaves Substitutas (Surrogate Keys):** São chaves artificiais criadas para identificar unicamente cada linha em uma dimensão, garantindo estabilidade e performance nas junções, independentemente das chaves dos sistemas de origem.

**2. Boas Práticas e Organização**

• **Conformidade de Dimensões:** Dimensões devem ser padronizadas para que possam ser compartilhadas entre diferentes fatos em toda a organização, garantindo que "cliente" signifique a mesma coisa em todos os departamentos.

• **SCD (Slowly Changing Dimensions):** Técnica aplicada quando os atributos de uma dimensão mudam ao longo do tempo (ex: um cliente que muda de endereço), permitindo rastrear o histórico dessas alterações.

• **Métricas bem definidas:** Devem ser claras e consistentes para evitar interpretações divergentes entre as áreas de negócio.

• **Data Marts:** São subconjuntos do Data Warehouse focados em áreas específicas (Marketing, RH, Vendas). Eles oferecem **maior velocidade de acesso**, menor dependência da TI e custos de implementação reduzidos.

**3. Justificativa do Star Schema (Esquema em Estrela)**

O **Star Schema** é o design mais comum em Data Warehousing, onde uma tabela de fatos central é conectada a várias tabelas de dimensões.

**Vantagens para Leitura e BI:**

• **Simplificação de Joins:** As junções são feitas diretamente entre a fato e as dimensões, evitando cadeias complexas de relacionamento.

• **Performance:** É otimizado para consultas **OLAP**, que buscam e processam milhares ou milhões de registros para identificar tendências e padrões.

• **Clareza para o Usuário:** A estrutura é intuitiva, facilitando a navegação de usuários de negócio que utilizam ferramentas de self-service BI.

**4. Impactos na Performance e Clareza**

• **Granularidade:** Uma granularidade muito alta (muito detalhe) aumenta o volume de dados e pode impactar a performance, mas permite análises mais profundas. Uma granularidade baixa (dados agregados) é mais rápida, mas limita a capacidade de detalhamento (_drill-down_).

• **Joins:** Em modelos mal projetados, o excesso de junções complexas degrada a performance das consultas. No Star Schema, a estrutura denormalizada das dimensões reduz a necessidade de múltiplos joins, tornando a execução das queries mais eficiente.

**Common Table Expressions (CTEs)**

As CTEs (definidas pela cláusula `WITH`) são conjuntos de resultados temporários que existem apenas durante a execução de uma única query. Elas funcionam como "tabelas auxiliares" que organizam o código.

**Por que são preferíveis em lógicas complexas?**

• **Legibilidade:** Permitem decompor uma lógica densa em blocos lógicos menores e nomeados, tornando o código mais fácil de ler e manter.

• **Reuso:** Você pode referenciar a mesma CTE múltiplas vezes dentro da query principal.

• **Depuração:** Facilita testar partes isoladas da transformação antes de chegar ao resultado final

O processo de **ETL/ELT orientado ao consumo** foca em transformar dados brutos em ativos estratégicos prontos para uso por analistas e cientistas de dados. Enquanto o **ETL** (Extração, Transformação e Carregamento) transforma os dados antes do destino, o **ELT** (Extração, Carregamento e Transformação) carrega os dados brutos e utiliza o poder de processamento do destino (como Cloud Data Warehouses) para a transformação.

**1. Critérios de Escolha: ETL vs. ELT**

A decisão entre os modelos depende do equilíbrio entre quatro pilares principais:

• **Governança:** O ETL é preferido para **dados sensíveis** (como LGPD), permitindo transformações antes do armazenamento. Já o ELT favorece a **linhagem e auditoria**, mantendo os dados originais disponíveis na Raw Zone para reprocessamento.

• **Latência:** O ELT costuma ser mais rápido no carregamento inicial, eliminando a espera pela pré-transformação.

• **Custo:** O ELT aproveita a **escalabilidade da nuvem** e modelos de "pague pelo uso", enquanto o ETL pode exigir infraestrutura dedicada e cara.

• **Acoplamento:** O ELT tem maior acoplamento com o mecanismo de consulta (ex: BigQuery, Snowflake), pois as transformações ocorrem dentro dele via SQL.




--------------------------------------------------------------------------------

**2. Fluxos Típicos em Camadas**

A organização por zonas evita que o repositório se torne um "pântano de dados" (Data Swamp). O fluxo padrão segue estas etapas:

1. **Ingestão (Transient/Raw Zone):** Dados brutos chegam de fontes como APIs ou Logs e são armazenados sem modificação para garantir fidelidade.

2. **Padronização e Validação (Trusted Zone):** Os dados são limpos (remoção de nulos e duplicatas) e padronizados (formatos de data e moeda). Aqui, os dados tornam-se a **Source of Truth** (Fonte da Verdade).

3. **Publicação e Exposição (Refined Zone):** Dados enriquecidos, agregados e modelados (como em **Star Schema**) são disponibilizados para ferramentas de BI e dashboards.

--------------------------------------------------------------------------------

**3. Estratégias de Carga: Completa vs. Incremental**

A escolha da carga afeta a eficiência do pipeline e a capacidade de recuperação:

• **Carga Completa (Full Load):** Todo o conjunto de dados é substituído. É mais simples, porém cara e lenta para grandes volumes.

• **Carga Incremental:** Apenas dados novos ou alterados são processados.

    ◦ **Marcação de Progresso:** Utiliza chaves como `data_atualizacao` ou `id` para identificar onde a carga anterior parou.
    

    ◦ **Idempotência:** É a garantia de que reexecutar o pipeline para o mesmo período não gerará dados duplicados ou inconsistentes, algo vital para o **reprocessamento isolado**.

--------------------------------------------------------------------------------

**4. Pontos de Controle antes do Consumo**

Para garantir a confiabilidade, o engenheiro de analytics deve implementar travas de segurança (Data Quality):

• **Validação de Schema:** Garantir que as colunas e tipos de dados não mudaram inesperadamente.

• **Integridade e Unicidade:** Verificar se campos obrigatórios estão preenchidos e se há registros duplicados (Taxa de Unicidade).

• **Fail Fast:** Implementar fluxos de **quarentena** que bloqueiam a publicação na Refined Zone se os indicadores de qualidade não forem atingidos.

• **Observabilidade:** Gerar evidências, logs estruturados e alertas caso o pipeline falhe ou a latência exceda o SLA acordado

# Orquestração de Pipelines Analíticos

A **orquestração de pipelines analíticos** é o processo de automatizar e organizar o fluxo entre tarefas, coordenando todas as etapas de desenvolvimento, processamento e entrega de dados. Ela garante que os dados se movam de forma fluida e confiável entre as camadas **Raw**, **Trusted** e **Refined**, gerenciando a complexidade das dependências e falhas.

Abaixo, detalho os **pilares técnicos** e as **estratégias de preparação para orquestração**.

---

## 1. Pilares Técnicos da Orquestração

Para garantir a robustez de um pipeline, o orquestrador deve gerenciar:

- **Dependências**  
  Define a ordem lógica de execução  
  _Exemplo: a tabela de Dimensão deve ser atualizada antes da tabela de Fatos._

- **Retries e Backoff**  
  Mecanismos de tentativas automáticas após uma falha, muitas vezes com intervalos crescentes (*backoff*) para evitar sobrecarga no sistema de origem.

- **Paralelismo**  
  Capacidade de executar tarefas independentes simultaneamente, otimizando o tempo total de processamento.

- **Timeouts**  
  Definição de limites de tempo para a execução de uma tarefa, evitando que processos travados consumam recursos indefinidamente.

---

## 2. Orquestração Nativa vs. Fluxos Multi-serviço

A escolha da ferramenta depende da complexidade do ambiente:

- **Orquestração Nativa**  
  Geralmente embutida em ferramentas específicas de ETL  
  _Exemplos: agendamento do AWS Glue ou Oozie no Hadoop._  
  É ideal para pipelines simples dentro do mesmo ecossistema.

- **Fluxos Multi-serviço**  
  Utilizam orquestradores dedicados, como **Apache Airflow** ou **AWS Step Functions**, para gerenciar fluxos que envolvem múltiplas tecnologias e lógica condicional complexa.  
  _Exemplo: um fluxo que inicia com um crawler, executa um job Spark e termina atualizando um dashboard no QuickSight._

---

## 3. Reprocessamento Isolado e Idempotência

Uma das competências mais críticas na engenharia de analytics é o planejamento de reprocessamentos:

- **Evitar o Rerun Completo**  
  O pipeline deve ser desenhado para permitir o reprocessamento apenas de etapas específicas que falharam ou que precisam de correção.

- **Idempotência**  
  Garantia de que reexecutar uma etapa para o mesmo período de tempo produzirá o mesmo resultado, sem duplicar dados ou gerar inconsistências.

- **Marcadores de Progresso**  
  Uso de *bookmarks* ou chaves de controle para identificar exatamente onde o processamento parou, permitindo cargas incrementais eficientes.

---

## 4. Integrações e Notificações

Um orquestrador moderno atua como o **“cérebro” do ecossistema**:

- **Conectividade**  
  Integra-se nativamente com motores de processamento (Spark, Hive), bancos de dados (Redshift) e ferramentas de ingestão (Kafka).

- **Observabilidade e Alertas**  
  Gera evidências e notificações automáticas em caso de erro ou atraso no **SLA (Service Level Agreement)**, garantindo transparência para as áreas usuárias.

---

## Resumo de Preparação

| Conceito            | Foco para a Prática                                                                 |
|---------------------|-------------------------------------------------------------------------------------|
| Lógica Condicional  | Usar fluxos multi-serviço quando a próxima etapa depende do resultado da anterior. |
| Gestão de Falhas    | Configurar retries adequados para lidar com instabilidades temporárias de rede/API.|
| Pontos de Controle  | Validar a qualidade do dado antes de permitir que o orquestrador publique para consumo. |
## 6. Processamento Distribuído (Visão Aplicada)

O processamento distribuído, liderado por frameworks como o **Apache Spark**, permite lidar com Big Data através do processamento em memória e execução paralela em clusters.

### Conceitos Essenciais

- **Transformações vs. Ações**  
  Transformações (ex: `map`, `filter`) criam novos RDDs e utilizam **avaliação preguiçosa (lazy evaluation)**, ou seja, só são executadas quando uma Ação (ex: `count`, `collect`) é chamada.

- **Plano Lógico e Plano Físico**  
  O **Driver Program** coordena a execução e converte o código em um **DAG (Grafo Acíclico Direcionado)** para otimizar o plano de execução antes de enviá-lo aos **Workers**.

### Práticas de Otimização

- **Pushdown**  
  Aplicar filtros o mais cedo possível para reduzir o volume de dados processados.

- **Particionamento**  
  Dividir os dados em partes menores para melhorar o desempenho e a escalabilidade.

- **Gargalos Comuns**  
  O **Shuffle** (redistribuição de dados entre nós) é o gargalo mais caro devido ao uso intensivo de rede e disco.  
  Deve-se evitar operações como `groupByKey` em favor de `reduceByKey`.

---

## 7. Qualidade de Dados (Data Quality)

A qualidade é a base para decisões assertivas; dados ruins podem custar de **15% a 25% da receita anual** de uma empresa.

### Tipos de Regras (6 Dimensões)

- **Precisão**: dados corretos  
- **Integridade**: ausência de campos faltantes  
- **Consistência**: uniformidade entre sistemas  
- **Atualidade**: dados recentes  
- **Unicidade**: ausência de duplicatas  
- **Conformidade**: aderência a padrões e regulamentos

### Integração e Fluxos

- Validar os dados **antes** de publicá-los na camada de consumo (*fail-fast*).
- Utilizar **fluxos de quarentena** para isolar dados reprovados.

### Métricas de Qualidade

- Taxa de Completude  
- Taxa de Acuracidade  
- Taxa de Duplicação  

Essas métricas ajudam a monitorar continuamente a saúde do **Data Lake**.

---

## 8. Governança, Catálogo e Segurança

A governança transforma dados brutos em **ativos estratégicos** por meio de processos e padrões bem definidos.

### Metadados Centralizados

- Ferramentas como **AWS Glue Catalog** ou **Apache Atlas** permitem catalogar tabelas, tipos e partições.
- Desacoplam a camada física da lógica de consumo.

### Controles de Acesso

- Uso de **IAM Roles** para conceder acesso granular (por banco ou tabela) e temporário.
- Elimina a necessidade de credenciais estáticas.

### Boas Práticas

- Padronização de nomenclatura.
- Documentação clara, como **Dicionário de Dados**, para evitar silos de informação.

---

## 9. Observabilidade e Operação

Observabilidade é a capacidade de entender o estado interno de um sistema através de suas saídas.

### Os 3 Pilares da Observabilidade

1. **Logs**  
   Registros cronológicos de eventos para análise e debug.

2. **Métricas**  
   Indicadores numéricos (latência, erros, throughput) usados em dashboards e alertas.

3. **Tracing**  
   Rastreia o caminho de uma requisição entre múltiplos serviços.

### Operação

- Uso de **IDs de correlação** para rastrear execuções ponta a ponta.
- Realização de **post-mortems objetivos** após incidentes para prevenir recorrências.

---

## 10. FinOps Aplicado a Analytics

O foco de **FinOps** é reduzir gastos desnecessários sem comprometer a performance.

### Estratégias Principais

- **Redução de Leitura**  
  Uso estratégico de particionamento e *partition pruning* reduz o volume de dados escaneados, impactando diretamente os custos de ferramentas como **Athena** ou **Redshift Spectrum**.

- **Gestão de Arquivos**  
  Evitar *small files* por meio de **compactação em batch**, otimizando I/O e custos de processamento.

- **Gestão de Recursos**  
  Dimensionar corretamente clusters (instâncias *spot* vs. *reservadas*) e desligar cargas ociosas.

---

## 11. Colaboração e Versionamento

A engenharia de dados moderna adota práticas consolidadas de desenvolvimento de software.

### Boas Práticas

- **Fluxos com Git**  
  Todo código de pipeline, modelagem e infraestrutura deve ser versionado.

- **Revisão de Código (Pull Requests)**  
  Melhora a qualidade, reduz regressões e dissemina conhecimento entre o time.

- **Validações Automatizadas**  
  Integração de testes de *lint* e checagens automáticas de schema em pipelines de **CI/CD**.

---

## 12. Exercícios Práticos Recomendados

Para consolidar os conhecimentos apresentados, recomenda-se:

1. **Modelagem**  
   Criar um **Star Schema** para um domínio de vendas, definindo granularidade e chaves substitutas.

2. **SQL**  
   Escrever queries com **CTEs** e analisar o plano de execução para identificar *scans* desnecessários.

3. **Data Quality**  
   Implementar validações de `not_null` e `unique` em um pipeline, gerando alertas em caso de falha.

4. **Orquestração**  
   Configurar um fluxo com **retries** e dependências entre camadas  
   *(Raw → Trusted → Refined)*.

## Star Schema vs. Snowflake Schema

**Star Schema** e **Snowflake Schema** são **técnicas de modelagem de dados para Data Warehouses**, tendo como principal diferença o nível de **normalização**.

- O **Star Schema** utiliza **dimensões desnormalizadas**, priorizando **performance de consulta** e **simplicidade para análise**.
- O **Snowflake Schema** utiliza **dimensões normalizadas**, reduzindo **redundância de dados** e aumentando a **integridade**.

De forma geral, o **Star Schema** é mais indicado para ferramentas de BI como **Power BI**, enquanto o **Snowflake Schema** se adapta melhor a **dados complexos e hierárquicos**.

---

## Principais Diferenças

### Estrutura
- **Star Schema:**  
  Possui uma **tabela fato central** conectada diretamente às **tabelas de dimensão**.
- **Snowflake Schema:**  
  As dimensões são **normalizadas** em múltiplas **sub-dimensões relacionadas**.

### Performance
- **Star Schema:**  
  Oferece **melhor desempenho** em consultas devido ao menor número de *joins*.
- **Snowflake Schema:**  
  Pode apresentar **consultas mais lentas**, pois exige mais *joins* para recuperar os dados.

### Armazenamento
- **Star Schema:**  
  Consome **mais espaço**, devido à redundância causada pela desnormalização.
- **Snowflake Schema:**  
  É **mais eficiente em armazenamento**, já que a normalização reduz a duplicação de dados.

### Complexidade
- **Star Schema:**  
  Mais **simples de projetar, entender e consultar**.
- **Snowflake Schema:**  
  Mais **complexo de manter**, porém **mais fácil de atualizar** quando há mudanças nas dimensões.

---

## Quando Usar Cada Um

### ⭐ Star Schema
Utilize quando:
- O foco for **dashboards de BI**
- Houver necessidade de **consultas rápidas e ad-hoc**
- **Simplicidade e performance** forem prioridades

### ❄️ Snowflake Schema
Utilize quando:
- **Integridade dos dados** for crítica
- O **espaço de armazenamento** for uma restrição
- Os dados possuírem **estruturas complexas e hierárquicas**

## Data Mesh 

- **Dados como produto** usar o mesmos princípios de engenharia de software
-  **Governança federada** uma área central como responsável pelos metadados 
-  **Domínio** cada área de negócio é responsável 
- **Self Service** 
- Desafios: Dificuldade em garantir a qualidade de dados devido à descentralização
- Dados como produto: Os dados devem ser gerenciados e entregue com a mesma atenção de engenharia de software.
- Vantagens: Melhoria na escalabilidade e agilidade, permitindo que as equipes se adaptem rapidamente as mudanças de requisitos. 
- Cada domínio é responsável elos seus próprios dados, promovendo autonomia e propriedade
-

> **No Hadoop, o Master coordena e os Slaves executam — tanto no storage quanto no processamento.**
> A arquitetura master/slave do Hadoop, essencial para big data, utiliza um nó mestre (Master) para gerenciar metadados e coordenar tarefas, enquanto múltiplos nós escravos (Slaves/Workers) armazenam dados (HDFS) e processam computações (MapReduce/YARN) em hardware comum

| Hadoop On-Prem | AWS                 |
| -------------- | ------------------- |
| NameNode       | S3 (gerenciado)     |
| DataNode       | S3                  |
| YARN           | Glue / EMR / Athena |
| Master/Slave   | Desacoplado         |

**AWS Glue Job Bookmark** é um recurso da ferramenta AWS Glue projetado para rastrear o estado de execução de um job de ETL (Extração, Transformação e Carregamento). Ele funciona como um mecanismo de persistência que mantém a **marcação de progresso** entre as execuções de um pipeline.

Abaixo, detalho o funcionamento e a importância desse recurso com base nos conceitos de engenharia presentes nas fontes:

**1. Suporte a Cargas Incrementais**

A principal função do Job Bookmark é facilitar a implementação de **cargas incrementais**. Em vez de processar toda a massa de dados em cada execução (o que seria uma carga completa), o Glue utiliza o bookmark para identificar apenas os novos dados que chegaram desde a última execução bem-sucedida.

**2. Marcação de Progresso e Estado**

O recurso atua registrando metadados sobre os objetos ou registros já processados. Isso é essencial para:

• **Evitar Duplicidade:** Garante que o mesmo dado não seja processado e carregado novamente, mantendo a integridade na camada de destino.

• **Idempotência:** Permite que o pipeline seja reexecutado de forma segura, garantindo que o resultado final seja consistente mesmo após falhas parciais.

**3. Eficiência Operacional e Reprocessamento**

O uso de bookmarks permite o planejamento de **reprocessamentos isolados**. Se houver uma falha em uma etapa específica do pipeline, o engenheiro pode utilizar o estado salvo para retomar o trabalho sem a necessidade de um "rerun" completo de todo o histórico de dados, o que otimiza o tempo e reduz o esforço computacional.

Lidar com o problema de **small files** (arquivos pequenos) é uma prática essencial de **FinOps** e processamento distribuído, pois o excesso de fragmentação sobrecarrega a gestão de metadados e degrada o desempenho de motores de consulta como Spark e Athena.

Abaixo estão as estratégias baseadas nas fontes para mitigar esse gargalo:

**1. Compactação (Compaction)**

A técnica de compactação consiste em consolidar diversos arquivos minúsculos em arquivos maiores e mais eficientes para o sistema de arquivos.

• **AWS S3DistCp:** No ecossistema AWS, a ferramenta **S3DistCp** é especificamente recomendada para mover e agrupar grandes volumes de arquivos pequenos entre buckets S3 ou para o HDFS, reduzindo a sobrecarga de leitura.

• **Merge em Jobs:** Durante os processos de ETL/ELT, é recomendada a inclusão de etapas de reprocessamento que façam o "merge" desses arquivos antes de publicá-los em camadas de consumo, como a **Refined Zone**.

**2. Estratégia de Particionamento e Pruning**

O particionamento incorreto é uma das causas primárias de "small files".

• **Evitar Over-partitioning:** Deve-se particionar os dados (por exemplo, por data ou negócio) apenas quando houver volume suficiente para justificar a divisão. Particionar dados de baixo volume por granularidades muito finas (como minutos ou IDs únicos) gera milhares de pastas com arquivos minúsculos.

• **Pruning:** O particionamento correto permite o **partition pruning** (poda de partição), onde o motor de busca ignora partições desnecessárias, reduzindo drasticamente o I/O e o custo por consulta, desde que os arquivos dentro das partições tenham o tamanho ideal


**3.Glue Workflow**

- Usar para pipelines ETL e Glue e athena com uma simplicidade maior

**4.Data Viz**

- Bolha para 3 variáveis e dispersão para 2.  

# 1️⃣ Modelagem **OLTP** (Transacional)

### 🎯 Objetivo

- Muitas escritas
    
- Baixa latência
    
- Consistência
- ## 🛠 Serviços AWS

- **Amazon RDS** (Postgres, MySQL, SQL Server)
    
- **Aurora**
# 2️⃣ Modelagem **OLAP** (Analytics / BI)

### 🎯 Objetivo

- Leitura pesada
    
- Agregações
    
- Histórico
- ## 🛠 Serviços AWS

- **Athena**
    
- **Redshift**
    
- **Glue Catalog**
    
- **S3 (Data Lake)**
Enunciado: Considere duas tabelas, 'transacoes' e 'clientes'. A tabela 'transacoes' contém informações sobre as transações financeiras dos clientes, e a tabela 'clientes' contém informações de clientes. 

Preencha as lacunas da consulta ao lado que calcula a *quantidade total de transações por cliente* e o *valor total de transações por cliente*, porém o cálculo precisa ser feito apenas os clientes que realizaram mais de 5 transações. A consulta precisa trazer o id do cliente, seu nome e os valores requeridos. Assuma que há um id único para cada cliente único id para as transações.
Preencha as lacunas na consulta ao lado:
#### Tabelas:
•*sql
-- Tabela transacoes
CREATE TABLE transacoes (
id INT, 
cliente id INT, 
valor DECIMAL (10, 2), 
data DATE
-- Tabela clientes
CREATE TABLE clientes
id INT, 
nome VARCHAR(100)
); 


select 
c.id,
c.nome,
count(t.id) as qtd_transacoes_clients,
sum(t.valor) as total_transacoes_clients
from 
clientes c 
join transacoes t on t.cliente_id = c.id
group by 
c.id, 
c.nome
having count(t.id) > 5 

Transações ACID são um conjunto de propriedades (Atomicidade, Consistência, Isolamento, Durabilidade) que garantem a fiabilidade, integridade e consistência dos dados em sistemas de banco de dados, especialmente durante falhas 

• **ETL na AWS:** S3 com dados brutos, Glue Job para transformação das camadas, athena para leitura 

• **ELT na AWS:**  S3 com dados brutos, como load Crawler ou Athena direto no S3 e transformação no Athena.

| Feature    | DynamicFrame (AWS Glue specific)                   | PySpark DataFrame (Apache Spark native) |
| ---------- | -------------------------------------------------- | --------------------------------------- |
| **Schema** | Flexible, schema-on-read, handles inconsistencies. | Requires a fixed, set schema.           |

|Tipo|Estrutura|Exemplos|
|---|---|---|
|Estruturado|Schema fixo|SQL, CSV, Excel, Parquet|
|Semi-estruturado|Schema flexível|JSON, YAML, logs|
|Não estruturado|Sem schema|Imagem, vídeo, PDF|
