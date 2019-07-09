#git add ./ 
#git commit -a
#git rm cc*
git add ./
git commit -m 'remove cc* '
git remote rm origin
git remote add origin "git@github.com:msd-model/rafs.git"
git pull origin test_xuhx 
git push -u origin test_xuhx 


