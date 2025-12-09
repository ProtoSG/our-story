FROM eclipse-temurin:17-jre-alpine
ARG JAR_FILE=target/our-story-back-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} app-our-story-back.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app-our-story-back.jar"]
