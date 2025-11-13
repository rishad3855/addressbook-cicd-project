# syntax=docker/dockerfile:1

# -------- Stage 1: Build the application --------
FROM maven:3.9.9-eclipse-temurin-11 AS build
WORKDIR /app

# Copy source and build; do NOT git clone inside the image
# Build context should be the repo root (run docker build . from the repo)
COPY . .
# If tests are slow or not needed in image builds, skip them
RUN mvn -B clean package -DskipTests

# -------- Stage 2: Runtime (Tomcat) --------
FROM tomcat:9.0-jdk11-temurin
# Optional: remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built WAR from the builder
# Adjust the artifact name if different; using a wildcard is fine if only one WAR is produced
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Expose Tomcat HTTP port
EXPOSE 8080

# Healthcheck (optional; Tomcat default ROOT context served at /)
HEALTHCHECK --interval=30s --timeout=5s --retries=5 \
  CMD curl -fsS http://localhost:8080/ || exit 1

# Default entrypoint/cmd from Tomcat image starts catalina
