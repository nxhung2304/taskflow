---
allowed-tools: Read, Grep, Glob, Write, mcp__ide__getDiagnostics
description: Review code against project rules and standards. Use when user asks "review code, review-code issue #11, code review..."
---

## Mục đích
Đọc code từ branch hoặc files, so sánh với `specs/rules/`, ghi feedback vào `specs/comments/[ISSUE-NUMBER]-code-review.md`.

---

## Điều kiện tiên quyết

1. Code phải được implement (branch hoặc files)
2. Rules files phải cập nhật trong `specs/rules/`

---

## Các bước thực hiện

### 1. Xác định issue number & code source
User gọi: `review-code 11` → extract number `11`

Tìm branch hoặc files:
- Branch: `feature/hung-11-calendar-widget`
- Hoặc specific files user cung cấp

### 2. Đọc tất cả rules từ các files sau
```
specs/rules/coding.md    — Naming, folder structure, Riverpod, error handling
specs/rules/flutter.md   — Flutter patterns
specs/rules/design.md    — Design tokens, colors, typography
specs/rules/clean-code.md — Code quality
```
Kiểm tra xem đã tuân theo quy tắc chưa ?


**🧪 No Warnings**
- [ ] `flutter analyze` = 0 warnings?
- [ ] No unused imports?
- [ ] No unused variables?
- [ ] No unused parameters?

### 7. Tạo specs/comments/[ISSUE-NUMBER]-code-review.md

```markdown
---
GitHub Issue: #11
Issue Title: Calendar Widget
Review Date: YYYY-MM-DD
Type: Code Review
Reviewer: Claude Code
---

## **Code Summary**
[Tóm tắt files/components được implement]

## **✅ What's Good**
- Folder structure correct
- Riverpod providers properly structured
- Widget extraction appropriate
- Consistent naming conventions

## **🚨 Critical Issues** (Must fix)

### Issue 1: [Title]
**Location:** `lib/features/calendar/presentation/screens/calendar_screen.dart:42`
**Problem:** Hardcoded color `Color(0xFF4CAF50)` instead of `AppColors.primary`
**Rule:** specs/rules/coding.md — Constants
**Fix:** Replace with `AppColors.primary`

### Issue 2: [Title]
...

## **⚠️ Code Quality Issues** (Nice to have)

### Issue 1: [Title]
**Location:** `lib/features/calendar/providers/calendar_provider.dart:15`
**Problem:** Method `_buildCalendar()` > 50 lines, should extract as widget
**Rule:** specs/rules/coding.md — Widgets
**Suggestion:** Extract to `CalendarGridWidget`

### Issue 2: [Title]
...

## **📊 Code Quality Score**

| Category | Status | Notes |
|----------|--------|-------|
| **Structure** | ✅/❌ | Folder organization |
| **Naming** | ✅/❌ | Conventions followed |
| **Riverpod** | ✅/❌ | Provider pattern |
| **Widgets** | ✅/❌ | Widget extraction |
| **Constants** | ✅/❌ | No hardcoding, colors/spacing via constants |
| **Magic Numbers** | ✅/❌ | ALL numbers extracted to named constants? |
| **Strings** | ✅/❌ | i18n proper, no hardcoded strings |
| **Imports** | ✅/❌ | Order & style |
| **flutter analyze** | ✅/❌ | 0 warnings? |

**Overall: X/10**

## **📋 Rule Compliance**

✅ Follows: `specs/rules/coding.md`
✅ Follows: `specs/rules/flutter.md`
❌ Violates: `specs/rules/clean-code.md` (magic numbers)

## **✍️ Action Items**
- [ ] Fix critical issues (2 items)
- [ ] Address code quality (3 items)
- [ ] Run `flutter analyze` & confirm 0 warnings
- [ ] Run `flutter test` & ensure all pass

## **Status**
- [ ] NEEDS_FIX — Critical issues found
- [ ] READY_TO_MERGE — Code meets standards
```

