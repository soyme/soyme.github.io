---
layout: post
title: Java Collection과 멀티쓰레드
category: blog
tags: [java,thread]
---
References: "Java 언어로 배우는 디자인 패턴 입문 - 멀티쓰레드편" Chapter 02

여러개의 인스턴스를 관리하는 인터페이스나 클래스를 총칭하여 컬렉션 이라고 한다.
 > java.util.List 인터페이스, java.util.ArrayList 클래스 등등..

자바의 컬렉션은 대부분 thread-safety 하지 않다. 따라서 여러개의 쓰레드들이 동시에 컬렉션에 접근하는 경우에는 사용하고자 하는 컬렉션이 thread-safety 한지 아닌지 API 레퍼런스를 체크해볼 필요가 있다.

<!-- more -->
다음과 같이 세 개의 예제를 살펴본다.

 - 1) thread-safety 하지 않은 java.util.ArrayList 클래스
 - 2) Collections.synchronizedList 메소드에 의한 동기화
 - 3) cow (copy-on-write) 를 사용한 java.util.concurrent.CopyOnWriteArrayList 클래스


### 1) thread-safety 하지 않은 java.util.ArrayList 클래스
```java
import java.util.List;
import java.util.ArrayList;
  
public class Main {
    public static void main(String[] args) {
  
        List<integer> list = new ArrayList<integer>();    // ArrayList는 thread-safety 하지 않음
        new WriterThread(list).start();        // WriterThread에서는 ArrayList를 write함
        new ReaderThread(list).start();        // ReaderThread에서는 ArrayList를 read함
        // ArrayList 인스턴스에 대해 read/write가 동시에 일어나므로 익셉션 발생
    }
}
```

```java
import java.util.List;

public class ReaderThread extends Thread {
    private final List<integer> list;
  
    public ReaderThread(List<integer> list) {
        super("ReaderThread");
        this.list = list;
    }
  
    public void run() {
        while (true) {
            for (int n : list) {        // iterator를 이용하여 list를 read
                System.out.println(n);
            }
        }
    }
}
```

```java
import java.util.List;
  
public class WriterThread extends Thread {
    private final List<integer> list;
  
    public WriterThread(List<integer> list) {
        super("WriterThread");
        this.list = list;
    }
  
    public void run() {
        for (int i = 0; true; i++) {
            list.add(i);     // list에 write
            list.remove(0);  // list에 write
        }
    }
}
```
ArrayList 클래스는 thread-safety 하지 않으므로 여러개의 쓰레드에서 동시에 읽고 쓰는 것은 안전하지 않다. ArrayList 클래스와 그 iterator는 안전성이 상실되었음을 검출하면 ConcurrentModificationException이라는 예외를 발생시킨다. 이것은 '수정이 동시에 이루어졌다'는 사실을 나타내는 런타임 익셉션이다. 또한 이 예제에서는 NullPointerException이 발생할 수 있다.


### 2) Collections.synchronizedList 메소드에 의한 동기화
java.util.ArrayList 클래스는 thread-safety 하지 않지만, Collections.synchronizedList 메소드를 이용하여 동기화하면 thread-satefy 인스턴스를 확보할 수 있다.

```java
import java.util.List;
import java.util.ArrayList;
import java.util.Collections;
  
public class Main {
    public static void main(String[] args) {
 
        // ArrayList의 인스턴스를 synchronizedList() 메소드를 통하여 변수 list에 보관
        final List<integer> list = Collections.synchronizedList( new ArrayList<integer>() );
 
        new WriterThread(list).start();        // WriterThread에서는 ArrayList를 write함.  
        new ReaderThread(list).start();        // ReaderThread에서는 ArrayList를 read함
    }
}
```
ArrayList의 인스턴스를 Collections.synchronizedList 메소드를 통하여 변수 list에 보관한다.

```java
import java.util.List;
  
public class ReaderThread extends Thread {
  
    private final List<integer> list;
  
    public ReaderThread(List<integer> list) {
        super("ReaderThread");
        this.list = list;
    }
  
    public void run() {
        while (true) {
            synchronized (list) {           // synchronized 블록 처리
                for (int n : list) {        // iterator를 이용하여 list를 read
                    System.out.println(n);
                }
            }
        }
    }
}
```
ReaderThread 클래스의 run() 메소드에서, iterator를 이용해 ArrayList 인스턴스에 read 하는 부분을 synchronized 블록으로 감싸준다. WriterThread 클래스의 run() 메소드에서 ArrayList 인스턴스에 write 하는 부분은 synchronized 블록으로 감싸줄 필요가 없다. 여기에서는 add, remove 메소드를 명시적으로 호출하기 때문이다.

이렇게 변경하면 ConcurrentModificationException, NullPointerException이 발생하지 않는다.

### 3) copy-on-write를 사용한 java.util.concurrent.CopyOnWriteArrayList 클래스
java.util.concurrent.CopyOnWriteArrayList 클래스는 thread-safety 하다. 이 클래스는 Collections.synchronizedList 메소드를 이용하여 동기화 시키는 위의 예제 2와는 달리, copy-on-write를 이용하여 충돌을 막는다.

```java
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
  
public class Main {
    public static void main(String[] args) {
  
        final List<integer> list = new CopyOnWriteArrayList<integer>();
  
        new WriterThread(list).start();
        new ReaderThread(list).start();
  
    }
}
```
copy-on-write는 'write 할 때 copy 한다'는 의미. 컬렉션에 대하여 write를 할 때마다, 내부에 확보된 배열을 통째로 복사한다. 이렇게 통째로 복사를 하면 iterator를 사용하여 element들을 순서대로 읽어가는 도중에 element가 변경될 염려가 없다. 따라서 CopyOnWriteArrayList 클래스와 그 iterator가 ConcurrentModificationException을 발생시키는 일은 절대 없다. 단 write를 할 때마다 배열을 통째로 copy 하므로, write가 잦은 경우 성능이 저하될 수 있다. write가 적고 read가 빈번한 경우에 좋다.