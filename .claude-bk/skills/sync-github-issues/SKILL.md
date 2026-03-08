---
allowed-tools: Bash(gh issue *), Bash(gh issue list), Bash(gh repo view *), Bash(gh label create), Bash(gh auth status), Read, Edit, Grep, Write, mcp__github__*, mcp__github__create_issue, mcp__github__list_issues, Bash(gh label create *)
description: Sync local issue files to GitHub Issues. Use when user asks "sync issues to github" or "push issues to github"
---

## Mục đích
Đọc các file trong `specs/issues/`, tạo GitHub Issues tương ứng, sau đó cập nhật `GitHub Issue` number vào từng file.

---

## Điều kiện tiên quyết
- GitHub MCP  → for structured operations (create issue, list issues, create PR)
- GitHub CLI  → for things MCP can't do (labels, advanced queries)


### 1. Kiểm tra GitHub CLI đã auth chưa
1. Call `mcp__github__list_issues` with limit 1
    - If succeeds → MCP auth is OK
    - If fails → tell user to set GITHUB_PERSONAL_ACCESS_TOKEN
2. If skill needs labels: run `gh auth status`
    - If fails → tell user to run `gh auth login`
    - If succeeds → proceed

---

## Các bước thực hiện

### 1. Tìm các file cần sync

Scan toàn bộ specs/issues/*.md, chỉ xử lý file thỏa mãn CẢ HAI điều kiện:
- Có: **Status:** approved
- Có: **GitHub Issue:** (to be filled after sync)

→ Bỏ qua: status pending, draft, hoặc đã có issue number

### 2. Với mỗi file → tạo GitHub Issue

Parse từ file:
- **Title** → `## Metadata > Title`
- **Phase** → `## Metadata > Phase` → dùng làm label
- **Body** → giữ nguyên toàn bộ nội dung file markdown

```bash
gh issue create \
  --title "[title]" \
  --body "[nội dung file .md]" \
  --label "phase-[N]"
```

Nếu label chưa tồn tại → tạo trước:
```bash
gh label create "phase-1" --color "#0075ca"
gh label create "phase-2" --color "#e4e669"
gh label create "phase-3" --color "#d93f0b"
gh label create "phase-4" --color "#0e8a16"
gh label create "phase-5" --color "#5319e7"
gh label create "phase-6" --color "#f9d0c4"
gh label create "phase-7" --color "#c2e0c6"
gh label create "phase-8" --color "#bfd4f2"
gh label create "phase-9" --color "#fef2c0"
```

### 3. Lấy issue number từ output

`gh issue create` trả về URL dạng:
```
https://github.com/[owner]/[repo]/issues/42
```
→ Parse số cuối URL → issue number

### 4. Cập nhật file .md

Replace dòng:
```
**GitHub Issue:** (to be filled after sync)
```
Thành:
```
**GitHub Issue:** #42
```

### 5. In summary sau khi xong

```
✅ Đã sync [X] issues lên GitHub:

  #42 — Project Setup
  #43 — Login UI
  #44 — Home Shell
  ...

→ Xem tại: https://github.com/[owner]/[repo]/issues
```

---

## Quy tắc quan trọng

- **KHÔNG** sync file đã có GitHub Issue number — tránh tạo duplicate
- **KHÔNG** xóa hoặc đóng GitHub Issue đã tồn tại
- Nếu `gh issue create` lỗi 1 file → log lỗi, tiếp tục xử lý file tiếp theo, không dừng toàn bộ
- Mỗi file tạo xong → cập nhật ngay, không đợi hết batch

---

## Xử lý lỗi

| Lỗi | Xử lý |
|-----|-------|
| gh chưa auth | Dừng, hướng dẫn `gh auth login` |
| Label tạo bị conflict | Bỏ qua, dùng label đã có |
| issue create thất bại | Log lỗi + skip file đó |
| File .md không parse được title | Skip + cảnh báo tên file |
