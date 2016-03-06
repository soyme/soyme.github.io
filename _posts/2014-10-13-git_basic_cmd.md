---
layout: post_page
title: Git 기본 명령어
tag: Git
---

### 기존의 디렉토리를 Git 저장소로 만들기
기존의 프로젝트를 Git으로 관리하고 싶을 때

1) 프로젝트의 루트 디렉토리로 이동
2) git init
-  .git 이라는 하위 디렉토리가 만들어지고, 그 안에 설정파일이 생긴다.
- 이 때 까지는 어떤 파일도 관리 대상이 아니며(untracked), add & commit을 해야 관리 대상이 된다.
3) git add 파일명 
- 해당 파일이 저장소에 추가된다. (tracked)
- 예) git add * : 디렉토리 내의 모든 파일을 stage area에 추가 (staged)
- 예) git add *.java : 디렉토리 내의 확장자가 java인 모든 파일을 stage area에 추가
4) git commit -m "커밋 메시지" 
- stage area의 스냅샷이 저장소에 저장된다. (commited)


### 기존 저장소를 clone 하기

이미 존재하는 원격 저장소를 로컬 저장소로 가져오고자 할 때


1) 원하는 루트 디렉토리로 이동
2) git clone 저장소url [디렉토리명]
- 예) git clone git://github.com/schacon/grit.git 
- 새로운 디렉토리가 생성되고 그 안에 .git 디렉토리가 생긴다. 디렉토리명을 지정하지 않은 경우 프로젝트명과 동일하게 생성된다. (예: grit)
- clone 명령은 원격 저장소의 데이터를 모두 가져와서 저장하고, 자동으로 가장 최신버전을 checkout 해놓는다.
- 처음 clone을 하면 모든 파일은 tracked 이고 unmodifed 이다.


### 파일 상태 확인하기

git status
- 현재 작업 중인 브랜치가 무엇이고, 어떤 상태인지 보여준다.
- 어떤 파일이 변경되었는지 보여준다. untracked 상태의 파일과, staged 상태의 파일을 확인 가능하다.


### 파일을 staged 상태로 변경하기 

git add 파일명or디렉토리명
- untracked 파일을 새로 추적할 때도 사용하고, tracked & modified 파일을 staged 상태로 만들 때도 사용한다.

1. untracked 파일을  git add하는 경우: tracked & staged 상태로 변경된다.
- untracked 파일이 tracked & staged 상태로 바뀜 (changes to be committed)
- 이 후 commit을 하면, git add를 실행한 시점의 파일이 저장소에 커밋됨.

2. tracked 파일을 git add하는 경우: staged 상태로 변경된다.
- 이미 tracked인 파일을 수정하면 modifed 상태가 됨. (changed but not update)
- modifed 파일을 add하면 tracked & staged 상태로 바뀜 (changed to be commited)

예) 새로운 파일을 add하여 staged로 만들고, staged 상태의 파일을 다시 수정한 후 git status 해보면
- changed to be committed, changed but not updated 둘 다에 해당 파일이 나온다.
- 이 시점에서 커밋을 하면 마지막으로 add 한 시점의 파일이 커밋되는 것임.
- 즉 add의 의미는 파일을 다음 커밋에 추가한다는 의미임.
- 최근 변경분까지 커밋되게 하고 싶으면 다시 git add  하면 된다.


### 특정 파일 무시하기

.gitignore 파일
- untracked를 유지하고 싶은 파일 패턴을 .gitignore 파일에 적을 수 있음. 로그파일, 임시파일, IDE 설정파일 등..
- 디렉토리 전체를 무시할 때는 "디렉토리명/"
- 느낌표로 시작한 패턴의 파일은 무시하지 않는다는 의미이다.

*.a
!lib.a
- 위와 같이 적으면 확장자가 a인 파일은 다 무시하나 lib.a는 무시하지 않음

/TODO
- 위와 같이 적으면 루트 디렉토리에 위치하는 TODO 라는 파일을 무시

TODO/
- 위와 같이 적으면 TODO라는 이름의 디렉토리 내에 있는 모든 파일을 무시 


### 파일 변경 내용 확인하기

git diff
- 어떤 내용이 변경 되었는지 확인
- 워킹 디렉토리와 staging area에 있는 내용을 비교한다. 즉 수정하고 아직 add (staged) 하지 않은 것, unstaged 상태인 내용을 보여준다.
- 수정한 파일을 전부 add (staged) 하였다면 변경사항이 없는 것임.

git diff --staged   /  git diff --cached
- 로컬 저장소의 최신 파일과 staging area에 있는 내용을 비교함
- 현재 시점에서 commit을 했을 때 로컬 저장소에 반영될 내용을 보여준다.


### 파일 커밋하기
git commit (-m "커밋 메시지")
- staging area에 있는 스냅샷을 저장소에 저장, add한 이후에 수정된 내용은 반영되지 않음(unstaged 이므로)

git commit -v
- 커밋 메시지에 git diff 내용을 추가하여 커밋 

git commit -a
- staging area를 생략하고 바로 commit
- tracked 상태인 파일을 자동으로 staging area에 넣은 후 커밋해주므로, git add를 실행하는 수고를 덜 수 있음


### 파일 삭제하기

git rm 파일명
- tracked 상태인 파일을 staging area & 워킹 디렉토리에서 삭제
- git rm 하면 changed to be comitted (staged) 상태가 됨. 그리고 커밋을 하면 git은 이 파일을 더이상 추적하지 않음.
- 이렇게 안하고 워킹디렉토리에서 그냥 파일을 삭제하면 changed but not update(unstaged) 상태가 됨

git rm --cached 파일명
- 워킹디렉토리에 있는 파일은 지우지 않고, staging area에서만 ㅈ거 (ignore하고 싶을 때 사용)


### 파일 이름 변경하기

git mv 이전파일명 새로운파일명
- tracked였던 파일의 이름을 바꾸고 싶을 때
- git rm 이전파일명 -> git add 새로운파일명 과 결과는 동일하다.
