---
layout: post
title: 순차(sequential) vs 병렬(parallel) vs 병행(concurrent) 차이
category: blog
tags: [thread]
---
sequential, parallel, concurrent 처리의 차이에 대해 간략하게 살펴보자.

<!-- more -->

#### 순차(sequential) 처리
- 복수의 업무를 순서대로 하나씩 처리. 

#### 병렬(parallel) 처리
- 복수의 업무를 "동시에" 처리. 

#### 병행(concurrent) 처리
- 병렬에 비해 추상도가 높은 표현. 
- 한 개의 업무를 어떠한 순서로 처리하든 상관 없는 여러 개의 작업으로 분할하여 처리.
작업자가 한 명이라면 분할된 작업들을 순차적으로 처리하게 되지만, 작업자가 두 명이라면 같은 작업을 병렬적으로 처리할 수 있다.

### 멀티 쓰레드 프로그램에서의 병행 처리 
멀티 쓰레드 프로그램의 경우 `병행 처리`를 의미한다. 만약 CPU가 한 개 뿐이라면 병행처리를 순차적으로 실행할 테고, CPU가 여러개라면 병행처리를 병렬적으로 실행할 수 있다.

일반 컴퓨터는 대개 CPU가 한개이므로 복수의 쓰레드가 작동하고 있다 하더라도 병행처리를 순차적으로 실행하게 된다.

1. 첫번째 쓰레드가 조금 작동하다가 멈춘다.
2. 두번째 쓰레드가 조금 작동하가 멈춘다.
3. 첫번째 쓰레드가 조금 작동하다 멈춘다.
4. 두번째 쓰레드가 조금 작동하다 멈춘다.
5. ....

이처럼 실제 작동하는 쓰레드가 바뀌면서 병행처리가 순차적으로 이뤄진다. 즉 "동일한 시간", "어떤 한 순간"에는 오직 하나의 쓰레드만 실행이 된다. 하지만 여러개의 쓰레드가 무작위로 번갈아가면서 실행됨으로서 "동시에" 처리되는 것처럼 보일 뿐이다.

### 쓰레드의 개수가 2배이면 처리량(throughput)도 2배일까?
일반적으로 그렇지 않다. 그 이유는..

- 쓰레드 개수가 늘어났다고 해도, CPU 개수에 제약이 있다면 쓰레드들이 병렬로 동작한다고 보장할 수 없다. 그리고 쓰레드간 컨텍스트 스위칭 오버헤드가 발생한다.
- 처리하는 업무를 모든 쓰레드에게 균일하게 분담시키는 것이 가능하다고 장담할 수 없다.
- 하드웨어의 제약이 없어 2배의 쓰레드가 병렬로 동작했다고 하더라도, 쓰레드간 mutual exclusion을 수행하기 위한 오버헤드가 있다.