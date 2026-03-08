# ─────────────────────────────────────────────────────────────────
#  Jenkins Agent
#  JDK  : Eclipse Temurin 21.0.10 (Ubuntu 22.04 Jammy)
#  Maven : 3.9.13
# ─────────────────────────────────────────────────────────────────
FROM eclipse-temurin:21.0.10_7-jdk-jammy

LABEL description="Jenkins Agent — JDK 21.0.10 + Maven 3.9.13"

# ── System packages ───────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    openssh-client \
    sshpass \
    procps \
    && rm -rf /var/lib/apt/lists/*

# ── Maven 3.9.13 ──────────────────────────────────────────────────
ENV MAVEN_VERSION=3.9.13
ENV MAVEN_HOME=/opt/maven
ENV PATH="${MAVEN_HOME}/bin:${PATH}"

RUN curl -fsSL https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    | tar -xzC /opt \
    && ln -s /opt/apache-maven-${MAVEN_VERSION} ${MAVEN_HOME}

# ── Jenkins user ──────────────────────────────────────────────────
RUN useradd -u 1000 -m -s /bin/bash jenkins

# ── Maven local repository ────────────────────────────────────────
RUN mkdir -p /home/jenkins/.m2/repository \
    && chown -R jenkins:jenkins /home/jenkins/.m2

# ── SSH: отключить проверку host key при деплое ───────────────────
RUN mkdir -p /home/jenkins/.ssh \
    && printf "Host *\n    StrictHostKeyChecking no\n    UserKnownHostsFile=/dev/null\n" \
       > /home/jenkins/.ssh/config \
    && chmod 600 /home/jenkins/.ssh/config \
    && chown -R jenkins:jenkins /home/jenkins/.ssh

USER jenkins
WORKDIR /home/jenkins

# ── Проверка версий при сборке ────────────────────────────────────
RUN java -version && mvn -version

CMD ["/bin/bash"]
