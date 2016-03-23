---
layout: post
title: 피보나치수열 with memoization
category: blog
tags: [java, algorithm]
---
### 피보나치 수열
1, 1, 2, 3, 5, 8, 13, 21, ... 재귀 함수를 배울 때 자주 등장하는 예제이다.


```java
public class Fibo {
    public static long fiboByRecursion(long n) {
        if (n == 1 || n == 2)
            return 1;
         
        return fibo(n-1) + fibo(n-2);
    }
     
    public static long fiboByLoop(long n) {
        if (n == 1 || n == 2)
            return 1;
         
        long sum = 1;
        long prev = 1;
        long temp;
         
        for(long i=3; i<=n; i++) {
            // sum은 n-1
            // prev는 n-2
            temp = sum;
            sum = sum + prev;  // n-1 + n-2
            prev = temp;       // n-2에 n-1을 대입
        }
         
        return sum;
    }
     
    public static void main(String[] args) {
        System.out.println(Fibo.fiboByRecursion(10));
        System.out.println(Fibo.fiboByLoop(10));
    }
}
```
가독성 측면에서는 loop 방식에 비해 recursion으로 구현한 코드가 훨씬 짧고 명료하다.
단 n이 작을 때에는 문제 없지만, 40 이상으로 넘어가면 수행시간이 기하급수적으로 증가한다. 
중복계산을 없애기 위해 recursion 방식의 코드에 memoization을 사용하자.
반환형이 long임에도 n이 커지면 오버플로가 발생할 수 있다는 점을 유의하자. 



```java
public class Fibo {
    static final long memo[] = new long[200];
     
    public static long fibo(long n) {
         
        if(memo[n] > 0)
            return memo[n];
         
        if (n == 1 || n == 2)
            return memo[n] = 1;
         
        return memo[n] = fibo(n-1) + fibo(n-2);
    }
     
    public static void main(String[] args) {
        System.out.println(Fibo.fibo(8));
    }
}
```
memoization을 적용하였다.