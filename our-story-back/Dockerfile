FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /app

COPY pom.xml .
COPY mvnw ./
COPY .mvn .mvn
RUN ./mvnw -B -q -DskipTests dependency:go-offline

COPY src src
RUN ./mvnw -B -q -DskipTests package

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
