# Dotnet Microsevices Template

## Purpose

This template is meant for creating ASP.NET applications with a microservices architecture. Implemented with Docker in mind, creating infrastructure for projects with automated scripts [See here](#scripts) using Justfiles.

## Requirements

* [.NET 8](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)
* [Just](https://github.com/casey/just)
* [sed and bash](https://gitforwindows.org/)
* [Docker](https://www.docker.com/)
* [Podman (Docker alternative)](https://podman.io/)

## The Template

The base solution is created as a minimal starting app only consisting of a basic `compose.yaml` file for Docker, a `sln` file for the project (can be renamed), a project `Proxy` which is the main gateway for the application using the "Yarp" package in Dotnet, and a justfile as well as some just scripts in the 'file_gen' folder.

The justfile is the main feature here, generating a simple microservice with a very basic command. [Just](https://github.com/casey/just) is a HARD requirement for this to work as well as some commands from the GNU package, specifically `sed` and `bash` ('Stream editor' and 'Bourne Again SHell').

To check if they are installed on your machine use: `sed --version` and `bash --version`. Alternatively if Just is installed use `just doctor`, the command will fail if either is not found.
If they are not installed you can install these tools to windows [here](https://gitforwindows.org/).

**_IMPORTANT:_** All recipes in Just are only tested on Linux, if they don't work I had nothing to do with it :)

## Scripts

To check if dependencies are present:
```bash
just doctor
```
Generate a new microservice, add to proxy, add to compose.yaml and adding to solution.
```bash
just add-service <name of service>

# Example
just add-service TestService
```