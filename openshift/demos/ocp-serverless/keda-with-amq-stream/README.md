# OpenShift CRUD Application

## Descirption

Deploy CRUD application with PostgreSQL BDD hosted on OpenShift

## Prerequisites

- **GIT** installed
- **oc** CLI
- **MAVEN** installed

## Steps

1. Clone the repository
```
git clone https://github.com/davmartini/redhat-techs.git
cd redhat-techs/openshift/demos/ocp-serveless/serving-with-ocp-bdd/app/
```

1. Log to your OpenShift Cluster and create new project
```
export PROJECT_NAME=<project-name>
oc login -u <user> <ocp-url>
oc new-project ${PROJECT_NAME}
```

2. Create your PostgreSQL BDD from OpenShift template
```
oc new-app -e POSTGRESQL_USER=crud -e POSTGRESQL_PASSWORD=crudpwd -e POSTGRESQL_DATABASE=FRUITSDB postgresql:10-el8 --as-deployment-config=true --name=postgresql-db -n ${PROJECT_NAME}
oc label dc/postgresql-db app.kubernetes.io/part-of=fruit-service-app -n ${PROJECT_NAME}
oc label dc/postgresql-db app.openshift.io/runtime=postgresql --overwrite=true -n ${PROJECT_NAME}
```

3. Deploy application from sources
```
mvn clean package -Dquarkus.kubernetes.deploy=true -DskipTests -Dquarkus.profile=prod-postgresql
``` 