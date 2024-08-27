IaC - Infrastructure as Code 🚧 Deploy da API na AWS com Terraform

💻 Sobre o Projeto

Este projeto usa Terraform para montar a infraestrutura na AWS para a API api_comment. A configuração cobre tudo, desde a criação de uma VPC e subnets públicas, até o setup de um Internet Gateway, um Application Load Balancer (ALB), um repositório ECR e um cluster ECS. Além disso, tudo é monitorado com CloudWatch.


💪 Funcionalidades

    Cria VPC: Monta uma Virtual Private Cloud com subnets públicas.
    Cria Subnets: Define subnets públicas em zonas diferentes.
    Cria Internet Gateway: Dá acesso à Internet para a VPC.
    Cria Tabela de Rotas: Configura o tráfego externo para o Internet Gateway.
    Cria ECR Repository: Prepara um repositório no Amazon Elastic Container Registry para as imagens Docker.
    Cria ALB: Configura um Application Load Balancer para distribuir o tráfego.
    Cria Security Groups: Define regras de segurança para as instâncias.
    Cria ECS Cluster e Serviço: Prepara um cluster ECS e um serviço para rodar a API.
    Métricas e Alarmes CloudWatch: Monitora o uso da CPU e a disponibilidade da API.

🛠 Pré-requisitos

    Git: Para clonar o repositório.
    
    Terraform: Para criar e gerenciar a infraestrutura.

🎲 Instalação

    Clone o repositório


git clone https://github.com/jeffersonqrz12/api_comment.git

Entre na pasta do projeto



    cd api_comment/terraform

🚀 Deploy

    Inicialize o Terraform

  

terraform init

Veja o plano de execução



terraform plan

Aplique as mudanças



    terraform apply --auto-approve

    Obs: Os recursos serão criados na região us-east-1.

🔧 Automação com GitHub Actions

Tudo é automatizado com GitHub Actions. Sempre que há uma atualização no repositório, o GitHub Actions executa os comandos Terraform automaticamente, garantindo que sua infraestrutura esteja sempre em dia.
