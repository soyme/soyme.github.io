---
layout: post
title: Bash Shell - 변수 변경자 (variable modifier)
category: blog
tags: [linux, shell]
---
`변수 변경자`를 사용하면, 특정 변수에 값이 지정되어 있는지 검사할 수 있으며 검사 결과에 따라 새로운 값을 할당할 수 있다.

<!-- more -->

### 값 존재 여부 검사
|command|result|
|-------|------|
|${var:-word}|변수 var에 값이 존재한다면 해당 값 사용. 변수가 존재하지 않거나 null 이라면 word 사용.|
|${var:=word}|변수 var에 값이 존재한다면 해당 값 사용. 변수가 존재하지 않거나 null 이라면 var의 값으로 word를 할당한 뒤 이를 사용.|
|${var:+word}|변수 var에 값이 존재한다면, word 사용.|
|${var:?word}|변수 var에 값이 존재한다면 해당 값 사용. 변수가 존재하지 않거나 null 이라면 `표준 오류`로 word 출력 후 쉘 종료.|

특히 `:=` 변경자는 변수에 값이 지정되어 있지 않을 경우 디폴트값을 설정할 때 유용하다.


```shell
$ echo $var				# 설정된 적 없는 변수

$ echo ${var:-hello}	# 값이 존재하지 않으므로 대신 hello가 출력됨
hello
$ echo var				# 변수 var는 여전히 존재하지 않음

$ echo ${var:=hello}	# 값이 존재하지 않으므로 대신 hello가 출력됨
hello
$ echo $var				# 위에서 := 변경자를 사용했으므로, var의 값이 hello로 변경됨
hello
```
---
만약 `:-`, `:=`, `:+`, `:?` 에서 콜론 `:`을 사용하지 않는다면, 변수의 값이 null인 경우에도 값이 존재하는 것으로 간주한다.

```shell
$ var=					# 변수 var의 값을 null로 지정
$ echo ${var:-hello}	# 값이 null이므로 대신 hello가 출력됨
hello
$ echo ${var-hello}		# 콜론을 빼면 null일지라도 hello 출력되지 않음.
```

`:?` 변경자를 이용하면, 변수의 값이 없을 때 간편하게 에러를 던질 수 있다. 변수명과 지정한 문자열이 표준 오류로 출력된다.

```shell
$ echo $myname	# 설정된 적 없는 변수

$ echo ${myname:?"myname is undefined..."}
-bash: myname: myname is undefined...
```

### offset을 이용한 sub string
변수의 값의 sub string을 간단하게 생성할 수 있다.

|command|result|
|-------|------|
|${var:offset}|변수 var의 값을 offset 위치부터 추출. offset은 0부터 시작한다.|
|${var:offset:length}|변수 var의 값을 offset 위치부터 length 길이만큼 추출.|

```shell
$ var="hello"
$ echo $var
hello
$ echo ${var:0}		# 0번 위치부터 끝까지 출력. $var 와 동일. 
hello
$ echo ${var:1:3}	# 1번 위치부터 3개 출력
ell
$ echo ${var:2}		# 2번 위치부터 끝까지 출력
llo
$ echo $var			# 변수 var의 값에는 영향이 없다.
hello
```

### 패턴 검색을 이용한 sub string
패턴 검색을 통해 문자열 앞뒤의 일부분을 제거할 수 있다.

|command|result|
|-------|------|
|${var%pattern}|변수 var의 값의 뒤쪽부터, 패턴과 일치하는 가장 작은 부분을 제거하여 추출.|
|${var%%pattern}|변수 var의 값의 뒤쪽부터, 패턴과 일치하는 가장 큰 부분을 제거하여 추출.|
|${var#pattern}|변수 var의 값의 앞쪽부터, 패턴과 일치하는 가장 작은 부분을 제거하여 추출.|
|${var##pattern}|변수 var의 값의 앞쪽부터, 패턴과 일치하는 가장 큰 부분을 제거하여 추출.|
|${var#pattern}|변수 var의 값의 앞쪽부터, 패턴과 일치하는 가장 큰 부분을 제거하여 추출.|
|${#var}|변수 var의 값의 문자 갯수(length)를 추출.|

```shell
$ pathname="/usr/bin/local/bin"
$ echo ${pathname%/bin*}	# 패턴 /bin* 지정
/usr/bin/local				# 뒤쪽의 `/bin`이 제거되었다.
$ echo ${pathname%%/bin*}
/usr						# 뒤쪽의 `/bin/local/bin`이 제거되었다.
```

```shell
$ pathname="/home/www/file/a.txt"
$ echo ${pathname##*/}		# 패턴 */ 지정
a.txt						# 앞쪽의 `/home/www/file/`이 제거되어 파일명만 출력됨
```


