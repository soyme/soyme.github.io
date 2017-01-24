---
layout: post
title: Git 기본 명령어
category: blog
tags: [git]
---
### 파일의 상태
- untracked : Git의 관리 대상이 아닌 파일.
- (tracked) unstaged : Git의 관리 대상임. 그런데 stage area에 아직 반영되지 않은 변경사항이 존재한다.
- (tracked) staged : Git의 관리 대상임. 변경사항이 stage area에 반영되었다. 그러나 아직 커밋된 것은 아니다. stage area란, 커밋을 날리면 반영될 변경사항들이 저장되어 있는 일종의 스냅샷이다.


### 기존의 디렉토리를 Git 저장소로 만들기
기존에 존재하던 프로젝트를 Git으로 관리하고 싶을 때

1. 프로젝트의 루트 디렉토리로 이동
2. `git init` 입력
 - `/.git` 이라는 하위 디렉토리가 만들어지고, 그 안에 설정파일들이 생긴다.
 - 이 때 까지는 어떤 파일도 관리 대상이 아니다. 즉 모든 파일이 untracked 상태이다. add & commit을 해줘야 관리 대상이 된다.
3. `git add 파일명`
 - git add 명령어는 두 가지 일을 한다. 해당 파일이 untracked 상태였다면 tracked 상태로 만든다. 그리고 해당 파일이 untracked 였던 tracked 였던, staged 상태로 만든다. 즉 새로운 파일을 관리 대상에 추가하고자 할 때, 그리고 수정한 파일을 stage area에 추가하고자 할 때 git add를 사용한다.
 - `git add *`, `git add *.java` 등과 같이 와일드카드 문자를 사용할 수 있다.
4. `git commit -m "커밋 메시지"`
 - stage area의 최종 스냅샷이 로컬 저장소에 커밋된다.


### 기존 저장소를 clone 하기
이미 존재하는 원격 저장소를 로컬 저장소로 가져오고자 할 때

1. 원하는 루트 디렉토리로 이동
2. `git clone 저장소url [디렉토리명]`
 - 예) git clone git://github.com/schacon/grit.git 
 - 새로운 디렉토리가 생성되고 그 안에 .git 디렉토리가 생긴다. 디렉토리명을 지정하지 않은 경우 프로젝트명(예: `grit`)과 동일하게 생성된다.
 - clone 명령은 원격 저장소의 모든 데이터를 가져와서 모두 저장하고, 자동으로 가장 최신버전의 master 브랜치를 checkout 해놓는다.
 - 처음 clone을 하면 모든 파일은 tracked 이고 unmodifed 이다.
3. 특정 브랜치를 clone 하고 싶은 경우, `git clone -b 브랜치명 저장소url [디렉토리명]`


### 파일 상태 확인하기
`git status`를 입력하면 현재 작업 중인 브랜치가 무엇이고, 어떤 상태인지 볼 수 있다. 또한 어떤 파일이 새로 생성되었고, 변경되었고 삭제되었는지 볼 수 있다.

```shell
$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)
	modified:   file1.txt
	new file:   file2.txt

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)
	modified:   file3.txt

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	file4.txt
```

한 줄 씩 살펴보자면..

- `On branch master` : 현재 작업중인 브랜치의 이름은 master 임
- `Your branch is up-to-date with 'origin/master'` : 현재 브랜치는 origin 이라는 이름의 remote 저장소의 master 브랜치를 바라보고 있으며, 최신 상태임.
- `Changes to be committed:` : staged 상태의 파일 목록. 쉽게 말하면 커밋될 후보들이다. 이 상태에서 commit을 날리면 해당 파일들의 최종 스냅샷이 커밋된다. 만약 파일을 unstaged로 되돌리고 싶다면, 즉 커밋 후보에서 제외시키려면 `git reset HEAD 파일명` 명령어를 사용한다.
- `Changes not staged for commit:` : 변경사항이 존재하지만 unstaged 상태인 파일 목록. 이 파일들을 커밋시 포함시키고 싶다면 `git add 파일명`을 해야한다. 혹은 변경사항을 날려버리고, 최신 커밋 버전으로 되돌리고 싶다면 `git checkout -- <file>` 명령어를 사용한다.
- `Untracked files:` : Git의 관리 대상이 아닌 파일 목록. `git add`를 하면 관리 대상이 되고, staged 상태가 된다.


### 파일을 staged 상태로 변경하기 
`git add 파일명` or `git add 디렉토리명` or `git add *` 등.. git add 명령어는 untracked 파일을 새로 추적할 때도 사용하고, tracked & modified 파일을 staged 상태로 만들 때도 사용한다.

