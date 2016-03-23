---
layout: post
title: Java 8 - Interface
category: blog
tags: [java]
---
> The interface body can contain abstract methods, default methods, and static methods. An abstract method within an interface is followed by a semicolon, but no braces (an abstract method does not contain an implementation). Default methods are defined with the default modifier, and static methods with the static keyword. All abstract, default, and static methods in an interface are implicitly public, so you can omit the public modifier.
> In addition, an interface can contain constant declarations. All constant values defined in an interface are implicitly public, static, and final. Once again, you can omit these modifiers.

<!-- more -->

기존의 Java 인터페이스에는 constant와 메소드의 정의만 존재할 수 있었다. (abstract 키워드가 붙은 메소드이던 아니던, 구현 body `{ ... }`가 없이 정의만 있는 메소드) 자바 8 에서부터는 인터페이스에도 메소드를 정의할 수 있는데, 이 것이 default 메소드이다.

인터페이스 내의 메소드는 무조건 public여야 하며, 암묵적으로 public이다. 즉 접근제어자를 지정하지 않을 시에도 default-package가 아닌 public이다.

그렇다면.. 흔히 다중상속의 문제점으로 꼽히는 다이아몬드 형태의 상속 구조가 가능해진다는 것이다.
이 때 상위 인터페이스 내의 default 메소드를 호출할 때 모호성이 생긴다. `인터페이스명.super.메소드명()` 의 방식으로, 명시적으로 어떤 상위 인터페이스의 메소드를 호출할지 지정하는 방법으로 해결할 수 있다고 한다.

사실 인터페이스와 추상클래스는 어떤 공식이나 규칙보다는 하나의 철학으로 이해하는 것이 맞지 않나 싶다. 학부 시절에는 추상클래스란 1개 이상의 추상 메소드를 포함한 클래스라고 배웠다. 하지만 추상 메소드가 한 개도 없어도 추상 클래스로 정의할 수 있다. 이렇게 하는 이유는, 해당 개념을 추상 클래스로 정의할 필요가 있기 때문이다. 추상클래스로 큰 개념을 정의하고, 이를 구체화시킬 구현체들이 이를 상속받는 구조를 만들기 위해서이다. (서브클래스 is a kind of 슈퍼클래스)

또한 인터페이스는 디자인패턴 측면에서, 구현할 컴포넌트의 표준을 정하고 실제로 어떤 방식으로 구현할지는 사용자에게 위임하기 위한 것이다. Comparable 인터페이스를 생각해보면 명료하다. 어떤 방식으로 sorting 할 것인지는, 인터페이스를 구현(implements)한 서브클래스에게 위임한다.

---

https://docs.oracle.com/javase/tutorial/java/IandI/defaultmethods.html