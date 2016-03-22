---
layout: post
title: Adapter 패턴 (Wrapper 패턴)
category: blog
tags: [java, pattern]
---
이미 제공되어 있는 것을 그대로 사용할 수 없을 때, `제공되어 있는 것`과 `필요한 것` 사이의 `차이`를 없애주는 디자인패턴. 기존에 있는 클래스(Adaptee)를 이용하여, 필요한 기능을 제공해주는 Adaptor 클래스를 만든다.

<!-- more -->

### 구현 예시
#### 클래스에 의한 Adapter 패턴
> class Adapter extends Adaptee implements Target

 1. 새롭게 필요한 기능을 정의한 interface Target 을 만든다.
 2. Target 인터페이스를 implements한 Adaptor 클래스를 만든다.
 3. Adaptor 클래스는 기존에 제공되어 있는 Adaptee 클래스를 extends 한다.
 4. Adaptor 클래스에 Target 인터페이스에 정의된 메소드들을 오버라이드한다. 이 때, 상위클래스인 Adaptee 의 메소드를 이용한다.
 
#### 인스턴스에 의한 Adapter 패턴
> class Adapter extends Target

 1. 새롭게 필요한 기능을 정의한 추상클래스 Target 을 정의한다.
 2. Target 추상클래스를 extends한 Adaptor 클래스를 만든다.
 3. Adaptor 클래스는 Adaptee 클래스를 인스턴스변수로 갖는다.
 4. Adaptor 클래스에 Target 추상클래스에 정의된 메소드들을 오버라이드한다. 이 때, 인스턴스변수인 Adaptee 의 메소드를 이용한다.

### 특징 및 장점
기존의 클래스는 전혀 수정하지 않으므로, 오류가 났을 때 새롭게 만든 클래스만 확인하면 된다. 또한 기존 클래스의 구체적인 구현 방법을 모르더라도, API(인터페이스)만 알면 된다.