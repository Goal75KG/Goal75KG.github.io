echo "Start"
git add .
git commit -m backup
git push origin hexo
hexo g
hexo d
echo "Finish"
echo 按任意键继续
read -n 1