### 8. Output to console
```
✅ Code Review Complete

📄 File: specs/comments/011-code-review.md
📊 Violations:
   🚨 Critical: X issues (must fix)
   ⚠️ Quality: X suggestions
   ✅ Compliance: X/10

🏷️ Rules Coverage:
   ✅ coding.md
   ✅ flutter.md
   ❌ clean-code.md (3 issues)

⏭️ Next Step:
   Fix critical issues, re-review, then merge
```

---

## Lỗi & Xử lý

| Lỗi | Xử lý |
|-----|-------|
| Branch/files không tồn tại | Dừng, thông báo không tìm thấy |
| `flutter analyze` có warning | Report all warnings, block merge |
| Tests fail | List failing tests, block merge |
| Hardcoded values | List each location, mark critical |
| Naming violation | Suggest correct name |

---

## Quy tắc quan trọng

- **Critical:** Hardcoded values, not following core patterns (Riverpod, Result, error handling)
- **Nice-to-have:** Code style, widget extraction, naming edge cases
- **Location:** Always mention file + line number for easy fixing
- **Rule Reference:** Always cite which rule is violated
- **Tone:** Constructive, explain WHY rule exists
- **Block merge:** Only if critical issues or `flutter analyze` warnings

---

## **🔍 Magic Number Detection Checklist** (from clean-code.md)

STRICTLY scan all code for EVERY hardcoded number. Check:

### Numbers to FLAG (ALWAYS):
- [ ] Comparison operators: `if (x > 5)`, `if (x >= 18)`, `if (x < 3)` → Extract to constant
- [ ] Array/list indices: `array[0]`, `list[7]`, `weekday == 6 || weekday == 7` → Extract to constant
- [ ] Loop ranges: `List.generate(7, ...)`, `for (int i = 0; i < 10; i++)` → Extract to constant
- [ ] Calculations: `x / 7`, `x * 24`, `y - 1` → Extract to constant with meaningful name
- [ ] UI dimensions: `width: 28`, `height: 28`, `size: 18`, `padding: 2` → Use AppSpacing/constants
- [ ] Hardcoded strings: `'Hôm nay'`, `'Error'` → Use Strings class (NOT critical but flag)

### Context matters - These are OK ONLY in specific cases:
- ✅ Loop counter: `for (int i = 0; i < items.length; i++)` — `i` is fine
- ✅ Offsets in comments: `// Return first 3 items` with magic `3` — OK if explained
- ❌ Everything else → Extract to named constant

### Examples of what to FLAG:
```dart
// ❌ BAD - flag these
if (items.length > 5) { }  // Magic: 5
final rows = (total / 7).ceil();  // Magic: 7
width: 28, height: 28  // Magic: 28 (should be const)
date.weekday == 6 || date.weekday == 7  // Magic: 6, 7
padding: EdgeInsets.all(2)  // Magic: 2 (should be AppSpacing.xs)
List.generate(7, ...)  // Magic: 7 (should be const _daysPerWeek)
index >= 5  // Magic: 5 (should be const _weekendStartIndex)
```

### Examples of correct fixes:
```dart
// ✅ GOOD - extracted constants
const int maxStatusLength = 5;
const int daysPerWeek = 7;
const double buttonSize = 28;

if (items.length > maxStatusLength) { }
final rows = (total / daysPerWeek).ceil();
width: buttonSize, height: buttonSize
```

---

## **How to check systematically:**

1. Use Grep to find all numbers in code:
   - `grep -n "[0-9]" file.dart` (look for digit patterns)
   - Focus on: `= [0-9]`, `> [0-9]`, `< [0-9]`, `== [0-9]`
   - Check lines with: `width:`, `height:`, `size:`, `padding:`, `.generate(`, `[]`

2. For each number found, ask:
   - "Is this a meaningful constant?" → If YES, should be named
   - "Does this appear multiple times?" → If YES, should be constant
   - "Can the value change?" → If YES, should be constant
   - "Is this domain knowledge?" → If YES (like 7=week), should be constant

3. If any of above = YES → Flag as magic number

**STRICT RULE:** If you find ANY hardcoded number that could be a constant, FLAG IT.
