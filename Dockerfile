FROM openjdk:8-jdk-alpine

LABEL maintainer="c-n-c"

EXPOSE 8080

ARG JAR_FILE=build/libs/uploading-files-0.0.1-SNAPSHOT.jar

ADD ${JAR_FILE} demo.jar

# Run the jar file
ENTRYPOINT ["java","-jar","demo.jar"]