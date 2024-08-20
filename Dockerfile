FROM openjdk:17-jdk-alpine

WORKDIR /app

EXPOSE 8080

COPY /target/*.jar ./java.jar

CMD ["java", "-jar", "java.jar"]
