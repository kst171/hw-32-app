# Jenkins Pipeline — Документация

## Обзор

Декларативный Jenkins Pipeline для сборки, тестирования и деплоя Java-приложения на основе Maven.

---

## Структура Jenkinsfile

```
pipeline
├── agent          — на каком агенте выполнять
├── environment    — переменные окружения
├── options        — настройки поведения pipeline
├── stages         — этапы сборки
│   ├── Checkout
│   ├── Build
│   ├── Test
│   ├── Package
│   ├── Code Quality
│   └── Deploy
└── post           — действия после завершения
```

---

## Агент

```groovy
agent {
    label 'java21'
}
```

| Параметр | Значение       | Описание                                      |
|----------|----------------|-----------------------------------------------|
| `label`  | `java21`       | Запускать только на агенте с этим label       |

Pipeline выполняется на постоянном агенте `my-agent`, настроенном в **Manage Jenkins → Nodes**.  
Образ агента: `jenkins-agent-java21` (JDK 21.0.10, Maven 3.9.13, Ubuntu 22.04).

---

## Переменные окружения

```groovy
environment {
    APP_NAME    = 'jenkins-pipeline-demo'
    APP_VERSION = '1.0.0'
    JAR_FILE    = "target/${APP_NAME}-${APP_VERSION}.jar"
}
```

| Переменная    | Значение                          | Использование                    |
|---------------|-----------------------------------|----------------------------------|
| `APP_NAME`    | `jenkins-pipeline-demo`           | Имя артефакта, сообщения логов   |
| `APP_VERSION` | `1.0.0`                           | Версия JAR-файла                 |
| `JAR_FILE`    | `target/jenkins-pipeline-demo...` | Путь к JAR для деплоя            |

Переменные доступны во всех stages через `${ENV_VAR}` (Groovy) или `$ENV_VAR` (shell).

---

## Этапы (Stages)

### 1. Checkout

```groovy
stage('Checkout') {
    steps {
        checkout scm
    }
}
```

**Что делает:** клонирует или обновляет код из репозитория, настроенного в Job-конфигурации.  
**Условие выполнения:** всегда.  
**Ветка:** `*/main` (настраивается в Job → Configure → Branch Specifier).

---

### 2. Build

```groovy
stage('Build') {
    steps {
        sh 'mvn clean compile -B'
    }
}
```

**Что делает:** компилирует исходный код (`src/main/java`).  
**Условие выполнения:** всегда.  
**Флаг `-B`:** batch mode — отключает интерактивный вывод Maven для чистых логов в Jenkins.  
**Упадёт если:** ошибки компиляции, недоступен Maven или JDK.

---

### 3. Test

```groovy
stage('Test') {
    steps {
        sh 'mvn test -B'
    }
    post {
        always {
            junit '**/target/surefire-reports/*.xml'
        }
    }
}
```

**Что делает:** запускает все JUnit 5 тесты из `src/test/java`.  
**Условие выполнения:** всегда.  
**Post-действие:** публикует XML-отчёты тестов в Jenkins UI (вкладка **Test Results**) — выполняется всегда, даже при падении тестов.  
**Упадёт если:** хотя бы один тест не прошёл.

---

### 4. Package

```groovy
stage('Package') {
    steps {
        sh 'mvn package -DskipTests -B'
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
    }
}
```

**Что делает:** собирает исполняемый JAR-файл.  
**Условие выполнения:** всегда.  
**`-DskipTests`:** тесты уже были запущены на предыдущем шаге — повторно не запускаем.  
**`archiveArtifacts`:** сохраняет JAR в Jenkins — доступен для скачивания со страницы сборки.  
**`fingerprint: true`:** вычисляет MD5 артефакта для отслеживания его использования в других job'ах.

---

### 5. Code Quality

```groovy
stage('Code Quality') {
    when {
        branch 'main'
    }
    steps {
        sh 'mvn checkstyle:check -B || true'
    }
}
```

**Что делает:** запускает статический анализ кода (Checkstyle).  
**Условие выполнения:** только для ветки `main`.  
**`|| true`:** мягкий режим — нарушения стиля не останавливают pipeline (для учебного проекта).  
**Для production:** убрать `|| true`, чтобы pipeline падал при нарушениях.

---

### 6. Deploy

```groovy
stage('Deploy') {
    when {
        branch 'main'
    }
    steps {
        sh "java -jar ${JAR_FILE}"
    }
}
```

**Что делает:** деплоит приложение.  
**Условие выполнения:** только для ветки `main`.  
**Для реального деплоя** заменить на:

```groovy
// Копирование на сервер по SSH
sh "scp ${JAR_FILE} user@server:/opt/app/"
sh "ssh user@server 'systemctl restart myapp'"

// Или через credentials
withCredentials([sshUserPrivateKey(credentialsId: 'deploy-key', keyFileVariable: 'SSH_KEY')]) {
    sh "scp -i $SSH_KEY ${JAR_FILE} user@server:/opt/app/"
}
```

---

## Блок post

```groovy
post {
    success { echo "✅ Pipeline finished successfully!" }
    failure { echo "❌ Pipeline failed — check the logs above." }
    always  { echo "🧹 Cleaning workspace..." }
}
```

| Условие   | Когда выполняется              | Действие                        |
|-----------|--------------------------------|---------------------------------|
| `success` | Pipeline завершился успешно    | Вывод сообщения в лог           |
| `failure` | Любой stage упал               | Вывод сообщения в лог           |
| `always`  | В любом случае                 | `cleanWs()` — очистка workspace |

---

## Условия выполнения (when)

| Stage          | Условие              | Описание                                  |
|----------------|----------------------|-------------------------------------------|
| Checkout       | всегда               | Нет блока `when`                          |
| Build          | всегда               | Нет блока `when`                          |
| Test           | всегда               | Нет блока `when`                          |
| Package        | всегда               | Нет блока `when`                          |
| Code Quality   | `branch 'main'`      | Только при сборке ветки `main`            |
| Deploy         | `branch 'main'`      | Только при сборке ветки `main`            |

Для feature-веток выполняются только первые 4 этапа: Checkout → Build → Test → Package.

---
