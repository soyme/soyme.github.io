---
layout: post
title: Parameter / Argument 차이

category: blog
tags: []
align: left

---

Parameter는 함수의 정의에 사용되는 것, Argument는 함수의 호출에 사용되는 것.

<!-- more -->

```c
#include<stdio.h>

void func(int parameter) { // parameter = 매개변수. 호출되면서 전달받은 것.
    printf(" %d ", parameter);
}

int main() {
    func( 3 );   // argument = 인자. 함수를 호출할 때 전달하는 것.
}
```

---

References: <https://en.wikipedia.org/wiki/Parameter_(computer_programming)#Parameters_and_arguments>