---
layout: post
title: Java - Uncaught Exception Handler, Shutdown Hook
category: blog
tags: [java]
---
### Uncaught Exception Handler
프로그램이 예외를 통보했을 때 그 예외를 캐치하는 try-catch절이 어디에도 적혀있지 않다고 하자. 이런 경우에는 일반적으로 쓰레드의 call stack을 표시하고 프로그램이 종료된다.

<!-- more -->

Thread 클래스의 static 메소드인 setDefaultUncaughtExceptionHandler 메소드를 사용하면 캐치되지 않는 예외의 핸들러를 설정할 수 있다. 핸들러는 Thread.UncaughtExceptionHandler 인터페이스의 객체로서 표현하고, 실제 처리는 uncaughtException 메소드에 기술한다. 이렇게 핸들러를 설정하면 종료할 때 call stack이 표시되지 않고 프로그램이 종료된다.


### Shutdown Hook
셧다운 훅이란 Java 실행 처리계 전체가 종료할 때 start하는 쓰레드를 말한다. 'Java 실행 처리계 전체가 종료할 때'란 System.exit 메소드를 호출했을 때나, 데몬쓰레드가 모든 쓰레드가 종료했을 때 등을 말한다. 이 경우 셧다운 훅을 이용하면 프로그램 전체의 종료 처리를 기술할 수 있다. 셧다운 훅을 설정하려면 java.lang.Runtime 클래스의 메소드인 addShutdownHook 메소드를 사용한다.


### Uncaught Exception Handler와 Shutdown Hook를 사용한 예제
이 프로그램은 다음과 같은 처리를 실행한다.

1. 캐치되지 않은 예외의 핸들러를 설정한다. (Thread.setDefaultUncaughtExceptionHandler 메소드 이용)
2. 셧다운 후크를 설정한다. (Runtime.getRuntime().addShutdownHook 메소드 이용)
3. 약 3초 후에 '0에 의한 정수의 나눗셈'을 실행하는 쓰레드(DivideThread)를 기동한다. 이 쓰레드에서는 java.lang.Arithmetic.Exception이 발생하여 프로그램이 종료된다. 프로그램 종료 전에 Uncaught Exception Handler와 Shutdown Hook가 순서대로 호출된다.

```java
public class Main {
    public static void main(String[] args) {
        System.out.println("main:BEGIN");

        // (1) Uncaught Exception Handler 설정
        Thread.setDefaultUncaughtExceptionHandler(
            new Thread.UncaughtExceptionHandler() {
                public void uncaughtException(Thread thread, Throwable exception) {
                    System.out.println("****");
                    System.out.println("UncaughtExceptionHandler:BEGIN");
                    System.out.println("currentThread = " + Thread.currentThread());
                    System.out.println("thread = " + thread);
                    System.out.println("exception = " + exception);
                    System.out.println("UncaughtExceptionHandler:END");
                }
            }
        );

        // (2) 셧다운 훅 설정
        Runtime.getRuntime().addShutdownHook(
            new Thread() {
                public void run() {
                    System.out.println("****");
                    System.out.println("shutdown hook:BEGIN");
                    System.out.println("currentThread = " + Thread.currentThread());
                    System.out.println("shutdown hook:END");
                }
            }
        );

        // (3) 약 3초후에 divided by zero를 실행하는 쓰레드를 기동
        new Thread("MyThread") {
            public void run() {
                System.out.println("MyThread:BEGIN");
                System.out.println("MyThread:SLEEP...");

                try {
                    Thread.sleep(3000);
                } catch (InterruptedException e) {
                }

                System.out.println("MyThread:DIVIDE");

                // divided by zero
                int x = 1 / 0;

                // 윗 줄에서 예외가 발생함으로써 이 다음 라인은 실행될 수 없다
                System.out.println("MyThread:END");
            }
        }.start();

        System.out.println("main:END");
    }
}
```