1. untracked 파일을  git add하는 경우: tracked & staged 상태로 변경된다.
 - untracked 파일이 tracked & staged 상태로 바뀜 (changes to be committed)
 - 이 후 commit을 하면, git add를 실행한 시점의 파일이 저장소에 커밋됨.
2. tracked 파일을 git add하는 경우: staged 상태로 변경된다.
 - 이미 tracked인 파일을 수정하면 modifed 상태가 됨. (changed but not update)
 - modifed 파일을 add하면 tracked & staged 상태로 바뀜 (changed to be commited)
3. 참고) 새로운 파일을 git add 하여 staged 상태로 만들고, 이 파일을 다시 수정한 후 git status 해보면..
 - changed to be committed, changed but not updated 둘 다에 해당 파일이 나온다.
 - 이 시점에서 커밋을 하면 마지막으로 add 한 시점의 파일이 커밋되는 것임.
 - 즉 add의 의미는 파일을 다음 커밋에 추가한다는 의미임.
 - 최근 변경분까지 커밋되게 하고 싶으면 다시 git add 를 날리면 된다.


### 특정 파일 무시하기
untracked를 유지하고 싶은 파일 패턴을 `.gitignore` 파일에 적을 수 있다. 로그파일, 임시파일, IDE 설정파일 등..

 - `!a` : 느낌표로 시작한 패턴의 파일은 무시하지 않는다
 - `*.a`, `!lib.a` : 확장자가 a인 파일은 다 무시하나 lib.a는 무시하지 않는다
 - `/TODO` : 루트 디렉토리에 위치하는 TODO 라는 파일을 무시
 - `TODO/` : TODO라는 이름의 디렉토리 내에 있는 모든 파일을 무시 


### 파일 변경 내용 확인하기

`git diff` 명령어를 사용하면 어떤 파일의 내용이 어떻게 변경 되었는지 확인할 수 있다.

- 작업하고 있는 디렉토리와 staging area에 있는 내용을 비교해서 보여준다. 즉 수정하고 아직 add (staged) 하지 않은 것, unstaged 상태인 내용을 보여준다. 즉 수정한 파일을 전부 add (staged) 하였다면 변경사항이 없다고 나온다.

`git diff --staged` or `git diff --cached`

- 로컬 저장소의 최신 파일과 staging area에 있는 내용을 비교해서 보여준다. 즉 현재 시점에서 commit을 했을 때 로컬 저장소에 반영될 내용을 보여준다.


### 파일 커밋하기
`git commit` 명령어를 수행하면 staging area에 있는 스냅샷의 내용을 로컬 저장소에 저장한다. 

- `git add`를 수행한 이후에 수정된 내용은 반영되지 않는다. git commit 명령어를 입력하면 커밋 메시지를 작성하기 위한 에디터가 열린다. 
- `git commit -m 커밋메시지` : 커밋 명령어와 메시지 작성을 한 번에 끝낼 수 있다.
- `git commit -v` : 커밋 메시지에 git diff 내용을 추가하여 커밋 
- `git commit -a`  : staging area를 생략하고 바로 커밋한다. tracked 상태인 파일을 자동으로 staging area에 넣은 후 커밋해주므로, git add를 실행하는 수고를 덜 수 있다.
- `git commit --amend` : 바로 직전에 했던 커밋에 이번에 하는 커밋을 덮어씌운다. 실수로 파일 한 두개를 빠뜨렸거나, 커밋 메시지를 다시 작성하고 싶을 때 주로 사용한다.
- `git commit --amend --reset-author` or `git commit --amend --author "so <so@so-blog.net>"`: author 변경


### 파일 삭제하기
`git rm 파일명` 명령어를 수행하면, 해당 파일을 staging area 및 작업중인 디렉토리에서 삭제한다.

```shell
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)
	deleted:   file
```
- `git rm` 후에 `git status`를 확인해보면, 해당 파일의 상태가 위와 같이 changed to be comitted (staged) 이다. 이 상태에서 커밋을 하면 staging area에서 삭제가 되고, git은 더이상 이 파일을 추적하지 않는다.
- `git rm`을 사용하지 않고 워킹 디렉토리에서 직접 파일을 삭제하면, changed but not update (unstaged) 상태가 된다.
- `git rm --cached 파일명` : 워킹 디렉토리에 있는 파일은 지우지 않고, staging area에서만 삭제한다. (tracked 상태였던 파일을 ignore 하고 싶을 때 사용)


### 파일 이름 변경하기
`git mv 이전파일명 새로운파일명`

 - tracked 상태였던 파일의 이름을 바꾸고 싶을 때 사용한다.
 - `git rm 이전파일명` 실행 후에 `git add 새로운파일명`을 실행하는 것과 결과는 동일하다.
