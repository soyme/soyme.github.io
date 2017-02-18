---
layout: post
title: 멀티쓰레드 프로그램 구현 방법 (Thread, Runnable) / ThreadFactory
category: blog
tags: [java,thread]
---
싱글쓰레드 프로그램과 멀티쓰레드 프로그램의 차이를 살펴보고 기본적인 멀티쓰레드 프로그램을 구현해보자.
<!-- more -->

### 싱글쓰레드 프로그램과 멀티쓰레드 프로그램의 차이

#### 싱글쓰레드 프로그램
싱글쓰레드 프로그램은, 지금 프로그램의 어느 부분이 실행되고 있냐는 물음에 "여기" 라고 한 군데를 가르킬 수 있다.

자바 프로그램을 실행하면 최소 한 개 이상의 쓰레드가 반드시 동작을 하게 된다. 코딩할 때 쓰레드를 따로 구현하지 않았더라도, 메인 쓰레드가 기본적으로 작동하여 main 메소드를 실행한다. 그리고 main 메소드 실행이 끝나면 메인 쓰레드는 종료된다. (물론 메인 쓰레드 뿐 아니라, 가비지 콜렉션용 쓰레드나 GUI 관련 쓰레드 등 또한 뒤에서 작동한다.)

#### 멀티쓰레드 프로그램
멀티쓰레드 프로그램은 지금 프로그램의 어느 부분이 실행되고 있냐는 물음에, "첫 번째 쓰레드는 여기, 두 번째 쓰레드는 저기..." 라며 쓰레드의 갯수 만큼을 가르키게 된다.

멀티 쓰레드가 사용되는 프로그램의 대표적인 예는 다음과 같다.

1. GUI 응용 프로그램
2. 시간이 걸리는 I/O 처리
 - 일반적으로 파일이나 네트워크 I/O 처리는 오래 걸리므로, I/O처리를 실행하는 쓰레드와 다른 처리를 실행하는 쓰레드를 분리하면 I/O에 걸리는 시간을 이용하여 다른 처리를 진행할 수 있다.
3. 복수 클라이언트 동시 처리
 - 일반적으로 네트워크 상에서 동작하는 서버는 여러 클라이언트를 동시에 상대한다. 클라이언트가 서버에 접속했을 때 그 클라이언트를 상대할 쓰레드를 준비한다. 그러면 서버가 마치 딱 하나의 클라이언트를 상대하고 있는 것처럼 프로그래밍을 할 수 있다.

> 참고) java.nio 패키지를 사용하면 쓰레드를 이용하지 않고도 수행능력과 확장성이 높은 I/O 처리가 가능하다.


### 멀티쓰레드 프로그램 구현 방법
Thread 클래스를 확장(extends) 하는 방법과 Runnable 인터페이스를 구현(implements) 하는 방법 두 가지로 나뉜다. Thread 클래스와 Runnable 인터페이스 모두 java.lang 패키지에 속해있다.

### Thread 클래스를 확장(extends) 하는 방법
```java
public class MyThread extends Thread {

    private String message;

    public MyThread(String message) {
    	this.message = message;
    }

    public void run() {
    	for (int i = 0; i < 10000; i++) {
    		System.out.print(message);
    	}
    }
}
```
1. Thread 클래스를 확장(extends)한 클래스를 만든다.
2. 개별 쓰레드가 수행할 코드를 run() 메소드에 작성한다.
 - 새로운 쓰레드를 기동시키면 그 쓰레드가 run() 메소드를 호출한다. 그리고 run() 메소드가 종료되면 쓰레드도 종료된다.

이 MyThread 클래스 만으로는 아무 것도 할 수 없으며, 메인 메소드 등에서 MyThread를 생성 및 기동시켜줘야 한다.

```java
public class Main {
    public static void main(String[] args) {

	MyThread thread1 = new MyThread("thread 1");	// 쓰레드 인스턴스 생성
	thread1.start();								// 쓰레드 기동 및 run() 실행

	new MyThread("thread 2").start();		// 위의 두 줄의 코드를 한줄로 쓰면 이렇게.

	for (int i = 0; i < 50; i++) {
	    System.out.print("main");
	}
    }
}
```

1. 메인메소드에 Thread 클래스를 확장한 클래스 (여기서는 MyThread) 의 인스턴스를 생성(new)한다.
2. 생성한 쓰레드 인스턴스의 start() 메소드를 호출한다.
 - start() 메소드는 Thread 클래스의 메소드이며, 우리가 따로 오버라이딩 하지 않는다.
 - start() 메소드를 호출하면, 쓰레드가 기동되고 해당 쓰레드의 run() 메소드가 호출된다.
 - run() 메소드를 직접 호출하는 것도 가능하나, 그렇게 하면 새로운 쓰레드를 기동할 수 없다.

> 참고) 쓰레드 인스턴스가 생성/소멸되는 것과, 쓰레드 그 자체가 시작/종료되는 것은 별개이다.

