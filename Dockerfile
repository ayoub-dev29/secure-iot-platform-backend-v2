# --- Stage 1: The "Build" Stage ---
# We use an official Maven image that includes JDK 17 to build our project.
# The 'AS build' part gives this stage a name we can reference later.
FROM maven:3.9-eclipse-temurin-17 AS build

# Set the working directory inside the container for our build process.
WORKDIR /app

# Copy the pom.xml file first. This is a clever trick to use Docker's caching.
# If our dependencies in pom.xml don't change, Docker won't re-download them on every build.
COPY pom.xml .
RUN mvn dependency:go-offline

# Now copy the rest of our application's source code.
COPY src ./src

# Use Maven to package the application into a single .jar file.
# We skip the tests for a faster build in this context.
RUN mvn package -DskipTests


# --- Stage 2: The "Final" Stage ---
# Start fresh with a much smaller, JRE-only image. This is our "showroom".
FROM eclipse-temurin:17-jre

# Set the working directory for the final application.
WORKDIR /app

# The magic step: copy ONLY the compiled .jar file from the 'build' stage into our new image.
COPY --from=build /app/target/*.jar app.jar

# Inform Docker that the container listens on this port at runtime.
EXPOSE 8080

# The command that will be executed when the container starts.
ENTRYPOINT ["java","-jar","/app/app.jar"]