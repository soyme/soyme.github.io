---
layout: post
title: 템플릿 메소드 패턴
category: blog
tags: [java, pattern]
---

`템플릿 메소드 패턴`은, 상위 클래스의 `템플릿 메소드`에서 처리의 흐름을 결정하고 하위 클래스에서 그 구체적인 처리 방법을 결정하는 디자인패턴이다.

<!-- more -->

### 구현 예시
```java
public abstract class AbstractDisplay { // 상위 클래스
    public abstract void open();         // 하위 클래스에 구현을 맡기는 추상 메소드 (1) open
    public abstract void print();        // 하위 클래스에 구현을 맡기는 추상 메소드 (2) print
    public abstract void close();        // 하위 클래스에 구현을 맡기는 추상 메소드 (3) close
    public final void display() {        // 템플릿 메소드
        open();
        for (int i = 0; i < 5; i++) {
            print();
        }
        close();
    }
}
```
상위클래스이자 추상클래스인 AbstractDisplay에는 한 개의 메소드가 템플릿 메소드로써 구현되어 있으며(display 메소드) 세 개의 추상클래스가 정의되어 있다. (open, print, close 메소드)

`display()` 라는 이름의 `템플릿 메소드`는 추상클래스인 open, print, close 메소드를 어떠한 알고리즘에 따라 호출하고 있다. 하지만 이 클래스만 봐서는 무슨 동작을 하는 클래스인지 알 수 없다. open, print, close가 추상메소드이기 때문이다. AbstractDisplay 클래스를 extends하는 하위클래스에서 3개의 추상메소드를 구현함으로서 클래스의 동작이 결정된다.

### 특징 / 장점
 - 상위클래스의 템플릿메소드에서 알고리즘이 final 메소드로 기술되어 있으므로, 로직의 공통화가 가능하다.
 - 하위클래스에서 추상메소드를 구현할 때에는, 그 메소드가 어느 타이밍에서 호출되는지를 이해해야 한다. 즉 상위클래스의 소스가 없다면 하위클래스의 구현이 어려울 수 있다.
 - 메인함수에서 하위클래스 인스턴스를 생성하여 상위클래스 타입의 변수에 대입한다. 이때 instanceof 등으로 하위클래스의 종류를 특정하지 않아도 프로그램이 작동하도록 만든다. "상위클래스형의 변수에 하위클래스의 어떠한 인스턴스를 대입해도 제대로 작동할 수 있도록 한다"는 LSP 원칙을 따른다.
 - 템플릿메소드 패턴을 인스턴스 생성에 응용한 전형적인 예가 Factory Method 패턴이다.