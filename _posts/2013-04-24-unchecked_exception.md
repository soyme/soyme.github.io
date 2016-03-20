---
layout: post
title: Checked Exception / Uncheked Exception (RuntimeException)
category: blog
tags: [java]
---

### Checked Exception
Exception을 상속한 클래스는 try-catch, throws 등으로 예외처리를 해주어야 한다.
처리를 해주지 않으면 컴파일시 에러가 발생한다.

<!-- more -->

### Unchecked Exception (RuntimeException)
RuntimeException을 상속한 클래스는 예외처리가 필수가 아니다.

 - ArithmeticException, IllegalArgumentException, IndexOutOfBoundsException
 - 코드에서 미리 예외조건을 처리하게 만든다면 피할 수 있으나, 개발자가 부주의하게 코딩한 경우에 발생할 수 있는 종류의 예외들이다.

<hr>
http://docs.oracle.com/javase/7/docs/api/java/lang/RuntimeException.html
