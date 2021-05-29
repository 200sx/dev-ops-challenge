FROM mcr.microsoft.com/dotnet/aspnet:5.0

# Copy all dotnet published files into the container
COPY src/DevOpsChallenge.SalesApi/bin/Release/net5.0 app/
COPY entrypoint.sh app/entrypoint.sh

# Expose required ports for application apiserver/listener
EXPOSE 5000/tcp

# Environment variable - makes container run as readonly for security
ENV DOTNET_EnableDiagnostics=0
#Environment variable - bind to a higher port
ENV ASPNETCORE_URLS http://+:5000
ENV DOTNET_ENVIRONMENT Development
# Create a user for application runtime so it's not root
RUN useradd -m -d /home/appuser -s /bin/bash appuser -u 1000
RUN chown -R appuser: /app

# Create the context for application runtime and make sure it runs the required dll
USER appuser
WORKDIR /app
ENTRYPOINT ["/bin/bash", "entrypoint.sh"]