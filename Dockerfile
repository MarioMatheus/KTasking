FROM ibmcom/swift-ubuntu:latest
LABEL Description="Docker image for running KTasking sample project"

USER root

# Expose default port for Kitura
EXPOSE 8080

RUN apt-get update && \ 
    apt-get install -y libpq-dev && \
    mkdir KTasking
ADD ./ KTasking

# Build Swift Started App
RUN cd KTasking && swift build

CMD ["bash", "-c", "cd /KTasking/.build/x86_64-unknown-linux/debug && ./KTaskingAPI"]
