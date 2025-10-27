compose := "compose.yaml"

add-to-compose name:
    #!/bin/sh
    echo adding {{name}} to compose.yaml
    # Handle service setup
    sed -i '$ a \  {{name}}:' {{compose}}
    sed -i '$ a \    build: ./{{uppercamelcase(name)}}' {{compose}}
    port="$(cat compose.yaml | grep -o "     - 600" | wc -l)" && sed -i "$ a \    ports:\n     - 600${port}:80" {{compose}}
    sed -i '$ a \    environment:\n     - ConnectionStrings__DefaultConnection=server=mysql_ordre;port=3306;database={{name}}db;user=user;password=password' {{compose}}
    sed -i '$ a \    depends_on:\n     - db_{{name}}\n' {{compose}}
    # Handle database setup
    sed -i '$ a \  db_{{name}}:' {{compose}}
    sed -i '$ a \    image: mysql:8.0' {{compose}}
    sed -i '$ a \    environment:' {{compose}}
    sed -i '$ a \      MYSQL_ROOT_PASSWORD: root' {{compose}}
    sed -i '$ a \      MYSQL_DATABASE: {{name}}db' {{compose}}
    sed -i '$ a \      MYSQL_USER: user' {{compose}}
    sed -i '$ a \      MYSQL_PASSWORD: password' {{compose}}
    sed -i '$ a \    ports:\n     - 3301:3306\n' {{compose}}
    sed -i '0,/depends_on:/s//depends_on:\n     - {{name}}\n/' {{compose}}
    echo done

generate-dockerfile service_path:
    echo "# Dockerfile for .NET microservice" >> {{service_path}}/Dockerfile
    echo "FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base" >> {{service_path}}/Dockerfile
    echo "WORKDIR /app" >> {{service_path}}/Dockerfile
    echo "" >> {{service_path}}/Dockerfile
    echo "FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build" >> {{service_path}}/Dockerfile
    echo "WORKDIR /src" >> {{service_path}}/Dockerfile
    echo "COPY . ." >> {{service_path}}/Dockerfile
    echo "RUN dotnet restore" >> {{service_path}}/Dockerfile
    echo "RUN dotnet publish -c Release -o /app/publish" >> {{service_path}}/Dockerfile
    echo "" >> {{service_path}}/Dockerfile
    echo "FROM base AS final" >> {{service_path}}/Dockerfile
    echo "WORKDIR /app" >> {{service_path}}/Dockerfile
    echo "COPY --from=build /app/publish ." >> {{service_path}}/Dockerfile
    echo "ENTRYPOINT ["dotnet", "{{service_path}}.dll"]" >> {{service_path}}/Dockerfile