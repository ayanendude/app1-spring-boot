FROM openjdk:8
USER 1000580000
ADD target/App1-spring-boot.jar App1-spring-boot.jar
CMD ["chmod","777","App1-spring-boot.jar"]
EXPOSE 8085
ENTRYPOINT ["java", "-jar", "App1-spring-boot.jar"]