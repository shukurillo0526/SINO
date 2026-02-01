# SINO API Reference

This document provides detailed API documentation for SINO's core services.

## Table of Contents

1. [GeminiService](#geminiservice)
2. [CrisisService](#crisisservice)
3. [MoodController](#moodcontroller)
4. [ConversationService](#conversationservice)
5. [AcademicsService](#academicsservice)
6. [RewardsController](#rewardscontroller)

---

## GeminiService

AI chat service for the SINO companion.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `isInitialized` | `bool` | Whether the service is ready |
| `shouldOfferIntervention` | `bool` | Whether proactive help is needed |
| `pendingInterventionReason` | `String?` | Reason for intervention |

### Methods

#### `getChatResponse(String message)`

Sends a message to the AI and returns a response.

```dart
Future<String> getChatResponse(String message)
```

**Parameters:**
- `message`: User's input text

**Returns:** AI response string

**Example:**
```dart
final response = await geminiService.getChatResponse("Hello!");
print(response); // "Hi there! How can I help? 🦊"
```

#### `checkForProactiveIntervention(...)`

Checks if the user needs proactive support.

```dart
void checkForProactiveIntervention({
  required int upcomingExamCount,
  required MoodLevel? recentMood,
  required int overdueTasks,
})
```

#### `resetSession()`

Clears conversation history.

```dart
void resetSession()
```

---

## CrisisService

Real-time crisis detection and intervention.

### Static Methods

#### `analyzeForCrisis(String text)`

Analyzes text for crisis indicators.

```dart
static RiskLevel? analyzeForCrisis(String text)
```

**Returns:** `RiskLevel.high`, `RiskLevel.medium`, `RiskLevel.low`, or `null`

**Example:**
```dart
final risk = CrisisService.analyzeForCrisis("I feel hopeless");
// Returns: RiskLevel.medium
```

#### `getSafetyInfo(RiskLevel level, bool isEnglish)`

Gets appropriate crisis response.

```dart
static CrisisResponse getSafetyInfo(RiskLevel level, bool isEnglish)
```

**Returns:** `CrisisResponse` with message and action details

---

## MoodController

State management for mood tracking.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `entries` | `List<MoodEntry>` | All mood entries |
| `recentEntries` | `List<MoodEntry>` | Last 20 entries |
| `latestEntry` | `MoodEntry?` | Most recent entry |
| `crisisAlerts` | `List<Map>` | Crisis alert history |

### Methods

#### `addManualMood(MoodLevel mood, {String? context})`

Adds a user-initiated mood entry.

```dart
Future<void> addManualMood(MoodLevel mood, {String? context})
```

#### `addMoodFromService(...)`

Adds mood from external source (games, chat, etc).

```dart
Future<void> addMoodFromService(
  MoodSource source,
  double sentimentScore, {
  String? context,
  Map<String, dynamic>? metadata,
})
```

#### `getWeeklyReport()`

Generates weekly analytics report.

```dart
WeeklyMoodReport getWeeklyReport()
```

**Returns:** `WeeklyMoodReport` with trends and insights

---

## ConversationService

AI conversation memory management.

### Methods

#### `addMemory(...)`

Stores a conversation context item.

```dart
Future<void> addMemory({
  required String topic,
  required String summary,
  MemoryType type = MemoryType.conversation,
  double? emotionalWeight,
})
```

#### `getContextSummary({int maxItems = 5})`

Gets formatted context for AI prompts.

```dart
String getContextSummary({int maxItems = 5})
```

**Returns:** Formatted string of recent memories

#### `clearMemories()`

Clears all stored memories.

```dart
Future<void> clearMemories()
```

---

## AcademicsService

Academic task and schedule management.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `todos` | `List<TodoItem>` | All tasks |
| `completedTodos` | `List<TodoItem>` | Completed tasks |
| `incompleteTodos` | `List<TodoItem>` | Pending tasks |
| `schedule` | `List<ScheduleEntry>` | Class schedule |

### Methods

#### `addTodo(TodoItem item)`

Adds a new task.

```dart
Future<void> addTodo(TodoItem item)
```

#### `toggleTodoComplete(String id)`

Toggles task completion status.

```dart
Future<void> toggleTodoComplete(String id)
```

#### `addScheduleEntry(ScheduleEntry entry)`

Adds a class to the schedule.

```dart
Future<void> addScheduleEntry(ScheduleEntry entry)
```

---

## RewardsController

Points and rewards management.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `points` | `int` | Current point balance |
| `skins` | `List<Skin>` | Available character skins |
| `coupons` | `List<Coupon>` | Available coupons |
| `selectedSkinId` | `String` | Currently equipped skin |

### Methods

#### `addPoints(int amount)`

Awards points to the user.

```dart
void addPoints(int amount)
```

#### `purchaseSkin(String skinId)`

Attempts to purchase a skin.

```dart
bool purchaseSkin(String skinId)
```

**Returns:** `true` if purchase successful

#### `purchaseCoupon(String couponId)`

Attempts to purchase a coupon.

```dart
bool purchaseCoupon(String couponId)
```

---

## Error Handling

All async methods follow this pattern:

```dart
try {
  final result = await service.method();
  // Handle success
} catch (e) {
  debugPrint('Error: $e');
  // Handle gracefully
}
```

## Type Definitions

### MoodLevel

```dart
enum MoodLevel {
  veryHappy,  // +0.8
  happy,      // +0.5
  neutral,    // 0.0
  sad,        // -0.4
  verySad,    // -0.8
  anxious,    // -0.5
  stressed,   // -0.6
}
```

### MoodSource

```dart
enum MoodSource {
  manual,      // Direct user input
  character,   // From SINO chat
  games,       // From game performance
  mindfulness, // From wellness activities
  academics,   // From task completion
  voice,       // From voice notes
}
```

### RiskLevel

```dart
enum RiskLevel {
  low,    // 1-4 points
  medium, // 5-9 points
  high,   // 10+ points
}
```

---

<p align="center">
  <strong>SINO API Reference v1.3.0</strong>
</p>
