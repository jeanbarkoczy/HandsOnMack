# Documentação da Arquitetura de Big Data

## Descrição Geral
A arquitetura foi desenvolvida para processar e analisar grandes volumes de dados em um sistema robusto, escalável e baseado em serviços da AWS. Ela é estruturada em camadas funcionais, cada uma com responsabilidades bem definidas, garantindo um fluxo de dados eficiente desde a ingestão até a entrega de insights.

---

## Componentes da Arquitetura

### **1. Camada de Fonte (Source System)**
- **Suspe (BASE)** e **ERP Empresa**: Sistemas que geram os dados de entrada. Incluem informações estruturadas e não estruturadas relevantes para análises de negócios.
- **MSK (Managed Streaming for Apache Kafka)**: Responsável pela ingestão de dados em tempo real, garantindo a entrega ordenada e resiliente de eventos.

---

### **2. Camada de Aquisição de Dados (Data Acquisition Layer)**
- **Amazon EMR**:
  - Processa grandes volumes de dados históricos utilizando Python.
  - Executa transformações iniciais e transfere dados para o armazenamento no S3 Bronze.
- **Amazon Kinesis**:
  - Garante o processamento contínuo de dados em tempo real.
  - Conecta-se com o Lambda para processamento rápido.
- **AWS Lambda**:
  - Executa funções serverless para transformar dados rapidamente em tempo real antes de armazená-los.

---

### **3. Camada de Armazenamento (Storage Layer)**
- **S3 Bronze**: Contém dados brutos, armazenados sem transformação para manter a integridade e rastreabilidade.
- **S3 Silver**: Armazena dados transformados e limpos, prontos para análises intermediárias.
- **S3 Gold**: Dados consolidados e otimizados em formato Parquet para análises avançadas.
- **Amazon Redshift (Gold)**:
  - Repositório final para dados organizados no formato Star Schema.
  - Ideal para consultas analíticas complexas e relatórios interativos.

---

### **4. Camada de Batch (Batch Layer)**
- **AWS Glue**:
  - Realiza operações de ETL (Extract, Transform, Load) em dados batch.
  - Organiza e cataloga os dados das camadas S3 no Glue Data Catalog, facilitando o acesso via Athena.

---

### **5. Camada de Servicing (Serving Layer)**
- **API Gateway**: Proporciona uma interface para acesso a dados e análises, permitindo integrações com outros sistemas ou aplicações.
- **Amazon Athena**:
  - Permite consultas interativas diretamente nos dados armazenados no S3 Gold.
  - Utiliza o Glue Data Catalog para referenciar os metadados.
- **Amazon QuickSight**:
  - Ferramenta de visualização de dados e geração de dashboards.
  - Conecta-se ao Redshift para fornecer relatórios dinâmicos e insights estratégicos.

---

### **6. Camada de Monitoramento (Monitoring Layer)**
- **Amazon CloudWatch**:
  - Monitora e registra logs, métricas e eventos do sistema.
  - Ajuda na identificação de falhas ou gargalos, permitindo uma operação confiável.

---

## Fluxo de Dados na Arquitetura
1. **Ingestão**:
   - Dados brutos são capturados de sistemas fontes (Suspe e ERP) e transmitidos para o MSK ou diretamente ao S3 Bronze via EMR.
   - Eventos em tempo real passam pelo Kinesis e são transformados pelo Lambda.
   
2. **Transformação e Armazenamento**:
   - Dados batch são processados no EMR e catalogados no Glue, sendo armazenados em S3 Bronze, Silver e Gold.
   - Dados finalizados no S3 Gold são formatados em Parquet ou transferidos para o Redshift.

3. **Consulta e Análise**:
   - Ferramentas como Athena e QuickSight consomem dados estruturados no S3 e Redshift.
   - APIs desenvolvidas no API Gateway facilitam o acesso programático.

4. **Monitoramento**:
   - Toda a operação é acompanhada por logs e alertas configurados no CloudWatch.

---

## Benefícios da Arquitetura
- **Modularidade**: Cada camada é independente, facilitando manutenção e upgrades.
- **Escalabilidade**: Suporta grandes volumes de dados e cresce conforme as demandas.
- **Eficiência**: Otimização de armazenamento em múltiplas camadas (Bronze, Silver, Gold).
- **Flexibilidade**: Combina fluxos batch e streaming para atender a diferentes necessidades analíticas.
- **Governança**: Metadados centralizados no Glue garantem organização e rastreabilidade.

---

