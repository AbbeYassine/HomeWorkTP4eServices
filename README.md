# Steps To Containerize Services (ProductService , DiscoveryService , ConfigService , ProxyService )

L'une des solutions pour containerizer les services en utilisions docker qui est un logiciel libre 
qui automatise le déploiement d'applications dans des conteneurs logiciels .
Commencons à créer une image de ProductService pour ensuite faire 3 contenaires différent de cette image .  

## ProductService
J'ai suivi le tuto du site officiel [Spring](https://spring.io/guides/gs/spring-boot-docker/) . On réalité , ProductService est une application Spring boot donc il suffit de savoir comment docarizer 
une application Spring pour résoudre cette problématique .

### 1- DockerFile
La premiére étape qu'on doit faire est de créer le fichier **Dockerfile** qui contient les instructions 
pour la construction de l'image qu'on veut lancer par la suite .

Voici les instructions de maniére générale pour construire une image d'un application Spring Boot : 

```Dockerfile
FROM openjdk:8-jdk-alpine
VOLUME /tmp
ARG JAR_FILE
ADD ${JAR_FILE} app.jar
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
```

On va importer le **JDK** depuis le **DockerHub** pour lancer une application Java : 

```Dockerfile
FROM openjdk:8-jdk-alpine
```

Remarques : Les prochaines **pull** seront à partir du local s'il n'y a pas d'autre mise à jour dans l'image du JDK.

L'étape suivant est optionelle , elle permet à créer un **Volume** pointer à **/tmp** permettant
à l'application de créer dans les fichier systémes . 

```Dockerfile
VOLUME /tmp
```

On ajoutant le fichier JAR du projet est ajouté au conteneur en tant que "app.jar" :

```Dockerfile
ARG JAR_FILE
ADD ${JAR_FILE} app.jar
```

Finalement en éxectuant le projet : 

```Dockerfile 
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
```

### 2- Construction de l'image 

On va construire notre image (**build**) avec maven en ajoutant les dépendances **Spotify**

```pom.xml
<properties>
   <docker.image.prefix>springio</docker.image.prefix>
</properties>
<build>
    <plugins>
        <plugin>
            <groupId>com.spotify</groupId>
            <artifactId>dockerfile-maven-plugin</artifactId>
            <version>1.3.6</version>
            <configuration>
                <repository>${docker.image.prefix}/${project.artifactId}</repository>
	<buildArgs>
		<JAR_FILE>target/${project.build.finalName}.jar</JAR_FILE>
	</buildArgs>
            </configuration>
        </plugin>
    </plugins>
</build>
```

On va simplement lancer cette commander pour faire le build : 

```bash
./mvnw install dockerfile:build
```

J'ai résolut deux problémes 
#### 1- Docker Config.json
J'ai supprimé le fichier **Users/Abbes/.docker/config.json** car docker ont ajouté l'athentification dans ca dérniére version que
d'aprés ce que j'ai compris qu'il faut sauter cette étape pour que ca marche .
#### 2- Connection Refused in port 2375 
Dans le menu setting de Docker j'ai coché le paramétre ``Expose daemon on tcp://localhost:2375  without TLS``


Aprés avoir construire l'image , une petite verfication de notre travail en tapant **docker images** on trouve bien les 2 images créer
```docker
REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
springio/product-service   latest              9ad831aff57d        About an hour ago   152MB
openjdk                    8-jdk-alpine        a2a00e606b82        2 weeks ago         101MB
```

### 3- Lancer l'image : 

L'étape la plus facile est de lancer l'image en affectant un port : 
Dans notre example en va affecter les port **4200** , **4201** et **4202** respectivement pour les instances (**product_service_1** ,
**product_service_2** et **product_service_3** )

```docker
docker run --name product_service_1 -d -p 4200:8080 -t springio/product-service
```

* Le port **8080** est le port que l'application spring expose , et le port 4200 est le port qu'on va exposer sur notre machine .

* **-d** pour dire qu'on veut lancer cette instance en background . 

* **springio/product-service** est le nom de l'image qu'on a créer . 

On voit bien nos instance marche sur les ports on tapant la commande **docker ps**
```
CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS              PORTS                    NAMES
54fcbb228d6f        springio/product-service   "java -Djava.secur..."   3 minutes ago       Up 3 minutes        0.0.0.0:4202->8080/tcp   product_service_3
6ca32a700606        springio/product-service   "java -Djava.secur..."   3 minutes ago       Up 3 minutes        0.0.0.0:4201->8080/tcp   product_service_2
ab7e58d6cdd6        springio/product-service   "java -Djava.secur..."   3 minutes ago       Up 3 minutes        0.0.0.0:4200->8080/tcp   product_service_1
```

Pour vérifier il suffit de lancer [http://localhost:4200/products](http://localhost:4200/products) pour afficher la liste des produits

## ConfigService 
On va proceder les mémes étape pour créer l'image du service ProductService . Mais le probélme que dans le lancement de l'image 
docker ne connait pas le path `` file:./src/main/resources/myConfig `` 


