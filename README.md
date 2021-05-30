# DevOps Challenge (.NET) Deployment Guide

## IDE Setup
This asset deployment is made to be run in a Linux/macOS environment hence may not apply to Windows developers. Also there are pecularities within the setup due to the UNIX based environment.
## Steps
1. Install the DOTNET runtime
    - Dotnet - https://dotnet.microsoft.com/download/dotnet/5.0
2. Install Docker for Desktop
    - Docker - https://docs.docker.com/docker-for-mac/install/
3. Install CLI tools for MSSQL
    ``` shell
    brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
    brew update
    brew install –no-sandbox msodbcsql mssql-tools
    ```

## Local Environment Deployment
A **docker-compose** has been provided, please look at it to understand how the microservices communicate. The below command will bring up all the required containers and place them in a network. Both services exposed on host for direct commands into database or API calls into API via POSTMAN.
```bash
docker-compose up mssql #bring up just db
docker-compose up #bring up the whole stack
```
NOTE: The docker-compose is utilised in the pipelines to pull from ECR. If you have a local image, please replace the image annotation as required. Don't commit this!

To interact with the database via CLI, the port is already exposed on the host and you can run a command like below to query the DB directly.
``` basg
sqlcmd -S localhost  -U sa -P Lolcats12# -Q "SELECT @@VERSION"
```

## Notes for the Assessor
Thanks for letting me have a go at the challenge. It was fun to learn a bit more about how dotnet applications work and tear into DLL hell for the first time. I've also been meaning to check out modern CICD tooling (I've mainly used Jenkins) as I wanted to upgrade to a more modern system implemented at work (Groovy is a pain to maintain, not as readable and there's something cool in having everything DevOps related in YAML/bash).

More onto the solution, it does the follwing;
- Pipeline Setup
    - Utilised GitHub actions and integrated with ECR as a container store, keys provided on the GitHub side for security
    - docker-compose utilised to bring up integration test environment and also allow easy local deployment
    - Pipeline tags the image version to git commit as a simple form of versioning, also tags image as latest for testing runs
    - Utilised a .gitignore file set up for dotnet projects
- Image
    - Image runs as a non-root user for security
    - Fixed swagger annotations to provide comments on swaggerdocs
    - Removed Kestrel header being sent in API payloads (read challenges section)
    - Added environmental flag to enhance security
    - Application image has a custom entrypoint in case startup tasks are required prior to runtime
- Testing Process
    - Unit tests are run prior to image building, and uses a clean build of the application
    - Integration tests are run if deployment succeeds, and uses image from ECR as source of truth
    - Code Coverage reports are generated and printed in pipeline logs (improvements highlighed below)

## Improvements and Challenges
Things to improve;
- Integration tests do run but fail due to database login failure
    - This is probably because the database doesn't have the schmas set up, if I had more time I'd have liked to learn more about how DOTNET applications can inherently set up the schemas on startup alike mongock.
    - Due to this issue, even though the Kestrel issue is fixed on paper, I was unable to test it
- The code coverage results are in the pipeline as a proof of concept. Ideally I would have liked to use the cobertura report and generate a HTML page uploaded on S3 for readability. SSO could be implemented here for security. 
- Passwords stored in plaintext in docker-compose, parameterise this and pull from secrets
- Implement a configurations file for all variables, to reduce code duplication and deployment issues. Azure DevOps seems to handle this nicer than GitHub actions
- In the image, there is an ENV VAR **DOTNET_EnableDiagnostics=0** which was recommended in the MS deployment docs. Ideally I would presume this would be disabled for non-release containers for dev/debugging purposes. I've left it there because I didn't utilise those features in my pipelines.
- Use a lean runtime container, need to do more research on which is the best container for published release
- Seperate out Integration Test pipeline to allow finer control on triggers
- MSSQL container is large, pulling all the layers into the VM during integration tests can be delayed depending on if the VM was warm or not (GitHub Actions limitation) - need to remediate this, ADO does it better.
- Setting CPU and RAM limitations on the application - requires performance testing to find ideal limits in production

Challenges I faced;
- macOS setup locally was fine but GitHub actions support for macOS is poor [(especially docker actions)](https://github.com/actions/runner/issues/715)
    - There was also an issue with the Code Coverage package used, initially I used the MSBuild package which was fine but it didn't work on GitHub with how I ran the tests so I ended up using the XPlat package.
- Ideally I would have run everything on a Windows Environment with an IDE like Visual Studio. I used VSCode due to lack of Windows environment.


---
If you liked (or disliked) anything I've done, or want to chat about hobbies, please reach out at gautham.ontri@gmail.com and we can spin some yarn ✌️