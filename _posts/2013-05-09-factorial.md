---
layout: post
title: 팩토리얼
category: blog
tags: [java, algorithm]
---

재귀 함수를 배울 때 필수로 등장하는 예제인 팩토리얼..
> 5! = 5 * 4 * 3 * 2 * 1

<!-- more -->

```java
public class Factorial {
    public static int factorialByLoop(int n) {
        int sum = 1;
        for(int i=n; i>1; i--)
            sum = sum*i;
        return sum;
    }
     
    public static int factorialByRecursion(int n) {
        if(n == 1) {
            return 1;
        }
         
        return n * factorialByRecursion(n-1);
    }
     
    public static void main(String[] args) {
        System.out.println(Factorial.factorialByRecursion(5));
        System.out.println(Factorial.factorialByLoop(5));
    }
}
```

재귀로 구현한 프로그램은 모두 비재귀적(루프 형태)으로 변경할 수 있다. 실제로 컴파일러는 재귀함수를 루프 형태로 변경하여 실행한다.

 - 재귀를 쓰면 n이 클 때 stack overflow가 발생할 수 있으므로 주의해야한다.
 - `if (n==1)`과 같은 base case 체크에 신경쓰자. 
 - 예제와 같이 팩토리얼 함수를 한 번 호출한다면 중복 계산은 일어나지 않는다. 하지만 여러번 호출하는 경우라면 memoization을 이용할 수 있다.