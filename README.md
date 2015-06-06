forumapp
========

Spring PostgreSQL Demo Application


```
rhc app create forumapp tomcat-7 postgresql-9.2
````

##Step 1 : Basic Setup##

```
$git rm -rf src pom.xml
$ git commit -am “deleted template project”
$ git remote add upstream -m master https://github.com/shekhargulati/forumapp.git
$ git pull -s recursive -X theirs upstream master
```
## Step 2 : Deploy##

```
$ git push
```
