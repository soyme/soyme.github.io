---
layout: post
title: Git - 커밋 합치기 (Squash)
category: blog
tags: [git]

---

### squash
- 짓누르다, 납작하게 만들다라는 의미.
- Git에서는 이미 수행한 여러개의 커밋들을 한 개의 커밋으로 합치는 행위를 말한다.

<!-- more -->

### How to squash (their commits)

#### 상황

```
git checkout master
git checkout -b branchA
```

master 브랜치로부터 브랜치 A를 생성했다.

```
// edit something..
git add .
git commit -m "initial commit"

// edit something..
git add .
git commit -m "add file"

// edit something..
git add .
git commit -m "modify file"
```

브랜치 A에 3개의 커밋을 했다.

이 때 브랜치 A에 작업했던 커밋 3개를 마스터 브랜치에 머지하고 싶다. 그러나 3개의 커밋을 한 개로 합쳐서 머지하고 싶다.

#### solution 1. git merge --squash
```
git checkout master
git merge --squash branchA
```

#### solution 2. git rebase -i
```
git checkout branchA
git rebase -i master
```

그러면 이런 화면이 뜬다.

```
pick d9eb73f initial commit
pick 1f4c495 add file
pick 02a3484 modify file

# Rebase 6bdf69c..02a3484 onto 6bdf69c (3 command(s))
#
# Commands:
# p, pick = use commit
# r, reword = use commit, but edit the commit message
# e, edit = use commit, but stop for amending
# s, squash = use commit, but meld into previous commit
# f, fixup = like "squash", but discard this commit's log message
# x, exec = run command (the rest of the line) using shell
# d, drop = remove commit
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
# Note that empty commits are commented out                                              
```

맨 윗부분을 아래와 같이 수정하자.

```
pick d9eb73f initial commit
squash 1f4c495 add file
squash 02a3484 modify file
```

세 개의 커밋 중 첫 번째 커밋은 그대로 유지하고, 두번째와 세번째 커밋을 `pick`이 아닌 `squash`로 변경한다. 합쳐진 커밋의 커밋 메시지는 새로 작성할 수 있다. 만약 첫 번째 커밋의 메시지를 그대로 사용하려면 squash 대신 `fixup`을 사용하면 된다.

### How to squash (our commits)
#### 상황
브랜치 A에 3개의 커밋을 했다. 마스터 브랜치에 머지하기 전에, 이 커밋들을 한 개로 합쳐버리고 싶다.

#### solution 1. git rebase -i
```
git checkout branchA
git rebase -i HEAD~3
```

이후에는 위에서 했던 것과 동일하게 rebase를 진행하면 된다.

#### solution 2. git reset
아예 커밋 자체를 되돌리는 방법.

```
git checkout branchA
git reset --soft HEAD~4
```

그러면 세 개의 커밋이 모두 취소되고, 그 동안 작업했던 내용은 uncommited 상태가 된다.

```
git add .
git commit
```

다시 한번에 커밋.

soft, mixed, hard에 대해서는 [여기](https://git-scm.com/book/ko/v2/Git-%EB%8F%84%EA%B5%AC-Reset-%EB%AA%85%ED%99%95%ED%9E%88-%EC%95%8C%EA%B3%A0-%EA%B0%80%EA%B8%B0)에 아주 잘 나와있다.

만약 이미 remote repository에 push한 커밋에 대해서 변경을 했다면, 그냥 push가 되지 않는다. `git push -f`와 같이 force 옵션을 사용하여야 한다.
