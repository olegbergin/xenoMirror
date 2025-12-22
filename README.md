# 🛸 Project XenoMirror (Windows Native Edition)

**Version:** 1.1 (Windows Migration)
**Status:** Pre-production / Prototyping
**Target Platform:** Android (ARM64/ARMv7)
**Core Concept:** "The Mirror Soul" — RPG Habit Tracker with Procedural AI Evolution.

---

## 1. High Concept

**XenoMirror** is a gamified self-improvement app where the user nurtures a digital entity—an alien mimic found in a cryo-pod.
Unlike standard virtual pets, **you do not feed it virtual food. You feed it your real-life habits.**

The creature is a **mirror of your lifestyle**:

- **Action:** You work out → The creature grows cybernetic/muscular legs.
- **Action:** You read books → The creature develops a "Third Eye" or Halo.
- **Inaction:** You neglect yourself → The creature's light fades, and it becomes glitchy.

**The Hook:** "Don't just level up a character. Build a better version of yourself, and watch it come alive."

---

## 2. Technical Architecture (New)

Мы отказались от Docker в пользу нативной разработки под Windows, чтобы избежать проблем с `il2cpp.exe` и драйверами GPU.

### 2.1 Структура Папок

Проект организован так, чтобы плагин `flutter_unity_widget` мог автоматически находить исходники.

```text
D:\xenoMirror\
└── client_app\                 <-- КОРЕНЬ FLUTTER ПРОЕКТА
    ├── android\
    │   ├── app\
    │   ├── unityLibrary\       <-- [GENERATED] Экспорт из Unity (НЕ РЕДАКТИРОВАТЬ ВРУЧНУЮ)
    │   ├── build.gradle.kts    <-- Настройки сборки (NDK Fix тут)
    │   └── settings.gradle.kts <-- Подключение модуля :unityLibrary
    ├── lib\
    │   └── main.dart           <-- Flutter UI код
    ├── unity\
    │   └── xeno_unity\         <-- ИСХОДНИКИ UNITY (Сцены, C# скрипты)
    └── pubspec.yaml

```

### 2.2 Stack

- **App UI:** Flutter (Dart) — Оболочка, интерфейс, навигация.
- **3D Core:** Unity 2022.3 LTS (URP) — Рендер существа и окружения.
- **Bridge:** `flutter_unity_widget` (master branch).
- **Vision AI:** Google ML Kit (On-device).
- **Backend:** Supabase + OpenAI (GPT-4o-mini).

---

## 3. Environment Setup (Windows)

Для успешной сборки требуются конкретные версии инструментов.

1. **Flutter SDK:** 3.x (Stable).
2. **Visual Studio 2022:**

- Workload: _Desktop development with C++_ (Обязательно для компиляции на Windows).

3. **Android Studio:**

- SDK Platform: Android 13+ (API 33+).
- SDK Tools: **Android SDK Command-line Tools**.
- **NDK (Critical):** Требуется установка двух версий (Side-by-side):
- `23.1.7779620` (Для Unity IL2CPP).
- `27.0.12077973` (Для Flutter плагинов).

---

## 4. Build Pipeline (Инструкция по сборке)

### Step 1: Подготовка Unity (Ядро)

1. Открыть проект `client_app/unity/xeno_unity` в Unity Hub (2022.3 LTS).
2. Перейти в **File -> Build Settings**.
3. Платформа: **Android**.
4. Галочка **Export Project**: [x] **ВКЛЮЧЕНА**.
5. Нажать **Export**.
6. Путь экспорта: `client_app/android`.

- _Unity создаст или обновит папку `unityLibrary` внутри `android`._

### Step 2: Подготовка Flutter (Оболочка)

1. Открыть терминал в `client_app/`.
2. Обновить зависимости:

```powershell
flutter pub get

```

3. **ВАЖНО:** Подключить реальный Android-телефон по USB (Режим отладки включен).

- _Эмуляторы x86_64 не поддерживаются Unity по умолчанию (будет ошибка `dlopen failed: library not found`)._

### Step 3: Запуск

```powershell
flutter run

```

---

## 5. Communication Bridge (Связь)

### Flutter (Отправка)

```dart
// Отправляет сообщение объекту "Cube" вызвать метод "ChangeColor" с аргументом "red"
_unityWidgetController?.postMessage('Cube', 'ChangeColor', 'red');

```

### Unity (Прием)

Скрипт должен висеть на объекте, имя которого совпадает с первым аргументом в `postMessage`.

```csharp
public void ChangeColor(string message) {
    if (message == "red") GetComponent<Renderer>().material.color = Color.red;
}

```

---

## 6. Game Mechanics & Lore

### 6.1 Narrative

**Role:** You are the Custodian. The creature has no context of Earth. It learns by observing _you_.
**Evolution:**

- _Phase 1:_ The Stranger (Cold, analytical).
- _Phase 2:_ The Student (Curious, mimicking).
- _Phase 3:_ The Symbiont (Empathetic, "best self").

### 6.2 RPG System (S.P.E.C.I.A.L.)

| Attribute    | Input (Habits)           | Visual Output (Body Part)                    | Archetype |
| ------------ | ------------------------ | -------------------------------------------- | --------- |
| **VITALITY** | Sports, Sleep, Nutrition | **Legs & Core.** (Thrusters, Armor, Muscles) | Titan     |
| **MIND**     | Reading, Study, Planning | **Head & Sensors.** (Halos, Optics, Runes)   | Psionic   |
| **SOUL**     | Hobbies, Art, Meditation | **Arms & Aura.** (Tools, Colors, Particles)  | Creator   |

### 6.3 Visual Style

- **"Rayman" Architecture:** Floating parts to avoid rigging issues.
- **"Charge Up" Shader:** Visual progression via PBR Shader Graph (Emission glow increases with XP).

---
