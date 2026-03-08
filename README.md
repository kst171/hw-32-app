# Jenkins Pipeline Demo — Java App

Минимальное Java-приложение для изучения Jenkins Pipeline.

---

## Структура проекта

```
jenkins-pipeline-demo/
├── src/
│   ├── main/java/com/demo/
│   │   ├── App.java           # Точка входа
│   │   └── Calculator.java    # Бизнес-логика
│   └── test/java/com/demo/
│       └── CalculatorTest.java # Unit-тесты (JUnit 5)
├── pom.xml                    # Maven-конфигурация
├── Jenkinsfile                # Описание pipeline
└── README.md
```

---

## Этапы Pipeline

| Stage        | Что происходит                                     |
|--------------|----------------------------------------------------|
| **Checkout** | Клонирование кода из репозитория                  |
| **Build**    | `mvn clean compile` — компиляция                  |
| **Test**     | `mvn test` — запуск JUnit-тестов                  |
| **Package**  | `mvn package` — сборка JAR-файла                  |
| **Quality**  | Checkstyle (только ветка `main`)                  |
| **Deploy**   | Заглушка деплоя (только ветка `main`)             |

---

## Быстрый старт

### 1. Локальная сборка (без Jenkins)

```bash
# Сборка
mvn clean package

# Запуск
java -jar target/jenkins-pipeline-demo-1.0.0.jar

# Только тесты
mvn test
```

### 2. Настройка Jenkins

**Требования:**
- Jenkins 2.x с плагином Pipeline
- JDK 17 (настроить в: Manage Jenkins → Global Tool Configuration → JDK)
- Maven 3.9 (настроить там же → Maven)

**Шаги:**
1. Создать новый **Pipeline** job
2. В разделе **Pipeline** выбрать `Pipeline script from SCM`
3. Указать URL репозитория
4. В поле `Script Path` оставить `Jenkinsfile`
5. Нажать **Save** → **Build Now**

### 3. Запуск Jenkins через Docker (самый простой способ)

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

# Получить начальный пароль
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Затем открыть http://localhost:8080 и завершить установку.

---

## Ключевые концепции Jenkinsfile

```groovy
pipeline {          // Декларативный синтаксис
    agent any       // Выполнять на любом агенте

    environment {   // Переменные окружения
        APP = 'demo'
    }

    stages {        // Список этапов
        stage('Build') {
            steps { sh 'mvn compile' }  // Команды оболочки
        }
    }

    post {          // Действия после выполнения
        success { echo "OK" }
        failure { echo "FAIL" }
        always  { cleanWs() }
    }
}
```

---

## Полезные плагины Jenkins

- **Pipeline** — основа declarative pipeline
- **Git** — интеграция с Git
- **JUnit** — отображение результатов тестов
- **SonarQube Scanner** — анализ качества кода
- **Blue Ocean** — современный UI для pipeline
