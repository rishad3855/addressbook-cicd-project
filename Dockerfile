FROM amazoncorretto
FROM maven:3.8.4-openjdk-11-slim AS build
WORKDIR /app
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/rishad3855/addressbook-cicd-project.git
RUN mvn compile
RUN mvn test
RUN mvn pmd:pmd
RUN mvn package
COPY --from=build /var/lib/jenkins/workspace/pipeline/target/*.war /home/ubuntu/apache-tomcat-8.5.100/webapps/
EXPOSE 7070 
CMD ["start.sh", "run"]
