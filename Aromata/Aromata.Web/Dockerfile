FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine3.20-arm64v8 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine3.20-arm64v8 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Aromata/Aromata.Web/Aromata.Web.csproj", "Aromata/Aromata.Web/"]
COPY ["Aromata/Aromata.Web.Client/Aromata.Web.Client.csproj", "Aromata/Aromata.Web.Client/"]
COPY ["Aromata/Aromata.Domain/Aromata.Domain.csproj", "Aromata/Aromata.Domain/"]
COPY ["Aromata/Aromata.Application/Aromata.Application.csproj", "Aromata/Aromata.Application/"]
COPY ["Aromata/Aromata.Infrastructure/Aromata.Infrastructure.csproj", "Aromata/Aromata.Infrastructure/"]
COPY ["Aromata/ServiceDefaults/ServiceDefaults.csproj", "Aromata/ServiceDefaults/"]
COPY ["Directory.Build.props", "Directory.Build.props"]
COPY ["Directory.Packages.props", "Directory.Packages.props"]
RUN dotnet restore "Aromata/Aromata.Web/Aromata.Web.csproj" -v n
COPY . .
WORKDIR "/src/Aromata/Aromata.Web"
RUN dotnet build "Aromata.Web.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "Aromata.Web.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Aromata.Web.dll"]
