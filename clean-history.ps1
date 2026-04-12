# Git 仓库隐私信息清理脚本
# 使用方法：在仓库根目录运行 .\clean-history.ps1

Write-Host "开始清理 Git 历史中的敏感信息..." -ForegroundColor Yellow

# 1. 首先清理 _private 文件夹从 git 历史中
Write-Host "步骤 1: 从历史中移除 _private 文件夹..." -ForegroundColor Cyan
git filter-branch --force --index-filter `
    "git rm -rf --cached --ignore-unmatch _private" `
    --prune-empty --tag-name-filter cat -- --all

# 2. 清理特定文件的敏感内容（可选，如果需要更彻底的清理）
Write-Host "步骤 2: 清理 about/index.md 中的邮箱..." -ForegroundColor Cyan
git filter-branch --force --tree-filter `
    "if (Test-Path 'about/index.md') { `(Get-Content 'about/index.md' -Raw) -replace '- \*\*Email\*\*:.*', '' | Set-Content 'about/index.md' }" `
    --prune-empty --tag-name-filter cat -- --all

# 3. 清理 refs 和备份
Write-Host "步骤 3: 清理备份引用..." -ForegroundColor Cyan
rm -rf .git/refs/original/
git reflog expire --expire=now --all

# 4. 垃圾回收
Write-Host "步骤 4: 执行垃圾回收..." -ForegroundColor Cyan
git gc --prune=now --aggressive

Write-Host "`n清理完成！" -ForegroundColor Green
Write-Host "`n重要提示:" -ForegroundColor Red
Write-Host "1. 请检查本地仓库是否正常：git log"
Write-Host "2. 强制推送到远程仓库：git push origin --force --all"
Write-Host "3. 同时更新标签：git push origin --force --tags"
Write-Host "`n警告：强制推送会改写远程历史，请确保只有你使用此仓库！" -ForegroundColor Yellow
