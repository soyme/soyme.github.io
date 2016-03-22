---
layout: post
title: Java - 인터럽트 상태와 InterruptedException의 상호 변환
category: blog
tags: [java,thread]
---
`interrupt()` 메소드를 호출하면 쓰레드에 인터럽트를 걸 수 있다. 이러한 행위는 다음 중 어느 하나의 결과를 낳는다.

 1. 쓰레드가 '인터럽트 상태'가 된다 -> '상태'에 반영
 2. InterruptedException이 통보된다 -> '제어'에 반영

<!-- more -->

일반적으로는 `1`이 되지만, 쓰레드가 `sleep` or `wait` or `join` 하고 있는 경우에는 `2`가 된다. (그리고 2의 경우에는 '인터럽트 상태'가 되지 않는다.) 그런데 이 `1`과 `2`는 상호 변환이 가능하다.

### 인터럽트 상태 -> InterruptedException으로 변환
```java
if (Thread.interrupted()) {
    throw new InterruptedException();
}
```
이런식으로 if문을 시간이 걸리는 처리 앞에 적어두면, 인터럽트에 대한 응답성이 좋아진다. 인터럽트가 걸렸다는 사실을 망각하고 시간이 걸리는 처리를 시작하는 것을 막을 수 있기 때문이다. Thread.interrupted() 메소드를 호출하면 쓰레드는 인터럽트 상태에서 벗어나게 된다. (인터럽트 상태가 삭제된다.) 인터럽트 상태를 삭제하지 않고 인터럽트 상태를 조사하고 싶다면 다음과 같이 한다.

```java
if (Thread.currentThread().isInterrupted()) {
    // 인터럽트 상태일 경우의 처리
}
```

### InterruptedException -> 인터럽트 상태로 변환
일정 시간만큼 쓰레드의 동작을 멈추고 싶을 때는 Thread.sleep 메소드를 사용한다. Thread.sleep은 InterruptedException을 통보한다. 

```java
try {
    Thread.slee(1000);
} catch (InterruptedException e) {
     // 아무 처리도 하지 않음
}
```
그런데 이렇게 적으면 통보된 InterruptedException이 무시된다. sleep 중에 다른 쓰레드가 인터럽트를 걸어올 경우, catch절에 의해 인터럽트가 무시되기 때문에 '인터럽트 당했다'는 사실을 잃어버리게 되는 것이다. 따라서 다음과 같이 자신에게 한번 더 인터럽트를 건다.

```java
try {
    Thread.slee(1000);
} catch (InterruptedException e) {
    Thread.currentThread().interrupt();
}
```
이렇게 하면, InterruptedException을 캐치했을 때 인터럽트 상태로 변환할 수 있다.


### InterruptedException -> InterruptedException으로 변환
InterruptedException을 캐치하였을 때 즉시 통보하는 것이 아니라 나중에 통보하는 방법도 있다.

```java
InterruptedException savedException = null;
// ...
  
try {
} catch (InterruptedException e) {
    savedException = e;
}
```  
...
if (savedException != null) {
    throw savedException;
}
인터럽트가 들어오면 일단 savedException이라는 필드에 보관해두고, 나중에 throw 한다.