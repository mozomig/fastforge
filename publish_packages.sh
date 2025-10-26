#!/bin/bash

# Скрипт для публикации пакетов на pub.dev в правильном порядке
# Использование: ./publish_packages.sh

set -e  # Остановить при ошибке

echo "🚀 Начинаем публикацию пакетов с префиксом 'plus_' на pub.dev"
echo "=================================================="

# Проверяем, что мы в правильной директории
if [ ! -f "melos.yaml" ]; then
    echo "❌ Ошибка: Запустите скрипт из корневой директории проекта"
    exit 1
fi

# Проверяем, что пользователь залогинен в pub.dev
echo "🔐 Проверяем авторизацию в pub.dev..."
if ! fvm flutter pub token list > /dev/null 2>&1; then
    echo "❌ Вы не авторизованы в pub.dev. Выполните: fvm flutter pub login"
    exit 1
fi

echo "✅ Авторизация подтверждена"
echo ""

# Функция для публикации пакета
publish_package() {
    local package_name=$1
    local package_path=$2
    
    echo "📦 Публикуем $package_name..."
    echo "   Путь: $package_path"
    
    cd "$package_path"
    
    # Проверяем, что pubspec.yaml существует
    if [ ! -f "pubspec.yaml" ]; then
        echo "❌ Ошибка: pubspec.yaml не найден в $package_path"
        exit 1
    fi
    
    # Проверяем, что пакет готов к публикации
    echo "   🔍 Проверяем пакет..."
    if ! fvm flutter pub publish --dry-run; then
        echo "❌ Ошибка: Пакет $package_name не готов к публикации"
        exit 1
    fi
    
    # Публикуем пакет
    echo "   📤 Публикуем пакет..."
    if fvm flutter pub publish --force; then
        echo "✅ $package_name успешно опубликован!"
    else
        echo "❌ Ошибка при публикации $package_name"
        exit 1
    fi
    
    echo ""
    cd - > /dev/null
}

# Публикуем пакеты в правильном порядке
echo "🎯 Уровень 1: Базовые пакеты"
publish_package "plus_shell_executor" "packages/shell_executor"
publish_package "plus_shell_uikit" "packages/shell_uikit"

echo "🎯 Уровень 2: Пакеты первого уровня"
publish_package "plus_parse_app_package" "packages/parse_app_package"
publish_package "plus_flutter_app_builder" "packages/flutter_app_builder"

echo "🎯 Уровень 3: Пакеты второго уровня"
publish_package "plus_flutter_app_packager" "packages/flutter_app_packager"

echo "🎯 Уровень 4: Пакеты третьего уровня"
publish_package "plus_flutter_app_publisher" "packages/flutter_app_publisher"

echo "🎯 Уровень 5: Пакеты четвертого уровня"
publish_package "plus_unified_distributor" "packages/unified_distributor"

echo "🎯 Уровень 6: Финальные пакеты"
publish_package "plus_fastforge" "packages/fastforge"
publish_package "plus_flutter_distributor" "packages/flutter_distributor"

echo "🎉 Все пакеты успешно опубликованы!"
echo "=================================================="
echo "📋 Список опубликованных пакетов:"
echo "   • plus_shell_executor"
echo "   • plus_shell_uikit"
echo "   • plus_parse_app_package"
echo "   • plus_flutter_app_builder"
echo "   • plus_flutter_app_packager"
echo "   • plus_flutter_app_publisher"
echo "   • plus_unified_distributor"
echo "   • plus_fastforge"
echo "   • plus_flutter_distributor"
echo ""
echo "🔗 Проверьте пакеты на https://pub.dev/"
