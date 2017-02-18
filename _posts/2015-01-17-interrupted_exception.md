---
layout: post
title: InterruptedException과 멀티쓰레드
category: blog
tags: [java,thread]
---
메소드에 throws InterruptedException이 붙는다는 것은 다음과 같은 의미를 지닌다.

1. 시간이 걸리는 메소드이다.
2. 취소 가능한 메소드이다.

<!-- more -->

### throws InterruptedException
Java 표준 라이브러리에서 `throws InterruptedException`이 붙은 대표적인 메소드는 다음과 같다.

- java.lang.Object 클래스의 wait 메소드
- java.lang.Object 클래스의 sleep 메소드
- java.lang.Object 클래스의 join 메소드

##### 시간이 걸리는 메소드
- wait 메소드를 실행한 쓰레드는 wait set에 들어가서 notify/notifyAll 되기를 기다린다. 기다리는 동안 쓰레드는 아무 활동도 하지 않지만 - notify/notifyAll 될 때까지 시간이 소요된다.
- sleep 메소드를 실행한 쓰레드는 인자로 지정된 시간만큼 실행을 일시정지한다. 역시 깨어날 때까지 시간이 소요된다.
join 메소드를 실행한 쓰레드는 지정된 쓰레드가 종료될 때까지 기다린다. 역시 지정된 쓰레드가 종료되기까지 시간이 걸린다.

##### 취소할 수 있는 메소드
시간이 걸리는 처리는 응답성을 떨어뜨리므로 다음과 같이 도중에 실행을 취소하는 수단이 필요하다.

- wait 메소드가 notify/notifyAll을 기다리는 것을 취소한다.
- sleep 메소드가 지정한 시간만큼 일시정지해 있는 것을 취소한다.
- join 메소드가 다른 쓰레드가 종료되기를 기다리는 것을 취소한다.

이렇게 취소를 한 후에는, 쓰레드를 종료시키거나 취소한 사실을 사용자에게 알리거나, 처리를 중단하고 다음 처리로 넘어가는 등을 프로그램에 따라 구현하면 된다.

### sleep 메소드와 interrupt 메소드
쓰레드 A가 다음과 같이 sleep 메소드를 사용해 일시정지 한 상태라고 하자.

```
Thread.sleep(604800000);
```

이 쓰레드의 sleep을 취소해보자. 이 쓰레드는 일시정지된 상태이므로, 다른 쓰레드 B가 취소를 해줘야 한다. 쓰레드 B는 다음 문장을 실행하여 쓰레드 A의 일시정지를 중단시킨다.

```
A.interrupt();
```

여기에서의 interrupt 메소드는 Thread 클래스의 static 메소드이다. interrupt를 실행하기 위해 Thread 인스턴스의 락을 얻을 필요는 없다. 언제 어떤 쓰레드라도 다른 어떤 쓰레드의 interrupt를 호출할 수 있다.

sleep하고 있던 쓰레드 A는 interrupt가 호출되면 일시정지를 중단하고 InterruptedException이라는 예외를 통보한다. 이렇게하여 쓰레드 A는 이 예외를 처리하는 catch절으로 이동하게 된다.

### wait 메소드와 interrupt 메소드
wait도 sleep과 마찬가지로 취소할 수 있다. 어떤 다른 쓰레드 B는 다음 문장을 실행하여 쓰레드 A의 wait를 취소할 수 있다.

```
A.interrupt();
```

이 문장은 쓰레드 A에게 `더 이상 notify/notifyAll을 기다리지 않아도 된다. wait set에서 나와라.`는 의도를 전달할 수 있다. 단 여기서 락에 주의할 필요가 있다. interrupt를 호출받은 쓰레드 A는 락을 다시 취한 이후에야 InterruptedException을 통보할 수 있다.

#### 참고) notify 메소드와 interrupt 메소드의 차이
- notify 메소드는 java.lang.Object 클래스의 메소드이며, 해당 인스턴스의 wait set 안에있는 임의의 쓰레드를 깨운다. 그리고 깨어난 쓰레드는 wait 구문의 다음 줄을 실행하게 된다. 또한 notify를 실행하기 위해서는 해당 인스턴스의 락을 취해야 한다.
- interrupt 메소드는 java.lang.Thread 클래스의 메소드이며, 특정 쓰레드를 직접 지정하여 깨운다. 그리고 깨어난 쓰레드는 InterruptedException을 통보한다. 또한 interrupt를 실행하기 위해서 취소하는 쓰레드의 락을 취할 필요는 없다.

