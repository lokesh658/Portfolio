# Multi-stage Dockerfile for Spring Boot (Maven build + slim runtime)
# Build stage: compile the application and create the runnable jar
FROM maven:3.8.8-openjdk-17 AS build
WORKDIR /workspace


# Copy Maven wrapper and settings to cache dependencies
COPY pom.xml mvnw ./
COPY .mvn .mvn

# Download dependencies (cache layer)
RUN mvn -B -DskipTests dependency:go-offline

# Copy source and build
COPY src ./src
RUN mvn -B -DskipTests package

# Runtime stage: small JRE image
FROM eclipse-temurin:17-jre-jammy
ARG JAR_FILE=target/*.jar
# Copy the jar from the build stage
COPY --from=build /workspace/${JAR_FILE} /app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]

