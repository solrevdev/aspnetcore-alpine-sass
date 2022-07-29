# aspnetcore-alpine-sass

**UPDATE**

This has now been for now at least fixed see [issue](https://github.com/koenvzeijl/AspNetCore.SassCompiler/issues/93) and [commit](https://github.com/solrevdev/aspnetcore-alpine-sass/commit/1d89d8ba01f713b6669c8e71e56b9a7a5b73f85d) for details

So, `glibc-2.34-r0.apk` works for me whereas the version `glibc-2.35-r0.apk` from the source site did not.

```diff
FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine AS build
WORKDIR /source

RUN apk update

+ # THIS WORKS (glibc-2.34-r0.apk) https://github.com/CargoSense/dart_sass#compatibility-with-alpine-linux-mix-sass-default-exited-with-2
+ #RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
+ #RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-2.34-r0.apk
+ #RUN apk add glibc-2.34-r0.apk
+ 
+ # THIS (glibc-2.35-r0.apk) FROM SOURCE SITE DOES NOT https://github.com/sgerrand/alpine-pkg-glibc#installing
+ RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
+ RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-2.35-r0.apk
+ RUN apk add glibc-2.35-r0.apk

COPY ./ ./
RUN dotnet restore -r linux-musl-x64
RUN dotnet publish -c release -o /app -r linux-musl-x64 --no-self-contained --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine-amd64
WORKDIR /app
COPY --from=build /app ./

EXPOSE 80
ENV ASPNETCORE_URLS=http://+:80
ENTRYPOINT ["dotnet", "aspnetcore-alpine-sass.dll"]
```

----------------

This is to repo the alpine docker issue I was having with https://github.com/koenvzeijl/AspNetCore.SassCompiler

Both the default `Dockerfile` and `Dockerfile.alpine-x64` builds worked until I added `AspNetCore.SassCompiler`

The original error is the following which suggests that it cannot find the sass binary:

```bash
docker build --pull --rm -f "Dockerfile.alpine-x64" -t aspnetcore-alpine-sass.alpine:latest "."

[+] Building 43.6s (11/13)
 => [internal] load build definition from Dockerfile.alpine-x64     0.0s
 => => transferring dockerfile: 451B                                0.0s
 => [internal] load .dockerignore                                   0.0s
 => => transferring context: 35B                                    0.0s
 => [internal] load metadata for mcr.microsoft.com/dotnet/aspnet:6  0.1s
 => [internal] load metadata for mcr.microsoft.com/dotnet/sdk:6.0-  0.1s
 => [build 1/5] FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine@sha25  0.0s
 => [internal] load build context                                   0.0s
 => => transferring context: 1.11kB                                 0.0s
 => [stage-1 1/3] FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine-  0.0s
 => CACHED [build 2/5] WORKDIR /source                              0.0s
 => [build 3/5] COPY ./ ./                                          0.0s
 => [build 4/5] RUN dotnet restore -r linux-musl-x64               40.4s
 => ERROR [build 5/5] RUN dotnet publish -c release -o /app -r lin  2.9s
------
 > [build 5/5] RUN dotnet publish -c release -o /app -r linux-musl-x64 --no-self-contained --no-restore:
#12 0.573 Microsoft (R) Build Engine version 17.2.0+41abc5629 for .NET
#12 0.573 Copyright (C) Microsoft Corporation. All rights reserved.
#12 0.573
#12 2.717 /root/.nuget/packages/aspnetcore.sasscompiler/1.52.3/build/AspNetCore.SassCompiler.targets(11,5): error MSB4018: The "CompileSass" task failed unexpectedly. [/source/aspnetcore-alpine-sass.csproj]
#12 2.717 /root/.nuget/packages/aspnetcore.sasscompiler/1.52.3/build/AspNetCore.SassCompiler.targets(11,5): error MSB4018: System.ComponentModel.Win32Exception (2): An error occurred trying to start process '/root/.nuget/packages/aspnetcore.sasscompiler/1.52.3/build/../runtimes/linux-x64/sass' with working directory '/source'. No such file or directory [/source/aspnetcore-alpine-sass.csproj]
#12 2.717 /root/.nuget/packages/aspnetcore.sasscompiler/1.52.3/build/AspNetCore.SassCompiler.targets(11,5): error MSB4018:    at System.Diagnostics.Process.ForkAndExecProcess(ProcessStartInfo startInfo, String resolvedFilename, String[] argv, String[] envp, String cwd, Boolean setCredentials, UInt32 userId, UInt32 groupId, UInt32[] groups, Int32& stdinFd, Int32& stdoutFd, Int32& stderrFd, Boolean usesTerminal, Boolean throwOnNoExec) [/source/aspnetcore-alpine-sass.csproj]
#12 2.717 /root/.nuget/packages/aspnetcore.sasscompiler/1.52.3/build/AspNetCore.SassCompiler.targets(11,5): error MSB4018:    at System.Diagnostics.Process.StartCore(ProcessStartInfo startInfo) [/source/aspnetcore-alpine-sass.csproj]
#12 2.717 /root/.nuget/packages/aspnetcore.sasscompiler/1.52.3/build/AspNetCore.SassCompiler.targets(11,5): error MSB4018:    at System.Diagnostics.Process.Start() [/source/aspnetcore-alpine-sass.csproj]
#12 2.717 /root/.nuget/packages/aspnetcore.sasscompiler/1.52.3/build/AspNetCore.SassCompiler.targets(11,5): error MSB4018:    at AspNetCore.SassCompiler.CompileSass.GenerateCss(String arguments) [/source/aspnetcore-alpine-sass.csproj]
#12 2.717 /root/.nuget/packages/aspnetcore.sasscompiler/1.52.3/build/AspNetCore.SassCompiler.targets(11,5): error MSB4018:    at AspNetCore.SassCompiler.CompileSass.GenerateSourceTarget(SassCompilerOptions options)+MoveNext() [/source/aspnetcore-alpine-sass.csproj]
#12 2.717 /root/.nuget/packages/aspnetcore.sasscompiler/1.52.3/build/AspNetCore.SassCompiler.targets(11,5): error MSB4018:    at System.Collections.Generic.List`1.InsertRange(Int32 index, IEnumerable`1 collection) [/source/aspnetcore-alpine-sass.csproj]
#12 2.717 /root/.nuget/packages/aspnetcore.sasscompiler/1.52.3/build/AspNetCore.SassCompiler.targets(11,5): error MSB4018:    at System.Collections.Generic.List`1.AddRange(IEnumerable`1 collection) [/source/aspnetcore-alpine-sass.csproj]
#12 2.717 /root/.nuget/packages/aspnetcore.sasscompiler/1.52.3/build/AspNetCore.SassCompiler.targets(11,5): error MSB4018:    at AspNetCore.SassCompiler.CompileSass.Execute() [/source/aspnetcore-alpine-sass.csproj]
#12 2.717 /root/.nuget/packages/aspnetcore.sasscompiler/1.52.3/build/AspNetCore.SassCompiler.targets(11,5): error MSB4018:    at Microsoft.Build.BackEnd.TaskExecutionHost.Microsoft.Build.BackEnd.ITaskExecutionHost.Execute() [/source/aspnetcore-alpine-sass.csproj]
#12 2.717 /root/.nuget/packages/aspnetcore.sasscompiler/1.52.3/build/AspNetCore.SassCompiler.targets(11,5): error MSB4018:    at Microsoft.Build.BackEnd.TaskBuilder.ExecuteInstantiatedTask(ITaskExecutionHost taskExecutionHost, TaskLoggingContext taskLoggingContext, TaskHost taskHost, ItemBucket bucket, TaskExecutionMode howToExecuteTask) [/source/aspnetcore-alpine-sass.csproj]
------
executor failed running [/bin/sh -c dotnet publish -c release -o /app -r linux-musl-x64 --no-self-contained --no-restore]: exit code: 1
```

I found [this](https://github.com/CargoSense/dart_sass) 
> Dart-native executables rely on [glibc](https://www.gnu.org/software/libc/) to be present. Because Alpine Linux uses [musl](https://musl.libc.org/) instead, you have to add the package [alpine-pkg-glibc](https://github.com/sgerrand/alpine-pkg-glibc) to your installation.

So,I tried the above but that did not help however I can improve things by adding the following which also adds glibc in alpine:


```diff
+ RUN apk update
+ RUN apk add gcompat
```

Which gets me to this error message:

```bash
docker build --pull --rm -f "Dockerfile.alpine-x64" -t aspnetcore-alpine-sass.alpine:latest "."

[+] Building 20.7s (13/15)
 => [internal] load build definition from Dockerfile.alpine-x64     0.0s
 => => transferring dockerfile: 487B                                0.0s
 => [internal] load .dockerignore                                   0.0s
 => => transferring context: 35B                                    0.0s
 => [internal] load metadata for mcr.microsoft.com/dotnet/aspnet:6  0.2s
 => [internal] load metadata for mcr.microsoft.com/dotnet/sdk:6.0-  0.2s
 => [stage-1 1/3] FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine-  0.0s
 => [internal] load build context                                   0.0s
 => => transferring context: 7.48kB                                 0.0s
 => [build 1/7] FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine@sha25  0.0s
 => CACHED [build 2/7] WORKDIR /source                              0.0s
 => CACHED [build 3/7] RUN apk update                               0.0s
 => CACHED [build 4/7] RUN apk add gcompat                          0.0s
 => [build 5/7] COPY ./ ./                                          0.0s
 => [build 6/7] RUN dotnet restore -r linux-musl-x64               14.6s
 => ERROR [build 7/7] RUN dotnet publish -c release -o /app -r lin  5.8s
------
 > [build 7/7] RUN dotnet publish -c release -o /app -r linux-musl-x64 --no-self-contained --no-restore:
#14 0.508 Microsoft (R) Build Engine version 17.2.0+41abc5629 for .NET
#14 0.508 Copyright (C) Microsoft Corporation. All rights reserved.
#14 0.508
#14 2.574 /root/.nuget/packages/aspnetcore.sasscompiler/1.52.3/build/AspNetCore.SassCompiler.targets(11,5): error : Error running sass compiler:  [/source/aspnetcore-alpine-sass.csproj]
#14 2.574 /root/.nuget/packages/aspnetcore.sasscompiler/1.52.3/build/AspNetCore.SassCompiler.targets(11,5): error : . [/source/aspnetcore-alpine-sass.csproj]
#14 5.668   aspnetcore-alpine-sass -> /source/bin/release/net6.0/linux-musl-x64/aspnetcore-alpine-sass.dll
#14 5.732   aspnetcore-alpine-sass -> /app/
------
executor failed running [/bin/sh -c dotnet publish -c release -o /app -r linux-musl-x64 --no-self-contained --no-restore]: exit code: 1
```

And this is as far as I have gotten.

To test run the following docker build commands


## Docker build commands

Ubuntu image:

```bash
docker build --pull --rm -f "Dockerfile" -t aspnetcore-alpine-sass:latest "."
````


Alpine iamge: 


```bash
docker build --pull --rm -f "Dockerfile.alpine-x64" -t aspnetcore-alpine-sass.alpine:latest "."
````
