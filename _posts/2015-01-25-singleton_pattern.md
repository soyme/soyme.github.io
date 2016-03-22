---
layout: post
title: Singleton 패턴 구현 예제
category: blog
tags: [thread, java]
---
`싱글톤 패턴`이란 어떤 클래스의 인스턴스가 반드시 딱 한 개만 생성됨을 보장하는 패턴이다. 기본 아이디어는 다음과 같다.

<!-- more -->

- 클래스의 생성자를 private로 선언하여 외부에서 인스턴스를 생성하지 못하도록 방지함 -> 생성자가 private 이므로 상속이 불가능함
- 클래스 내에 private static 변수로 자기 자신 클래스의 인스턴스를 가짐
- 이 private static 변수를 리턴해주는 public static getInstance() 메소드를 가짐

> 이 포스팅에서는 Lazy 초기화를 이용한 예제만 다룬다. 필드 선언과 함께 초기화하는 것은 다루지 않는다.

### 첫 번째 예제 - Single Threaded Execution -> 문제 없음
```java
import java.util.Date;
  
public class MySystem {
    private static MySystem instance = null;
    private Date date = new Date();
    private MySystem() {
    }
    public Date getDate() {
        return date;
    }
    public static synchronized MySystem getInstance() {
        if (instance == null) {
            instance = new MySystem();
        }
        return instance;
    }
}
```
1. getInstance 메소드를 synchronized로 선언하였다. 
2. instance 필드의 값이 null인 상태라는 것은, getInstance() 메소드가 최초로 실행되었음을 의미한다. 즉 getInstance() 메소드가 최초 실행되었을 때에 인스턴스를 생성한다.
3. 만약 두 개의 쓰레드가 동시에 getInstance 메소드를 호출하더라도, synchronized로 선언되었기 때문에 인스턴스는 한 번만 생성됨을 보장할 수 있음.
4. 단 인스턴스가 생성된 이후에도 getInstance 메소드를 동시에 여러 쓰레드에서 호출하지 못하므로 성능이 떨어진다.
5. getInstance 메소드가 한 번도 호출되지 않았다면 인스턴스가 생성되지 않으므로 메모리를 아낄 수 있다.

### 두 번째 예제 - Double-Checked Locking -> 문제 있음
```java
import java.util.Date;
// 이 코드는 thread-safety 하지 않다
public class MySystem {
    private static MySystem instance = null;
    private Date date = new Date();
    private MySystem() {
    }
    public Date getDate() {
        return date;
    }
    public static MySystem getInstance() {
        if (instance == null) {                 // (a) 첫번째 test
            synchronized (MySystem.class) {     // (b) synchronized 블록에 들어감
                if (instance == null) {         // (c) 두번째 test
                    instance = new MySystem();  // (d) 인스턴스 생성
                }
            }                                   // (e) synchronized 블록에서 나옴
        }
        return instance;                        // (f)
    }
}
```
첫번째 예제에서 성능을 높이기 위해 수정한 에제이다. instance 필드의 값이 null일 때에만 synchronized 블록에 들어간다. 즉 getInstance 메소드가 두번째 호출될때부터는 synchronized 블록에 들어가지 않는다. 하지만 이 예제는 정상적으로 동작하지 않을 가능성이 있다. 메인에서 MySystem.getInstance().getDate()를 호출했을 때, data 필드가 초기화 되어 있지 않을 가능성이 있다.

두 개의 쓰레드 A, B가 동시에  MySystem.getInstance().getDate() 를 실행했다고 하자. 그리고 다음과 같이 동작하였다고 하자.

1. 쓰레드 A가 (a), (b), (c), (d) 까지 실행을 한다.
2. 쓰레드 A에서 B로 switching 된다.
3. 쓰레드 B가 (a)를 실행하고, instane != null 으로 판단하여 (f)를 실행한다.
4. 쓰레드 B가 getData()를 실행한다.
 - 이 때, 쓰레드 A는 아직 synchronized 블록에서 나오지 않았고 쓰레드 B는 synchronized 블록에 아예 들어가지 않았다. 이런 경우 쓰레드 A가 생성한 MySystem 인스턴스의 date 필드 값이 쓰레드 B에는 보이지 않을 수 있다.
 - 만약 쓰레드 B 또한 synchronized 블록에 들어가서 (a), (b), (c), (f)를 실행했다면 문제가 없었을 것이다.

쓰레드 B에 instance 필드의 값은 보이는데 data 필드의 값이 보이지 않는 이유는 무엇일까..? reorder에 의해 instance 필드의 값이 data 필드의 값보다도 먼저 보일 가능성이 있다는 것이다.

instance 필드를 volatile으로 선언하면 이런 문제는 없어진다. 하지만 이 예제는, synchronized 메소드를 사용한 첫번째 예제의 성능을 개선하기 위한 것이다. 만약 volatile으로 선언한다면 첫 번째 예제(synchronized 메소드를 사용하는 것)와 성능이 별반 다를 게 없다.


### 세 번째 예제 - Initialization On Demand Holder -> 문제 없음
```java
import java.util.Date;
  
public class MySystem {
    private static class Holder {
        public static MySystem instance = new MySystem();
    }
    private Date date = new Date();
    private MySystem() {
    }
    public Date getDate() {
        return date;
    }
    public static MySystem getInstance() {
        return Holder.instance;
    }
}
```
이 예제는 정상적으로, 안전하게 동작한다. 또한 synchronized나 volatile을 사용하지 않기 때문에 수행 능력이 떨어지지 않는다.

1. MySystem 클래스의 inner static 클래스로 Holder 클래스를 둔다. 
2. 이 Holder 클래스는 instance 필드를 갖는다. instance 필드는 선언시에 초기화하였다.
3. getInstance 메소드의 리턴값은 Holder.instance이 된다.

세번째 예제에서는 Holder 클래스의 "클래스 초기화"를 이용하여 thread-safety한 싱글톤 인스턴스를 만들고 있다. (클래스의 초기화는 Java 사양상 thread-safety하다.)

또한 lazy initialization을 이용하고 있다. Holder 클래스의 초기화는 쓰레드가 이 클래스에 접근했을 때 비로소 실행된다. 즉 MySystem.getInstance 메소드를 호출하기 전까지는 Holder 클래스의 초기화도 이뤄지지 않고 나아가 MySystem 인스턴스도 생성되지 않는다. 이 방법을 사용하면 메모리를 불필요하게 사용하는 일도 없어진다.
