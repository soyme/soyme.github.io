---
layout: post
title: java.lang.Object 클래스
category: blog
tags: [thread, java]
---
모든 클래스의 상위 클래스인 java.lang.Object 클래스의 thread 관련 메소드를 살펴보자.

<!-- more -->

### public final void notify()
이 객체 상에서 wait 하고 있는 쓰레드 중 한 개를 골라서 깨운다. 현재의 쓰레드가 이 객체의 락을 가지고 있지 않은 경우(모니터를 소유하고 있지 않은 경우)는 실행시 java.lang.IllegalMonitorStateException이 통보된다.

### public final void notifyAll()
이 객체 상에서 wait하고 있는 쓰레드를 전부 깨운다. 현재의 쓰레드가 이 객체의 락을 가지고 있지 않은 경우(모니터를 소유하고 있지 않은 경우)는 실행시 java.lang.IllegalMonitorStateException이 통보된다.


### public final void wait() throw InterruptedException
현재의 쓰레드(wait 메소드를 호출한 쓰레드)를 wait 시킨다. 타임아웃은 하지 않는다.

- sleep 메소드와 달리 현재의 쓰레드가 가지고 있는 락은 해제된다.
- 현재의 쓰레드가 이 객체의 락을 가지고 있지 않은 경우(모니터를 소유하고 있지 않은 경우)는 실행시 java.lang.IllegalMonitorStateException이 통보된다.
- 다른 쓰레드가 현재의 쓰레드에 interrupt한 경우에는 java.lang.InterruptedException이 통보되며, 인터럽트 상태를 삭제한다.

### public final void wait(long millis) throws InterruptedException
parameter로 받는 `millis`는 타임아웃까지의 시간이다. 파라미터가 `(0)`인 경우는 타임아웃 하지 않는다. millis가 마이너스인 경우에는 java.lang.IllegalArgumentException이 통보된다.

### public final void wait(long millis, int nanos) throws InterruptedException
1,000,000 * millis + nanos = 타임아웃까지의 시간이다. 파라미터가 `(0, 0)`인 경우는 타임아웃 하지 않는다. millis가 마이너스인 경우 혹은 nanos가 0 이상 999,999 이하가 아닌 경우에는 java.lang.IllegalArgumentException이 통보된다.
