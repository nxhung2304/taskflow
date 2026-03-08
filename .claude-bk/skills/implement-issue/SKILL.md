---
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(flutter *), Bash(dart *), Bash(git *), Bash(mkdir *),Bash(slack *), mcp__github__*, mcp__slack__*, Bash(gh pr create *)
description: Implement a feature from a GitHub Issue. Use when user asks "implement issue 1, implement #1,..."
---

## Mục đích
Đọc spec từ GitHub Issue, implement feature theo đúng spec, chạy quality checks, commit, và notify Slack.

---

## Điều kiện tiên quyết
- Ưu tiên dùng MCP Slack và Github, nếu bị lỗi thì dùng fallback là gh và slack cli

### Slack Notification Strategy
- Use `mcp__slack__slack_post_message` tool directly (NOT bash, NOT env var checks)
- Parameters:
- channel_id: "C0AGTJ0EE6B"
- text: [message]
- For replies: use `mcp__slack__slack_reply_to_thread`
- channel_id: "C0AGTJ0EE6B"
- thread_ts: [ts from initial post]
- text: [message]
- DO NOT check for SLACK_API_TOKEN or SLACK_BOT_TOKEN env vars
- DO NOT skip Slack — always attempt the MCP call
- If MCP call fails → log the error and continue (don't block implementation)

### 1. Xác định issue number từ lệnh
User gọi: `implement issue #42` → extract number `42`

### 2. Đọc issue spec
```bash
gh issue view 42 --json title,body,labels
```

### 3. Tìm file spec local tương ứng
```bash
grep -rl "GitHub Issue:** #42" specs/issues/
```
→ Đọc file đó để lấy đầy đủ context: Acceptance Criteria, Implementation Checklist, Wireframe Reference, Notes

### 4. Kiểm tra status file phải là `approved`
Nếu Review là Pending` → dừng lại, thông báo:
```
❌ Issue #42 chưa được Approve. Dev cần đổi Review → Approved trước.
```

---

## Các bước thực hiện

### 0. Pull code
``` bash
git checkout develop
git pull origin develop
```

### 1. Tạo branch mới
```bash
git checkout -b feature/hung-#[issue-number]-[slug-title]
```
Slug từ title: lowercase, space → `-`, bỏ ký tự đặc biệt


### Step 2: Notify Slack — bắt đầu
Use `mcp__slack__slack_post_message`:
- channel: "C0AGTJ0EE6B"
- text: "🚀 Bắt đầu implement *Issue #[N]: [title]*\nBranch: `feature/hung-#[N]-[slug]`"
- Save the returned `ts` value for threading later
If MCP fails → fallback to slack CLI

### 3. Đọc rules trước khi code
Đọc các file sau trước khi viết bất kỳ dòng code nào:
- `specs/rules/coding.md`
- `specs/rules/flutter.md`
- `specs/rules/design.md`

### 3.5. Cross-check colors against HTML design
Before writing any code, if the spec references colors or design tokens:
- Open the relevant HTML design file in `specs/designs/` (referenced in the issue spec)
- Compare hex values in CSS `--variables` against `AppColors` constants in `lib/core/constants/app_colors.dart`
- **HTML design files are the source of truth** for hex values — if `AppColors` disagrees with the HTML, update `AppColors` first
- Also update `specs/rules/design.md` to stay in sync

### 4. Implement theo spec

Làm tuần tự từng item trong `## Implementation Checklist` của file spec:
- Tạo file structure
- Implement UI theo wireframe trong `specs/designs/`
- Extract widget nếu > 50 lines
- Thêm `const` constructors
- Thêm `TODO` comment cho data placeholder
- Tuân thủ conventions trong `specs/rules/`

**Quy tắc khi code:**
- Không implement logic ngoài spec
- Không tự thêm feature
- Nếu spec không rõ → dừng lại, hỏi dev, không tự assume

### 5. Chạy quality checks

```bash
flutter analyze
```
→ Phải đạt **0 warnings, 0 errors** trước khi tiếp tục

```bash
flutter test
```
→ Tất cả tests phải pass

Nếu có lỗi → tự fix trước khi commit, không commit code lỗi

### 6. Commit
```bash
git add .
git commit -m "feat: [title] (#42)"
git push origin feature/issue-42-[slug]
```

### 7. Cập nhật status trong file spec
Sửa dòng status:
```
## **Status:**
- PR: Todo
```
Thành:
```
## **Status:**
- PR: Draft
```

### 8. Cập nhật GitHub Issue label
```bash
gh issue edit 42 --add-label "coding-done"
```

### 9. Tạo Draft PR
```bash
THREAD_TS=$(cat .claude/tmp/thread_${ISSUE_NUMBER}.txt)

gh pr create --draft \
  --title "[title]" \
  --body "## Summary
[Tóm tắt ngắn gọn những gì đã implement]

## Designs
- [Tham chiếu file Designs nếu có trong specs/designs dựa vào tệp specs/issues]

## Changes
[Liệt kê các file/widget đã tạo]

## Issue
Closes #42

<!-- slack-thread-ts: $THREAD_TS -->"
```

### Step 10: Notify Slack — hoàn thành
  Use `mcp__slack__slack_reply_to_thread`:
  - channel: [channel-id]
  - thread_ts: [saved ts from step 2]
  - text: "✅ Code xong — Draft PR đã tạo\nPR: [url]\n @[user-id] review & test nghe"

  If MCP fails → fallback to slack CLI

---

## Quy tắc quan trọng

- **KHÔNG** code ngoài những gì spec mô tả
- **KHÔNG** commit nếu `flutter analyze` còn warning
- Nếu gặp ambiguity → hỏi ngay, không assume
- Mỗi issue = 1 branch riêng, không code trực tiếp trên `main`

---

## Xử lý lỗi

| Lỗi | Xử lý |
|-----|-------|
| Issue không tồn tại | Dừng, thông báo issue number không hợp lệ |
| Status không phải approved | Dừng, nhắc dev đổi status |
| flutter analyze có lỗi | Tự fix, không được skip |
| flutter test fail | Tự fix, không được skip |
| Spec không rõ | Dừng, hỏi dev — không tự assume |
