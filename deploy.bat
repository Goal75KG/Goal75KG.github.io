@echo off
echo Start
git add .
git commit -m "backup"
git push origin hexo
hexo g
TIMEOUT /T 3
hexo d
echo Finish
echo 按任意键继续...
pause >nul