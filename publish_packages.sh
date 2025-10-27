#!/bin/bash

# Скрипт для публикации пакетов на pub.dev в правильном порядке
# Использование: ./publish_packages.sh

# set -e  # Остановить при ошибке (отключено для корректной работы с функциями)

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

# Счетчики
published_count=0
skipped_count=0
total_packages=9

# Функция для проверки, опубликована ли уже версия пакета
check_package_version() {
    local package_name=$1
    local version=$2
    
    echo "   🔍 Проверяем, опубликована ли версия $version пакета $package_name..."
    
    # Используем pub.dev API для проверки версии
    local response=$(curl -s "https://pub.dev/api/packages/$package_name" 2>/dev/null || echo "")
    
    if [ -z "$response" ]; then
        echo "   ⚠️  Не удалось проверить статус пакета $package_name (возможно, пакет не существует)"
        return 1  # Пакет не существует, можно публиковать
    fi
    
    # Проверяем, есть ли нужная версия в ответе
    if echo "$response" | grep -q "\"version\":\"$version\""; then
        echo "   ✅ Версия $version пакета $package_name уже опубликована"
        return 0  # Версия уже существует
    else
        echo "   📝 Версия $version пакета $package_name не найдена, можно публиковать"
        return 1  # Версии нет, можно публиковать
    fi
}

# Функция для получения версии из pubspec.yaml
get_package_version() {
    local package_path=$1
    
    # Извлекаем версию из pubspec.yaml
    local version=$(grep "^version:" "$package_path/pubspec.yaml" | sed 's/version: *//' | tr -d ' ')
    
    echo "$version"
}

# Функция для публикации пакета
publish_package() {
    local package_name=$1
    local package_path=$2
    
    echo "📦 Обрабатываем $package_name..."
    echo "   Путь: $package_path"
    
    cd "$package_path"
    
    # Проверяем, что pubspec.yaml существует
    if [ ! -f "pubspec.yaml" ]; then
        echo "❌ Ошибка: pubspec.yaml не найден в $package_path"
        exit 1
    fi
    
    # Получаем версию пакета из текущей директории
    local version=$(grep "^version:" pubspec.yaml | sed 's/version: *//' | tr -d ' ')
    echo "   📋 Версия: $version"
    
    # Проверяем, не опубликована ли уже эта версия
    if check_package_version "$package_name" "$version" 2>/dev/null; then
        echo "   ⏭️  Пропускаем $package_name v$version (уже опубликован)"
        ((skipped_count++))
        echo ""
        cd - > /dev/null
        return 0
    fi
    
    # Проверяем, что пакет готов к публикации
    echo "   🔍 Проверяем пакет..."
    if ! fvm flutter pub publish --dry-run; then
        echo "❌ Ошибка: Пакет $package_name не готов к публикации"
        exit 1
    fi
    
    # Публикуем пакет
    echo "   📤 Публикуем пакет..."
    local publish_output
    if publish_output=$(fvm flutter pub publish --force 2>&1); then
        echo "✅ $package_name v$version успешно опубликован!"
        ((published_count++))
    else
        # Проверяем различные типы ошибок
        if echo "$publish_output" | grep -q "already exists"; then
            echo "   ⏭️  Версия $version пакета $package_name уже существует, пропускаем"
            ((skipped_count++))
        elif echo "$publish_output" | grep -q "rate limit has been reached"; then
            echo "   ⏸️  Достигнуто ограничение скорости публикации на pub.dev"
            echo "   ⏰ Подождите 10-15 минут и попробуйте снова"
            echo "   📋 Оставшиеся пакеты:"
            echo "      • $package_name"
            # Показываем оставшиеся пакеты
            local remaining_packages=()
            case "$package_name" in
                "plus_unified_distributor")
                    remaining_packages=("plus_fastforge" "plus_flutter_distributor")
                    ;;
                "plus_fastforge")
                    remaining_packages=("plus_flutter_distributor")
                    ;;
            esac
            for remaining in "${remaining_packages[@]}"; do
                echo "      • $remaining"
            done
            echo ""
            echo "💡 Для продолжения выполните:"
            echo "   ./publish_packages.sh"
            exit 0
        else
            echo "❌ Ошибка при публикации $package_name:"
            echo "$publish_output"
            exit 1
        fi
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

echo "🎉 Публикация завершена!"
echo "=================================================="
echo "📊 Статистика:"
echo "   • Всего пакетов: $total_packages"
echo "   • Опубликовано: $published_count"
echo "   • Пропущено: $skipped_count"
echo ""
echo "📋 Список пакетов:"
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
