pipeline {
    agent any

    // ── Global environment variables ──────────────────────────────────────────
    environment {
        APP_NAME    = 'jenkins-pipeline-demo'
        APP_VERSION = '1.0.0'
        JAVA_OPTS   = '-Xmx512m'
    }

    // ── Tool definitions (configure these names in Jenkins → Global Tools) ────
    tools {
        maven 'Maven 3.9'
        jdk   'JDK 21'
    }

    options {
        timestamps()                    // prefix every log line with a timestamp
        timeout(time: 15, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    // ══════════════════════════════════════════════════════════════════════════
    stages {

        // ── 1. Checkout ───────────────────────────────────────────────────────
        stage('Checkout') {
            steps {
                echo "📥 Checking out source code..."
                checkout scm               // pulls code from the configured SCM
                echo "Branch: ${env.BRANCH_NAME ?: 'local'}"
                echo "Commit: ${env.GIT_COMMIT ?: 'unknown'}"
            }
        }

        stage('Check Java') {
            steps {
                sh 'java -version'
            }
        }

        // ── 2. Build ──────────────────────────────────────────────────────────
        stage('Build') {
            steps {
                echo "🔨 Compiling the project..."
                sh 'mvn clean compile -B'  // -B = non-interactive / batch mode
            }
        }

        // ── 3. Test ───────────────────────────────────────────────────────────
        stage('Test') {
            steps {
                echo "🧪 Running unit tests..."
                sh 'mvn test -B'
            }
            post {
                always {
                    // Publish JUnit test results in Jenkins UI
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        // ── 4. Package ────────────────────────────────────────────────────────
        stage('Package') {
            steps {
                echo "📦 Packaging into a JAR..."
                sh 'mvn package -DskipTests -B'
                // Archive the artifact so it can be downloaded from Jenkins
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        // ── 5. Code Quality (optional — remove if no SonarQube) ──────────────
        stage('Code Quality') {
            when {
                // Only run this stage on the main branch
                branch 'main'
            }
            steps {
                echo "🔍 Running code quality checks..."
                // Uncomment when SonarQube is configured:
                // sh 'mvn sonar:sonar -B'
                sh 'mvn checkstyle:check -B || true'   // soft-fail for demo
            }
        }

        // ── 6. Deploy (stub) ─────────────────────────────────────────────────
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo "🚀 Deploying ${APP_NAME} v${APP_VERSION}..."
                // Replace the line below with your real deploy command, e.g.:
                //   sh 'scp target/*.jar user@server:/opt/app/'
                //   sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'echo "Deployment step — replace with your real command"'
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    post {
        success {
            echo "✅ Pipeline finished successfully!"
        }
        failure {
            echo "❌ Pipeline failed — check the logs above."
        }
        always {
            echo "🧹 Cleaning workspace..."
            cleanWs()
        }
    }
}
