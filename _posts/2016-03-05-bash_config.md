---
layout: post_page
title: Bash Shell 환경 설정
tag: bash
---

몇몇의 초기화 파일들을 통해 사용자 shell의 환경을 설정할 수 있다.

<!-- more -->

### /etc/profile 파일
`/etc/profile`은 사용자가 로그인 할 때, 시스템 전체적으로 공통된 초기화를 하기 위해 설정하는 파일이다. 즉 모든 사용자에게 적용된다. 

### ~/.bash_profile 파일
`~/.bash_profile` 파일은 사용자별로 적용되는 파일이다. 사용자가 로그인을 하면 사용자 홈 디렉토리(~)에 있는 `.bash_profile` 파일을 실행한다. 만약 .bash_profile 파일이 없는데 `bash_login` 이라는 파일은 있다면 이를 대신 사용한다. 만약 이 또한 없는데 `.profile` 파일이 있다면 이를 사용한다. 즉 1) ~/.bash_profile > 2) ~/.bash_login > 3) ~/.profile 순으로 하나만 적용된다.

### /etc/bashrc, ~/.bashrc 파일
/etc/profile, ~/bash_profile 파일은 로그인 시 수행되는 반면, /etc/bashrc, ~/.bashrc 파일은 shell 실행시에 수행된다.
`/etc/bashrc` 파일은 시스템 전체에 적용되고, `~/.bashrc` 파일은 해당 사용자에게만 적용된다.

### ~/.bash_logout 파일
해당 사용자가 로그아웃 할 때, 이 파일이 존재한다면 실행된다. 보통 임시 파일 삭제, 히스토리 파일 삭제, 로그아웃 시간 기록 등의 작업을 수행하는데 사용한다.

### source 명령어
`source` 명령어 또는 `.` 명령어는 쉘 스크립트 파일명을 매개변수로 받는데, 이 파일을 현재 쉘에서 실행시킨다.

```shell
$ source ./helloWorld.sh
$ . ./helloWorld.sh
```

`source` 명령어나 `.` 명령어를 사용하지 않고 스크립트를 그냥 직접 실행시키면, 자식 쉘이 생성되어 실행되므로 현재 쉘에는 스크립트의 내용이 적용되지 않는다. 따라서 현재 쉘에 대한 환경 설정을 변경하는 스크립트 실행시 이 명령어를 사용한다. `.bash_profile` 등 초기화 파일을 수정했을 때, 다시 로그인하는 과정을 거치지 않고 현재 쉘에 바로 적용시키기 위해서 주로 사용한다. 또한 이 명령을 사용하는 경우는 스크립트에 실행 권한이 없어도 된다.

```shell
# 실행 권한(x)이 없다
$ ls -l ~/.bash_profile
-rw-r--r--  1 www  staff  1362  2 19 23:36 /Users/www/.bash_profile

# 실행 권한이 없으므로 그냥 실행 시킬 수 없다
$ ~/.bash_profile
-bash: /Users/www/.bash_profile: Permission denied

# source 명령어나 . 명령어로 실행시 문제 없이 실행된다
$ source ~/.bash_profile
$ . ~/.bash_profile
```


### set, shopt 명령어를 이용한 옵션 설정
#### set 명령어

`set` 명령어의 `-o` 옵션을 이용하면 셸 환경에 대한 세부적인 사항을 설정할 수 있다.
`set -o` 명령을 실행하면 사용 가능한 모든 옵션의 목록과 설정된 값(on/off)을 출력한다.

```shell
$ set -o
allexport      	off		# 사용하지 않는 옵션
braceexpand    	on		# 사용하는 옵션
emacs          	on
errexit        	off
errtrace       	off
functrace      	off
...
```

`set -o 옵션명`을 실행하면 해당 옵션의 on/off 여부를 toggle 할 수 있다. 또한 대부분의 옵션에는 축약형이 존재한다. 예를 들어 `set -o allexport` 명령은 `set -a`으로 줄여서 쓸 수 있다.

#### shopt 명령어

`shopt` 명령어는 `set` 명령어를 대체하기 위해 2.x 이후 버전부터 적용된 명령이다. (shopt = shell options의 줄임말이다.) set 명령과 유사하나, 더욱 다양한 옵션들을 제공한다.

`shopt -p` 명령을 실행하면 사용 가능한 모든 옵션의 목록을 볼 수 있다.  `-u`는 현재 사용하지 않는 옵션이고, `-s` 옵션은 현재 사용하는 옵션임을 의미한다.

```shell
$ shopt -p
shopt -u cdable_vars
shopt -u cdspell
shopt -u checkhash
shopt -s checkwinsize
shopt -s cmdhist
shopt -u compat31
...
```

`set` 명령어는 `-o` 옵션으로 설정 확인, on으로 변경, off로 변경을 모두 처리한다. 반면 shopt는 이들을 각각 다른 옵션으로 실행한다.

- `shopt -p 옵션명` : 해당 옵션의 설정 값을 확인
- `shopt -u 옵션명` : 해당 옵션을 사용하지 않도록 변경
- `shopt -s 옵션명` : 해당 옵션을 사용하도록 변경

```shell
# checkhash 옵션의 설정값 확인
$ shopt -p checkhash
shopt -u checkhash		# 사용하지 않는 옵션

# checkhash 옵션을 사용하도록 변경
$ shopt -s checkhash

# checkhash 옵션의 설정값 확인
$ shopt -p checkhash
shopt -s checkhash		# 사용으로 변경되었다.
```

### PATH 설정
배시 쉘은 커맨드 라인에 입력된 명령의 위치를 찾기 위해 변수 `PATH`의 값을 참조한다. 

```shell
$ echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:.
```

각 경로들은 콜론(:)으로 구분되어 있으며, 왼쪽에서 오른쪽 방향으로 검색된다. 경로의 맨 마지막 dot`.`은 현재 작업 디렉토리를 의미한다. 경로의 맨 마지막에 dot(.)을 지정하지 않은 경우에는, 현재 작업 디렉토리에 있는 명령이나 파일을 수행시킬 때 파일명 앞에 `./`를 붙여야 한다. 예를 들어 `./helloWorld.sh` 처럼 입력해야 한다. `./`를 붙이지 않고 파일명 `helloWorld.sh`만 입력한다면 쉘은 파일을 찾지 못한다.

```shell
$ echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:	# dot 없음

# 현재 디렉토리에 파일이 존재하나, 실행되지 않는다.
$ helloWorld.sh
-bash: helloWorld.sh: command not found

# 앞에 ./를 붙이면 정상적으로 실행된다.
$ ./helloWorld.sh
Hello, world!

# PATH 변수의 값을 변경한다. 현재 값의 맨 뒤에 dot을 붙인다.
$ PATH=$PATH:.

# PATH를 수정하였으므로 ./를 붙이지 않아도 정상적으로 실행된다.
$ helloWorld.sh
Hello, world!
```

