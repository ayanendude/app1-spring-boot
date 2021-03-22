FROM openjdk:8
USER 1000580000
ADD target/App1-spring-boot.jar App1-spring-boot.jar
RUN touch tmp/test1.txt
RUN touch tmp/test2.txt
EXPOSE 8085
ENTRYPOINT ["java", "-jar", "App1-spring-boot.jar"]