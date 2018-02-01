---
layout: post
title: Java 동기화 - synchronized, volatile, final
category: blog
tags: [thread, java]
---
먼저, 동기화가 제대로 이루어지지 않아서 문제가 생기는 경우를 살펴보자.

<!-- more -->

### reorder
reorder란, 최적화를 위해 컴파일러나 JVM이 프로그램의 처리 순서를 바꾸는 것을 말한다. 프로그램의 수행 능력을 높이기 위해 널리 사용되고 있지만, 그 사실을 프로그래머가 의식하기는 어렵다.  실제 싱글 쓰레드 프로그램에서는 reorder가 이뤄지고 있는지 판단할 수 없다. reorder시에 예기치 못한 작동을 막기 위한 제약이 따르기 때문이다. (사실 싱글 쓰레드 프로그램에서는 reorder로 인한 동시성 문제가 일어나지 않는다.) 그러나 멀티 쓰레드 프로그램에서는 reorder가 원인이 되어 예기치 못한 작동을 하는 경우가 있다.

```java
class Something {
    private int x = 0;
    private int y = 0;
  
    public void write() {
        x = 100;
        y = 50;
    }
  
    public void read() {
        if (x < y) {
            System.out.println("x < y");
        }
    }
}
  
public class Main {
    public static void main(String[] args) {
        final Something obj = new Something();
  
        // Writer만 하는 쓰레드 A
        new Thread() {
            public void run() {
                obj.write();
            }
        }.start();
  
        // Read만 하는 쓰레드 B
        new Thread() {
            public void run() {
                obj.read();
            }
        }.start();
    }
}
```

Something 클래스를 보자. x와 y의 값은 0으로 초기화되어있다. write() 메소드에서는 x=100;을 먼저 실행하고 그다음 y=50;을 실행하게 되어있다. 따라서 read() 메소드의 if( x < y ) 라는 조건은 절대 만족될 가능성이 없어보인다. 하지만 Java 메모리 모델에서는 x < y 가 되는 순간이 있을 가능성이 있다. reorder가 일어났을 수 있기 때문이다.

write() 메소드 안에서 필드 x에 대한 대입과 y에 대한 대입 간에는 의존 관계가 없기 때문에, 컴파일러가 대입 순서를 y=50; x=100; 으로 바꾸어 버릴 가능성이 있다. 게다가 쓰레드 A가 y=50;을 수행한 직후에 쓰레드 B가 if( x < y ) 조건을 검색하면, 결과가 true가 되어버린다.

이 예제에서처럼 공유되는 필드에 대하여 Writer 쓰레드와 Reader 쓰레드가 분리되어있음에도 불구하고 정상적으로 동기화되지 않은 상태를 "데이터 레이스(data race)가 있다"고 한다. 그리고 이러한 프로그램을 `incrrecly synchronized 프로그램` 이라고 한다. 이러한 예제는 안전성에 문제가 있다.  해결 방법은, 명시적으로 동기화를 처리하는 것이다. 메소드를 synchronized로 선언하거나, 필드를 volatile로 선언하면 정상적으로 동기화된다.

```java
class Runner extends Thread {
    private boolean quit = false;
  
    public void run() {
        while (!quit) {
            // ...
        }
        System.out.println("Done");
    }
  
    public void shutdown() {
        quit = true;
    }
}
  
public class Main {
    public static void main(String[] args) {
        Runner runner = new Runner();
  
        // 쓰레드를 기동한다
        runner.start();
  
        // 쓰레드를 종료한다
        runner.shutdown();
    }
}
```

이 프로그램에서 run 메소드를 실행하는 쓰레드는 runner 쓰레드이고, shutdown 메소드를 실행하는 쓰레드는 메인쓰레드이다. 이 경우 메인쓰레드가 quit=true; 라고 값을 변경했음에도 불구하고 runner 쓰레드는 영원히 인지하지 못할 가능성이 있다.

- 메인쓰레드가 quit 필드에 변경한 true라고 하는 값은, 메인쓰레드의 캐시에 보관되어 있는 것일수도 있다.
- runner 쓰레드가 run() 메소드에서 읽는 quit의 값은 runner 쓰레드의 캐시에 보관된 false라는 값에서 변경되지 않았을 수도 있다.

즉 각각의 쓰레드가 다른 캐시를 사용하기 때문에, 한쪽에서 quit의 값을 변경해도 다른 한쪽에서는 visible하지 않을 수 있다. 동기화가 이루어지지 않는 것이다.

- quit를 volatile 필드로 선언하면 정상적으로 동기화된다.

### 참고) 지역변수는 동기화 문제가 일어나지 않는다.
공유 메모리 (Heap 메모리)는 모든 쓰레드가 공유하는 영역이다. 인스턴스는 모두 공유 메모리에 확보되므로, 인스턴스 내의 필드도 공유 메모리상에 존재하게 된다. new를 사용하여 생성된 인스턴스들이 여기에 확보되는 것이다.
지역변수는 공유 메모리에 존재하지 않고, 대개 쓰레드 각자가 가지고 있는 스택에 확보된다. (실제로 스택에 확보될지 여부는 JVM의 구현에 의존한다. 여기서 중요한 것은 지역변수는 공유메모리에 없다는 것이다.) 따라서, 지역변수에 여러개의 쓰레드가 접근하는 일은 일어나지 않는다.
Java의 메모리 모델에서는 여러개의 쓰레드가 접근 가능한 공유 메모리만이 문제가 된다.

volatile 외의 일반 필드에 read/write할 때에는 각 쓰레드가 가지고 있는 캐시를 매개로 이루어진다. 따라서 read로 구해지는 값이 반드시 최신값이라고는 보장할 수 없다.

### volatile
`volatile` 키워드는 동기화 기능과, long/double의 최소 단위(atomic) 취급 기능을 한다.

- volatile 필드에 read/write할 때에는 캐시를 거치지 않고 공유 메모리를 매개로 이루어진다. read로 읽은 값은 항상 최신값이며, write로 적은 값은 곧바로 다른 쓰레드에게 visible 해진다.
- volatile 필드에 read/write를 하기 전후에는 reorder가 일어나지 않는다.

### synchronized (lock & unlock)
`synchronized` 키워드는 쓰레드의 배타 제어 기능과, 동기화 기능을 한다.

- synchronized 메소드/블록은 락을 가진 하나의 쓰레드만 실행할 수 있다. 여러 쓰레드가 동시에 실행하는 것이 불가능하다.
- 어떠한 쓰레드가 synchronized 메소드/블록을 수행한 후 unlock을 하면 캐시에 적힌 내용을 공유 메모리에 강제로 write 한다. 그다음 다른 쓰레드가 synchronized 메소드/블록을 수행하기 위해 lock을 실행하면 캐시에 적힌 내용을 무효화하고 공유 메모리로부터 강제로 read한다.
- 즉, reorder나 visibility의 영향을 신경 쓰지 않아도 된다.

따라서 여러 쓰레드가 공유하는 필드는 반드시 synchronized 또는 volatile으로 보호해야 한다.

### final
final 필드는 딱 한번만 초기화 할 수 있다. 따라서 synchronized나 volatile을 이용한 동기화가 필요 없다.

- 필드를 선언할 때 초기화
- 생성자 안에서 초기화

Java 메모리 모델에서는, 생성자 호출이 종료된 이후에만 final 필드의 값이 visible 해진다. 그러나, 생성자가 끝나기 전까지는 final 필드의 값으로서 디폴트 초기 값(0, false, null)이 보일 가능성이 있다.