### join 메소드와 interrupt 메소드
join도 sleep, wait과 마찬가지로 취소할 수 있다. join 메소드는 인스턴스의 락을 취하지 않고도 호출할 수 있기 때문에 sleep 메소드와 마찬가지로 바로 catch절을 실행하게 된다.

### Interrupted Status
interrupt 메소드는 대상 쓰레드의 interrupted status를 바꾸는 것일 뿐, interrupt 메소드를 호출했을 때, 대상 쓰레드가 항상 InterruptedException을 통보하는 것은 아니다. (interrupted status란 쓰레드가 인터럽트 된 상태인지 아닌지를 나타내는 status이다.)

쓰레드 A가 sleep/wait/join을 실행하여 정지하고 있는 중에 쓰레드 B가 A의 interrupt 메소드를 호출했다고 하자. 그러면 쓰레드 A는 InterruptedException을 통보한다. 그러나 이것은 sleep, wait, join 메소드 내부에서 쓰레드의 interrupted status를 조사하고 명시적으로 InterruptedException을 통보하고 있기 때문이다.

만약 쓰레드 A가 sleep/wait/join 실행중이 아니라 다른 일반적인 연산을 수행중이었다고 하자. 이 때 쓰레드 A의 interrupt 메소드가 호출되었다면, 쓰레드 A는 InterruptedException을 통보하지 않고 하던 연산을 계속 수행한다. 즉, 코드상에서 interrupted status를 조사하여 InterruptedException을 통보하지 않는 이상 InterruptedException은 통보되지 않는다.

#### 참고) 코드상에서 InterruptedException 통보하기
```java
public void test() throw InterruptedException {
    // ...
    if (Thread.interrupted() ) {
        throw new InterruptedException();
    }
    // ...
}
```

- interrupted 상태에서 `A.interrupt()`를 호출하면 쓰레드 A는 non-interrupted 상태가 된다.
- non-interrupted 상태에서 `A.interrupt()`를 호출하면 쓰레드 A는 interrupt 상태가 된다.

### isInterrupted() 메소드
isInterrupted() 메소드는 지정한 쓰레드의 interrupted status를 조사하는 Thread 클래스의 static 메소드이다. 지정한 쓰레드가 interrupted status라면 true를 리턴, non-interrupted status라면 false를 리턴한다. (status의 변경은 없다.)

### Thread.interrupted() 메소드
Thread.interrupted() 메소드는 현재 쓰레드의 interrupted status를 조사하고 삭제하는 Thread 클래스의 static 메소드이다.

- 현재 쓰레드가 non-interrupted status라면 false를 리턴한다.  (status의 변경은 없다.)
- 반면 interrupted status라면, 해당 쓰레드의 interrupted status를 삭제한 후 true를 리턴한다. (interrupted status를 삭제하면 non-interrupted status가 된다.)
* interrupt 메소드와 Thread.interruptted() 메소드의 차이를 잘 구분하자.

```java
public class Main {
    public static void main(String[] args) {
        Thread t = new Thread() {
            public void run() {
                while (true) {
                    try {
                        if (Thread.currentThread().isInterrupted()) {
                            throw new InterruptedException();
                        }
                        System.out.print(".");
                    } catch (InterruptedException e) {
                        System.out.print("*");
                    }
                }
            }
        };
        t.start();

        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
        }

        t.interrupt();	// 인터럽트를 건다
    }
}
```
위 코드의 쓰레드는 non-인터럽트 상태일때는 점(.)을 반복하여 출력하고, 인터럽트 상태일 때에는 별(*)을 반복하여 출력한다.

- Thread.currentThread().isInterrupted()는 인터럽트 상태를 바꾸지 않고 조사만 하기 때문에, 계속 인터럽트 상태로 남아있기 때문에 별이 반복되어 출력된다. (...............**************)
- 반면 Thread.interrupted()는 인터럽트 상태를 non-인터럽트 상태로 변경시킨다. 따라서 8 line의 Thread.currentThread().isInterrupted() 구문을 Thread.interrupted() 로 바꾼다면, 별이 딱 한번만 출력되고 그 다음에는 다시 점이 출력된다. (.............*.............)


### Thread.stop() 메소드 - @deprecate
이 메소드는 deprecate 메소드이다. stop() 메소드는 동작중인 쓰레드를 종료시키기 위한 것인데 안전성을 위협할 수 있으므로 사용하지 않는 것이 좋다. stop() 메소드는 현재 쓰레드가 critical section을 실행하고 있는 중이라고 하더라도 종료시킬 수 있다. 이는 안전성 관점에서 굉장히 위험한 일이다.
