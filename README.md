# Website

- [Website](#website)
  - [Models and Views](#models-and-views)
  - [settings.py](#settingspy)
    - [Cosmos MongoDB](#cosmos-mongodb)
    - [Azure Storage backend](#azure-storage-backend)
    - [Security](#security)
  - [Terraform](#terraform)
    - [Security](#security-1)
  - [Pipelines](#pipelines)
  - [Dockerfile](#dockerfile)

This was originally created for the [Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/azure/), but as I've progressed after achieving the AZ-104 certification I decided to break away from its mold a bit. I started to get more focused on Python, and wanted to redo this site with Django.

A little overkill for a single page application, but I thought it was a fun project and it allows me to better expand on my site in the future.

    ├───app
    │   ├───cmeadows_tech           # Project folder
    │   ├───home                    # Main app folder
    └───infra
        ├───global                  # Global Terraform IAC
        └───web                     # Terraform IAC for running app


## Models and Views

Pretty straightforward for a single page site. At the moment I have one model for my projects, so in the future I can more easily add, remove and modify them. You know, your basic CRUD opereations.

I would like to create another model for more extensive project descriptions, and use that to provide more information if the visitor is so inclined to follow through.

## settings.py

### Cosmos MongoDB

To try and save on costs and because I like NoSQL databases, I wanted to put my database up on Cosmos DB. The easiest way to do this was with it's MongoDB api and the [Djongo](https://github.com/doableware/djongo) backend.

This did come with some difficulties though, as the package dependencies were a mess after updates to Python3 and Django itself.

[This open issue](https://github.com/doableware/djongo/issues/171) has an ongoing conversation on the issue I ran into, and is what helped me correct my dependencies.

These packages work together:

```python
asgiref==3.6.0
Django==4.1.4
djongo==1.3.6
dnspython==2.2.1
pymongo==3.12.3
pytz==2022.7           # This  must be installed manually, it is not included in djongo
sqlparse==0.2.4
tzdata==2022.7
```

    Note: Cosmos uses a different port than the default MongoDB port, so you have to specify it in the connection string.

### Azure Storage backend

I also wanted to use Azure Storage to server my static files, which luckily was pretty straightforward to do with the [Azure Storage backend.](https://django-storages.readthedocs.io/en/latest/backends/azure.html)

```python
AZURE_ACCOUNT_NAME = "<storage account name>"
AZURE_CONTAINER = 'static'
AZURE_ACCOUNT_KEY = '<storage account key>'
AZURE_OVERWRITE_FILES = 'True'

STATIC_URL = 'static/'

STATIC_DIRS = [
BASE_DIR / "static"
]
```

### Security

Of course, this resulted in a bunch of vulnerabilities if I were to store the connection strings and keys as plaintext in settings.py, so I utilized environment variables, GitHub Secrets, and App Service Settings to secure the important bits.

    DJANGO_SECRET_KEY - Used to update SECRET_KEY in production
    - Secret = DJANGO_SECRET_KEY
    DJANGO_DEBUG - Used to disable debug mode in production
    - No Secret
    DJONGO_HOST - Used to secure connection string to Cosmos MongoDB
    - Secret = DJONGO_HOST        
    ACCOUNT_KEY - Used to secure connection key to Azure Storage hosting static files
    - Secret = ACCOUNT_KEY

## Terraform

I have two main Terraform configurations:

1. global - This is used to define the resource group and storage account used by both the remote state and static files. Using the same storage account for both probably isn't considered a best practice, but I thought it acceptible for a small personal project where everything would likely share the same lifecycle
2. web - This defines the infrastructure my Django app needs to run. The Cosmos DB, the static container, and the App Service

### Security

For authentication, I am using a Service Principal and setting the below environment variables during the workflow run, with their values retrieved from repo secrets.

    ARM_CLIENT_ID
    ARM_CLIENT_SECRET
    ARM_SUBSCRIPTION_ID 
    ARM_TENANT_ID 

## Pipelines

Just two pipelines at the moment

1. deploy.yml - Not well-named, but is what I used to deploy my web Terraform configuration. I want to thank Facuno Gauna for his wonderful article on deploying [Terraform with Github ACtions](https://gaunacode.com/deploying-terraform-at-scale-with-github-actions)
2. appcontent.yml - Used to deploy my app content to the Azure App Service. Using [this sample](https://github.com/Azure/actions-workflow-samples/blob/master/AppService/python-webapp-on-azure.yml) provided by Microsoft, with very minor modifications. 

## Dockerfile

I started creating a Dockerfile with the intention of containerizing, which I still might, but haven't completed due to deciding on Azure App Service hosting instead of a container instance. It really only needs environment variables for settings.py at this point, then publishing somewhere. 