    # Usar a imagem base do Python
    FROM python:3.9-slim

    # Definir o diretório de trabalho no container
    WORKDIR /app
    
    # Copiar os arquivos de requisitos e instalá-los
    COPY requirements.txt requirements.txt
    RUN pip install --no-cache-dir -r requirements.txt
    
    # Copiar o código da aplicação para o diretório de trabalho
    COPY . .
    
    # Expor a porta em que a aplicação irá rodar
    EXPOSE 5000
    
    # Comando para rodar a aplicação
    CMD ["python", "comment.py"]