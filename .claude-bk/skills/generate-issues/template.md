## **Status:**
- Review: Pending / Approved
- PR: Todo / Draft / Merged

## Metadata
- **Title:** [title]
- **Phase:** [phase number & name]
- **GitHub Issue:** (to be filled after sync)

---

## Description
[Mô tả ngắn gọn story này làm gì, mục đích là gì]
[Xuống dòng cho mỗi ý]
Example:
- Step 1
- Step 2

---

## Design
- File: `specs/designs/[file].html`
- Màn hình: [tên màn hình cụ thể trong file HTML]
- Example:
    - Timesheet screen
    - Design: specs/designs/timesheet/list.html

---

## Acceptance Criteria
- [ ] [Tiêu chí cụ thể, có thể test được]
- [ ] [...]

---

## Implementation Checklist
- [ ] Tạo file structure
- [ ] Implement UI theo wireframe trong `specs/designs/`
- [ ] Extract widget nếu > 50 lines
- [ ] Thêm const constructors
- [ ] Thêm TODO comment cho data placeholder
- [ ] flutter analyze — 0 warnings
- [ ] Viết widget test cơ bản

---

## Notes
[Ghi chú thêm, edge cases, dependencies với story khác]

## Screenshots
<!-- Describe screens to capture after implementing this issue -->
<!-- The QA skill will use this to navigate and screenshot automatically -->

| Screen Name | Navigation Steps | Expected State |
|---|---|---|
| [screen-name] | [how to get there: tap X, swipe, etc.] | [what should be visible] |

Example:
```
| Screen Name | Navigation Steps | Expected State |
|---|---|---|
| home | App launches on Home tab | AppBar shows "Trang chủ", status bar visible |
| timesheet | Tap "Chấm công" in bottom nav | AppBar shows "Chấm công", safe area OK |
| leave | Tap "Nghỉ phép" in bottom nav | AppBar shows "Nghỉ phép" |
| setting | Tap "Cài đặt" in bottom nav | AppBar shows "Cài đặt" |
```
