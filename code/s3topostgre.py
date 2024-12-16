from pyspark.sql import SparkSession
from pyspark.sql.functions import col

# Inicialização da sessão Spark com o driver JDBC
try:
    spark = SparkSession.builder \
        .appName("S3 to Postgre") \
        .getOrCreate()
    print("Sessão Spark iniciada com sucesso.")
except Exception as e:
    print(f"Erro ao iniciar a sessão Spark: {e}")
    raise

# Configuração do caminho do arquivo no S3
s3_path = " - "

# Leitura dos dados CSV do S3
try:
    glue_data = spark.read \
        .format("csv") \
        .option("header", "true") \
        .option("inferSchema", "true") \
        .option("delimiter", ";") \
        .load(s3_path)

    # Exibir o schema para verificação
    glue_data.printSchema()
    print("Dados carregados com sucesso do S3.")
except Exception as e:
    print(f"Erro ao carregar os dados do S3: {e}")
    raise

# Configuração de conexão JDBC com o PostgreSQL
pg_url = "-"
pg_properties = {
    "user": "-",
    "password": "-",
    "driver": "org.postgresql.Driver"
}

# Ajuste dos tipos de dados para compatibilidade com PostgreSQL
try:
    glue_data = glue_data.withColumn("coenti", col("coenti").cast("bigint")) \
                         .withColumn("damesano", col("damesano").cast("bigint")) \
                         .withColumn("quantidade", col("quantidade").cast("bigint"))
    print("Tipos de dados ajustados para corresponder ao PostgreSQL.")
except Exception as e:
    print(f"Erro ao ajustar os tipos de dados: {e}")
    raise

# Escrita dos dados no PostgreSQL
try:
    glue_data.write \
        .format("jdbc") \
        .option("url", pg_url) \
        .option("dbtable", "raw_ses_transferenciasexternas") \
        .option("user", pg_properties["user"]) \
        .option("password", pg_properties["password"]) \
        .option("driver", pg_properties["driver"]) \
        .mode("overwrite") \
        .save()
    print("Dados transferidos com sucesso para o PostgreSQL!")
except Exception as e:
    print(f"Erro ao transferir dados para o PostgreSQL: {e}")
    raise

# Encerramento seguro da sessão Spark
finally:
    spark.stop()
    print("Sessão Spark encerrada com sucesso.")ls