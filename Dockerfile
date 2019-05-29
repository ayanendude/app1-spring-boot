FROM openjdk:8
ADD target/App1-spring-boot.jar App1-spring-boot.jar
EXPOSE 8085
ENTRYPOINT ["java", "-jar", "App1-spring-boot.jar"]