# terraform-local-demo
Demonstration of Terraform's capabilities for managing infrastructure locally in compliance with best practices. The project will be a good tutorial and an initial template for diving into real-world tasks.

Демонстрация возможностей Terraform для управления инфраструктурой локально с соблюдением best practices. Проект будет хорошим учебным пособием и начальным шаблоном для погружения в реальные задачи.



## Структура проекта
```text
terraform-local-demo/
├── main.tf                  # Основная конфигурация
├── variables.tf             # Определение переменных
├── outputs.tf               # Определение выходных данных
├── terraform.tfvars         # Значения переменных (опционально)
├── tags.json                # Дополнительные теги
├── templates/
│   └── README.md.tftpl      # Шаблон README
└── modules/
    └── monitoring/
        ├── main.tf          # Основной код модуля
        ├── variables.tf     # Переменные модуля
        └── outputs.tf       # Выходные данные модуля
```

## Как начать?

### Установка Terraform с Yandex Cloud
##### Для того чтобы установить Terraform с Yandex Cloud:
1) Заходим на страницу [Зеркало Yandex для HashiCorp](hashicorp-releases.yandexcloud.net/terraform/) и находим нужную нам версию Terraform.
2) Скачиваем через ```curl``` или ```wget``` необходимый нам пакет
```sh
wget https://hashicorp-releases.yandexcloud.net/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip
```
3) Распаковываем архив
```sh
unzip terraform_1.12.2_linux_amd64.zip
```
4) Перемещаем бинарный файл *terraform* в каталог, доступный через переменную PATH. Как правило это ```/usr/local/bin```
```sh
sudo mv terraform /usr/local/bin/
```
5) Проверяем корректность работы Terraform выполнив команду для вывода установленной версии
```sh
terraform --version
```
✅ Если видим вывод версии terraform то установка успешно завершена.


### Настройка провайдера Yandex Cloud

1) Создаем в домашнем каталоге пользователя файл ```nano ~/.terraformrc``` со следующим содержимым:
```hcl
provider_installation {
 network_mirror {
   url = "https://terraform-mirror.yandexcloud.net/"
   include = ["registry.terraform.io/*/*"]
 }
 direct {
   exclude = ["registry.terraform.io/*/*"]
 }
}
```
Для очистки кеша, если были предыдущие ошибки в прошлых инициализациях
```sh
rm -rf .terraform*
```
## [Инструкция по настройке провайдера YC](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart#configure-provider)

### Как использовать:
1) Создаем структуру папок
```sh
mkdir -p terraform-local-demo/{templates,modules/monitoring,configs,logs}
```
2) Инициализируем terraform
```sh
terraform init
```
3) Проверяем конфигурацию
```sh
terraform validate
terraform plan
```
4) Применяем конфигурацию
```sh
terraform apply
```
5) Изучаем созданные файлы:
- configs/ - конфигурации окружений
- README.md - документация проекта
- logs/environments.json - информация о окружениях


### Основные возможности проекта:
1) #### Локальное управление инфраструктурой
- Создание и управление локальными ресурсами (файлы, директории, скрипты) без облачных провайдеров.
- Генерация динамических конфигураций(JSON) через шаблонизацию.
- Примеры использования local-exec для интеграции с внешними инструментами.

2) #### Работа с переменными и окружениями
- Модульная архитектура с разделением dev/stage/prod окружений.
- Использование валидации переменных:
```hcl
variable "project_name" {
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Only lowercase alphanumeric chars and hyphens allowed."
  }
}
```
3) #### Безопасность и секреты
- Автоматическая генерация случайных паролей/токенов через random_password.
- Помечение чувствительных данных как sensitive:
```hcl
output "db_password" {
  value     = random_password.db.result
  sensitive = true
}
```
4) #### Автоматизация
- Post-apply хуки: создание файлов, директорий, запуск скриптов.
- Динамические блоки для генерации конфигов:
```hcl
  dynamic "config" {
  for_each = var.environments
  content {
    env  = config.key
    path = "configs/${config.key}.json"
  }
}
```
5) #### Документирование
- Автогенерация README.md через шаблоны Terraform.
- Пример структуры для CHANGELOG.md и документации модулей.

## Использованные возможности terraform 
Работа с переменными:
- Валидация входных параметров
- Сложные типы переменных (map of objects)
- Четкие описания

Использование locals:
- Использование функций merge, jsondecode, fileexists
- Динамическое преобразование данных
- Условная логика

Безопасность:
- Все секреты помечены как sensitive
- Использование хешей вместо реальных значений
- Правильные permissions для файлов

Динамические ресурсы:
- for_each с комплексными структурами
- Условное создание ресурсов (count)
- Зависимости между ресурсами

Шаблонизация:
- Условная логика в шаблонах
- Генерация Markdown документации
- Поддержка JSON конфигураций

Жизненный цикл:
- Pre-apply проверки
- Post-apply настройки
- Cleanup скрипты

Модульность:
- Условное включение модуля
- Четкие интерфейсы модулей
- Переиспользуемые компоненты

Вывод информации:
- Форматированные multi-line output
- Чувствительные и нечувствительные выводы
- Полезные next steps

Обработка ошибок:
- Проверка существования файлов
- Валидация структур данных
- Ясные сообщения об ошибках
 
##### Эта конфигурация полностью самодостаточна и работает без облачных провайдеров, но при этом демонстрирует все ключевые возможности Terraform.
