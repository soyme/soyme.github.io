---
layout: post
title: CountDownLatch / CyclicBarrier 클래스
category: blog
tags: [java,thread]
---
`java.util.concurrent.CountDownLatch` 클래스, `java.util.concurrent.CyclicBarrier` 클래스는 여러개의 쓰레드를 동기시킬 때 사용하면 편리하다.

<!-- more -->

### java.util.concurrent.CountDownLatch 클래스
어떤 쓰레드가 지정한 쓰레드가 종료되기를 기다릴 때에는 java.lang.Thread 클래스의 join 메소드를 이용한다. 하지만 join 메소드로 기다리는 것이 가능한 것은 '쓰레드의 종료'라고 하는 단 한 번의 액션뿐이다. 따라서 '지정한 횟수만큼 어떠한 액션이 일어나는 것을 기다린다'라는 것은 불가능하다.
java.util.concurrent.CountDownLatch 클래스를 사용하면 '지정한 횟수만큼 countdown 메소드가 호출되기를 기다린다'는 기능을 구현할 수 있다.


아래의 예제는 쓰레드에 MyTask라는 일을 10개 처리하도록 하고, 10개의 일이 전부 끝나기를 기다리는 프로그램이다.

```java
import java.util.concurrent.Executors;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.CountDownLatch;
  
public class Main {
    private static final int TASKS = 10; // 일의 갯수
  
    public static void main(String[] args) {
        System.out.println("BEGIN");
        ExecutorService service = Executors.newFixedThreadPool(5);
        CountDownLatch doneLatch = new CountDownLatch(TASKS);
        try {
            // 일을 시작한다
            for (int t = 0; t < TASKS; t++) {
                service.execute(new MyTask(doneLatch, t));
            }
            System.out.println("AWAIT");
            // 일이 종료되기를 기다린다
            doneLatch.await();
        } catch (InterruptedException e) {
        } finally {
            service.shutdown();
            System.out.println("END");
        }
    }
}
```
1. 일을 실행하기 위한 ExecutorService 객체를 생성한다. (쓰레드 5개를 가진 쓰레드풀)
2. CountDownLatch 클래스의 인스턴스를 생성한다. 이 때 생성자의 인자로 일의 갯수를 전달한다.
3. execute 메소드를 10번 호출하여, 10개의 일을 시작하도록 한다. 내부에서 10개의 MyTask 쓰레드가 기동되어 일을 처리한다.
4. CountDownLatch 클래스의 await 메소드를 호출하여, 카운트 값이 0이 될 때까지 기다린다.
5. 카운트 값이 0이 되었다면 shutdown 메소드를 호출하여 service를 종료한다.

```java
import java.util.Random;
import java.util.concurrent.CountDownLatch;
  
public class MyTask implements Runnable {
    private final CountDownLatch doneLatch;
    private final int context;
    private static final Random random = new Random(314159);
  
    public MyTask(CountDownLatch doneLatch, int context) {
        this.doneLatch = doneLatch;
        this.context = context;
    }
  
    public void run() {
        doTask();
        doneLatch.countDown();
    }
  
    protected void doTask() {
        String name = Thread.currentThread().getName();
        System.out.println(name + ":MyTask:BEGIN:context = " + context);
        try {
            Thread.sleep(random.nextInt(3000));
        } catch (InterruptedException e) {
        } finally {
            System.out.println(name + ":MyTask:END:context = " + context);
        }
    }
} 
```
MyTask 클래스는 일의 내용을 나타내는 클래스이며 Runnable 인터페이스를 implements 한다. run 메소드에서는 다음 처리를 실행한다.

 1. doTask 메소드를 호출하여 '실제 처리'를 실행한다.
 2. CountDownLatch 클래스의 countDown 메소드를 호출하여 카운트 값을 1 감소시킨다.

지정된 갯수만큼의 모든 MyTask가 처리 완료되면 카운트 값이 0이 되고, 메인쓰레드는 await 메소드로부터 돌아오게 된다. 이로써 MyTask를 실행하던 쓰레드가 메인쓰레드에게 일 처리가 종료되었음을 알리는 것이다.

### java.util.concurrent.CyclicBarrier 클래스
앞에서 살펴본 CountDownLatch 클래스의 인스턴스는 카운트다운밖에 할 수 없다. 즉 한 번 카운트가 0에 도달하면 await 메소드를 호출해도 바로 돌아와버린다. 쓰레드의 동기를 몇 번이고 반복하고 싶을 때에는 java.util.concurrent.CyclicBarrier 클래스를 사용한다.


CyclicBarrier는 주기적으로 (cyclic 하게) 장벽(barrier)을 만든다. 장벽에 부딪힌 쓰레드는 장벽이 사라질 떄까지 다음 단게로 나아갈 수 없다. 장벽이 사라지는 조건은 생성자에서 지정한 개수의 쓰레드가 그 장벽에 도착하는 것이다. 즉, 지정한 개수의 쓰레드가 장벽에 도착하면 장벽이 사라지고 쓰레드들이 모두 실행을 시작하게 된다.


아래의 예제는 0~4단계까지 다섯 단계를 거치는 일을 3개의 쓰레드가 처리하는 프로그램이다.
단, 3개의 쓰레드 모두가 N단계를 종료할 떄까지는 어떤 쓰레드도 다음 단계로 나아갈 수 없다. 즉, 3개의 쓰레드들의 단계 맞추기를 위하여 CyclicBarrier 클래스를 사용한다. 또한 3개의 쓰레드가 모든 단계를 종료했다는 사실을 메인쓰레드에게 알리기 위해 CountDownLatch 클래스를 사용한다.


그리고 CyclicBarrier 인스턴스를 생성할 때 Runnable 객체를 인자로 전달한다. 이 객체를 barrier action이라고 한다. barrier action은 장벽이 해제될 때마다 실행된다.

```java
import java.util.concurrent.Executors;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.CyclicBarrier;
import java.util.concurrent.CountDownLatch;
  
public class Main {
    private static final int THREADS = 3; // 쓰레드의 갯수
  
    public static void main(String[] args) {
        System.out.println("BEGIN");
  
        // 일을 실행하는 쓰레드를 제공하는 ExecutorService (쓰레드풀)
        ExecutorService service = Executors.newFixedThreadPool(THREADS);
  
        // barrier가 해제될 때 실행될 액션 (Runnable 객체)
        Runnable barrierAction = new Runnable() {
            public void run() {
                System.out.println("Barrier Action!");
            }
        };
  
        // 쓰레드들 간에 단계를 맞추기 위한 CyclicBarrier
        CyclicBarrier phaseBarrier = new CyclicBarrier(THREADS, barrierAction);
  
        // 모든 단계가 CountDownLatch
        CountDownLatch doneLatch = new CountDownLatch(THREADS);
  
        try {
 
            for (int t = 0; t < THREADS; t++) {
                service.execute(new MyTask(phaseBarrier, doneLatch, t));
            }
 
            System.out.println("AWAIT");
            doneLatch.await();
        } catch (InterruptedException e) {
        } finally {
            service.shutdown();
            System.out.println("END");
        }
    }
}
```
