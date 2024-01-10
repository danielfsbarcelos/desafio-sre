# metabase image
FROM metabase/metabase:latest

# porta padrao conforme documentação
EXPOSE 3000

# Comando para iniciar o Metabase
CMD ["java", "-jar", "metabase.jar"]