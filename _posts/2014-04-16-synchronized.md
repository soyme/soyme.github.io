---
layout: post
title: 쓰레드의 배타제어 (mutual exclusion) / 동기화 (synchronized)
category: blog
tags: [java, thread]
---
concurrent 하게 수행되는 여러개의 쓰레드가 같은 변수/인스턴스에 접근하는 경우를 `race`라고 한다. 이러한 경쟁으로 인하여 예기치 않게 발생하는 상황을 date race, 혹은 `race condition` 이라고 한다. race condition을 방지하기 위해서는, 일종의 교통 정리가 필요하다.

 - 대표적인 교통 정리의 방법으로 `mutual exclusion`이 있다. 하나의 쓰레드가 어느 부분을 실행하고 있을 때에는 다른 쓰레드가 그 부분을 실행할 수 없게 만드는 방법이다. 자바에서는 쓰레드의 mutual exclusion을 실행할 때 `synchronized` 키워드를 사용한다.
 - synchronized 키워드는 메소드에 붙일수도 있고, 익명 블록에 붙일수도 있다.

<!-- more -->

### synchronized 메소드
메소드에 synchronized 키워드를 붙여서 선언하면, 그 메소드는 동시에 한 개의 쓰레드만 실행할 수 있다.

```java
public class Bank {
    private int money;
    private String name;
  
    public Bank(String name, int money) {
        this.name = name;
        this.money = money;
    }
  
    // 예금한다
    public synchronized void deposit(int m) {
        money += m;
    }
  
    // 출금한다
    public synchronized boolean withdraw(int m) {
        if (money >= m) {
            money -= m;
            return true;    // 출금 가능
        } else {
            return false;   // 잔고 부족
        }
    }
  
    public String getName() {
        return name;
    }
}
```
deposit() 메소드는 money 변수의 값을 변경하고, withdraw() 메소드는 money 변수의 값을 읽고/변경한다. 따라서 race condition이 생길 수 있으므로 synchronized 메소드로 만든다. 이렇게 하면 하나의 쓰레드가 deposit() 메소드를 실행하는 도중에는 다른 쓰레드가 동일한 Bank 인스턴스의 deposit() 메소드와 withdraw() 메소드를 실행할 수 없다.

 - 어떤 synchronized 메소드가 실행되면, 해당 인스턴스의 모든 synchronized 메소드에 락(lock)이 걸린다.
 - 실행중이던 synchronized 메소드가 실행 종료되면, 걸려있던 락이 해제된다.
 - 다른 쓰레드가 synchronized 메소드에 접근을 시도할 때, 락이 걸려있는지 아닌지를 먼저 체크하게 된다.
 - 만약 락이 걸려있다면, 락이 해제될 때 까지 블록되어 기다린다...
 - 락이 해제되면, 지금까지 락이 걸려있어서 기다리고 있던 쓰레드 중 어느 하나가 synchronized 메소드를 실행할 수 있게 된다. (이것을 "락을 획득했다"라고 한다.) 락을 획득하지 못한 나머지 쓰레드들은 또 락이 해제될 때 까지 블록되어 기다린다..


getName() 메소드는 name 변수의 값을 리턴한다. name 변수의 값을 변경하는 곳은 생성자밖에 없다. 따라서 getName() 메소드는 synchronized 메소드로 할 필요가 없으며, 여러개의 쓰레드가 동시에 getName() 메소드를 실행할 수 있다.


락은 인스턴스마다 독립적으로 존재한다. 어떤 인스턴스의 synchronized 메소드가 실행중이라고 해서, 다른 인스턴스의 synchronized 메소드를 실행할 수 없는 것은 아니다.

### synchronized 블록 (synchronized statement)
하나의 메소드 전체가 아니라 메소드 일부만 상호 배타적으로 실행하고 싶을 때에는 `synchronized 블록`을 이용한다. synchronized 블록 내의 코드는 동시에 한 개의 쓰레드만 실행할 수 있게 된다.

```java
synchronized(lock) {
	....
}
```
`lock` 부분에는 락을 취할 변수나 인스턴스를 명시한다. 같은 인스턴스가 명시된 synchronized 블록들은 상호 배타적으로 실행되게 된다. 즉 synchronized 블록은 상호 배타적으로 실행하는 범위를 치밀하게 제어하고 싶을 때 사용한다.

### synchronized 메소드와 synchronized 블록
#### synchronized 메소드
```java
public class Bank {
    ...
    public synchronized void deposit(int m) {
        money += m;
    }
}
```

#### synchronized 블록
```java
public class Bank {
    ...
    public void deposit(int m) {
        synchronized (this) {
            money += m;
        }
    }
}
```
위의 두 코드는 동일하게 동작한다. synchronized 메소드에서는 쓰레드의 상호 배타 제어를 실행하는데 this의 락을 사용하는 것이다. 단 static 메소드/블록의 경우 모든 인스턴스가 공유하는 것이므로, this가 아닌 클래스 객체가 사용된다.

### static synchronized 메소드와 블록
#### static synchronized 메소드
```java
public class Bank {
    ...
    static synchronized public void deposit(int m) {
        money += m;
    }
}
```

#### static synchronized 블록
```java
public class Bank {
    ...
    public void deposit(int m) {
        synchronized (Bank.class) {
            money += m;
        }
    }
}
```
위의 두 코드는 동일하게 동작한다.