# Documentação: CI/CD Pipeline

## Visão Geral

Este repositório implementa um pipeline CI/CD usando GitHub Actions para:

1. Executar linting e testes unitários (Continuous Integration - CI).
2. Realizar o deploy de infraestrutura e aplicação em serviços AWS (Continuous Deployment - CD).

---

## Estrutura do Repositório

```
.
├── .github/
│   └── workflows/
│       └── CI-CD-PIPELINE.yml  # Arquivo do pipeline
├── requirements.txt            # Dependências do Python
├── tests/                      # Pasta para testes unitários
│   └── test_app.py
├── infrastructure.yaml         # Template para infraestrutura
└── api-definition.json         # Definição da API Gateway
```

---

## Pipeline

### Localização

O arquivo do pipeline está localizado em `.github/workflows/CI-CD-PIPELINE.yml`.

### Gatilhos

- **Push** para a branch `main`
- **Pull requests**

### Jobs

#### 1. **Continuous Integration (CI)**

Executa as seguintes etapas:

- **Checkout do código**
- Configuração do ambiente Python (versão 3.9)
- Instalação das dependências listadas em `requirements.txt`
- Execução de linting com `flake8`
- Execução de testes unitários com `pytest`

#### 2. **Continuous Deployment (CD)**

Executa após a conclusão do job de CI:

- **Deploy de infraestrutura** usando AWS CloudFormation (`infrastructure.yaml`)
- **Deploy da aplicação** em um cluster EMR e configuração de API Gateway
- **Notificação** de sucesso via Amazon SNS

---

## Dependências

As dependências para o projeto estão listadas em `requirements.txt`:

```plaintext
flask==2.3.3
boto3==1.28.57
pytest==7.4.0
flake8==6.1.0
requests==2.31.0
```

Instale-as com:

```bash
pip install -r requirements.txt
```

---

## Testes Unitários

Os testes estão localizados na pasta `tests/`.

### Exemplo de teste (`tests/test_app.py`):

```python
import pytest
import requests

def test_sample():
    response = requests.get('https://example.com')  # Substitua pelo endpoint real
    assert response.status_code == 200

def test_addition():
    assert 1 + 1 == 2
```

Execute os testes com:

```bash
pytest tests/
```

---

## Deploy de Infraestrutura

O arquivo `infrastructure.yaml` define a infraestrutura necessária para a aplicação.

### Exemplo de recurso:

```yaml
Resources:
  MyS3Bucket:
    Type: 'AWS::S3::Bucket'
    Properties:
      BucketName: my-app-bucket
```

Realize o deploy com o comando:

```bash
aws cloudformation deploy \
  --template-file infrastructure.yaml \
  --stack-name my-app-stack \
  --capabilities CAPABILITY_NAMED_IAM
```

---

## Definição da API Gateway

O arquivo `api-definition.json` especifica a API Gateway para a aplicação.

### Exemplo:

```json
{
  "openapi": "3.0.1",
  "info": {
    "title": "API for HandsOn",
    "description": "API for project HandsOn",  
    "version": "1.0.0"
  },
  "paths": {
    "/hello": {
      "get": {
        "summary": "Returns a greeting",
        "responses": {
          "200": {
            "description": "A greeting message",
            "content": {
              "application/json": {
                "example": {
                  "message": "Hello, World!"
                }
              }
            }
          }
        }
      }
    }
  }
}
```

Implemente a API com:

```bash
aws apigatewayv2 import-api --body file://api-definition.json
```

---

## Notificações

O pipeline inclui notificação de sucesso do deploy usando Amazon SNS:

```bash
aws sns publish \
  --topic-arn ${{ secrets.SNS_TOPIC_ARN }} \
  --message "Deployment completed successfully!"
```

Certifique-se de configurar o tópico SNS e armazenar o ARN como segredo no GitHub.

---

## Ajustes e Configurações

- Atualize os nomes dos recursos no arquivo `infrastructure.yaml` conforme a necessidade.
- Substitua `https://example.com` pelos endpoints reais nos testes.
- Certifique-se de configurar os segredos no GitHub (ex.: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`).


