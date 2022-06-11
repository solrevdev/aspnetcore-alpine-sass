FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /source

COPY ./ ./
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=build /app ./

EXPOSE 80
ENV ASPNETCORE_URLS=http://+:80
ENTRYPOINT ["dotnet", "aspnetcore-alpine-sass.dll"]