> thread1, thread2 인스턴스가 만들어졌다고 해서 쓰레드가 시작되는 것이 아니며, 쓰레드가 종료되었다고 thread1, thread2 인스턴스가 사라져 버리는 것도 아니다.

위의 코드를 실행시키면 `main`, `thread 1`, `thread 2`가 무작위로 번갈아가며 출력된다.
처음에는 메인 쓰레드만이 존재하여 main 메소드가 실행되었지만, `thread1.start()`가 실행된 시점부터 쓰레드가 한 개 더 기동됨으로써 프로그램의 흐름이 두 개로 나뉘었고, `thread2.start()`가 실행된 시점부터 쓰레드가 한 개 더 기동됨으로서 프로그램의 흐름이 세 개가 되었기 때문이다. 세 개의 쓰레드는 각각 독립적으로 자신의 일을 수행한다. 메인쓰레드는 "main"을 출력하고, 새로 생성된 쓰레드 thread1은 `thread 1` 을 출력하고, 곧이어 생성된 thread2는 `thread 2`를 출력하고 ....

여기서 `run()` 메소드의 for문은 10000회 반복하도록 되어있고, 메인메소드의 for문은 50회 반복하도록 되어있기 때문에 `main` 출력이 50회 완료된 후에는 메인 메소드가 종료되어 `thread1`, `thread2`만 무작위로 번갈아가며 출력된다.

메인메소드가 종료되면 메인쓰레드도 바로 종료된다. 하지만 start된 두 개의 쓰레드가 아직 끝나지 않았기에 프로그램은 종료되지 않는다. 모든 쓰레드가 종료되어야 프로그램이 종료된다.

> 참고) 자바 프로그램은 데몬쓰레드를 제외한 모든 쓰레드가 종료되어야 종료된다. 데몬쓰레드란 background에서 수행되는 작업을 시키기 위한 쓰레드이며, setDaemon() 메소드를 사용하여 데몬쓰레드를 만들 수 있다.


### Runnable 인터페이스를 구현(implements) 하는 방법
```java
public interface Runnable {
    public abstract void run();
}
```
java.lang.Runnable 인터페이스는 위와 같이 run() 이라는 한 개의 추상메소드를 갖는다.

```java
public class Printer implements Runnable {

    private String message;

    public Printer(String message) {
	this.message = message;
    }

    @override
    public void run() {
	for (int i = 0; i < 10000; i++) {
	    System.out.print(message);
	}
    }
}
```
1. Runnable 인터페이스를 implements한 클래스를 만든다.
2. 개별 쓰레드가 수행할 코드를 run() 메소드에 작성한다.
여기서 Thread 클래스를 extends하는 방식과 달라진 점은, extends Thread => implements Runnable 외에는 없다.

```java
public class Main {
    public static void main(String[] args) {

	Runnable r = new Printer("runnable 1");	// Runnable을 implements한 클래스의 인스턴스 생성
	Thread thread1 = new Thread(r);	// 생성한 인스턴스를 인자로 하여 Thread 인스턴스 생성
	thread1.start();			// 쓰레드 기동 및 run() 실행

	new Thread( new Printer("runnable 2") ).start();	// 위의 세 줄의 코드를 한줄로 쓰면 이렇게.
    }
}
```
3. 메인메소드에 Runnable 인터페이스를 구현한 클래스 (여기서는 Printer)의 인스턴스를 생성(new)한다.
4. 생성한 인스턴스를 인자로 하여 Thread 인스턴스를 생성한다.
5. 생성한 쓰레드 인스턴스의 start() 메소드를 호출한다.
 - 이후 작동 방식은 Thread 클래스를 extends하는 방식과 동일하다.


### java.util.concurrent.ThreadFactory로 구현하는 방법
java.util.concurrent 패키지에는 쓰레드 생성을 추상화시킨 ThreadFactory 인터페이스가 포함되어 있다.
이를 이용하면 Runnable을 인수로 하여 Thread 인스턴스를 생성하는 부분을 ThreadFactory 내부에 숨길 수 있다.

```java
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadFactory;

public class Main {
    public static void main(String[] args) {

//      Runnable r = new Printer("runnable 1");	// Runnable을 구현한 클래스의 인스턴스 생성
//      Thread thread1 = new Thread(r);	// 생성한 인스턴스를 인자로 하여 Thread 인스턴스 생성
//      thread1.start();					// 쓰레드 기동 및 run() 실행

	ThreadFactory factory = Executors.defaultThreadFactory();
	factory.newThread(new Printer("runnable 1")).start();
    }
}
```
1. 디폴트 ThreadFactory 객체를 얻기 위해 Executors.defaultThreadFactory() 메소드를 이용한다.
2. Runnable 인스턴스를 인자로 하여 ThreadFactory 객체의 newThread 메소드를 호출하면 쓰레드 인스턴스가 생성된다.
3. 생성된 쓰레드 인스턴스의 start() 메소드를 호출한다.

---

References: "Java 언어로 배우는 디자인 패턴 입문 - 멀티쓰레드편" Introduction 01
