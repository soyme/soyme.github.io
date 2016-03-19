---
layout: post
title: 일급 객체 (first-class object)
category: blog
tags: [javascript]
---
자바스크립트를 처음 공부하다 보면, `일급(First-class) 객체`라는 단어가 종종 등장한다.

### 자바스크립트에서의 일급 객체
일급(First-class)에는 `모든 것을 값으로 취급`한다는 의미가 내포되어 있다. JavaScript에서는 숫자도, 함수도 일급 객체이다. 숫자 뿐 아니라 함수도 하나의 값으로 취급된다는 것이다. 따라서 숫자, 객체 등 `값`이 올 수 있는 곳에는 거의 예외 없이 함수가 올 수 있다.

<!-- more -->


1. 함수를 변수에 저장할 수 있다.

	```javascript
	var fortytwo = function() { return 42 };
	```

1. 함수를 배열에 저장할 수 있다.

	```javascript
	var fortytwos = [42, function() { return 42; }];
	```

1. 함수를 객체에 저장할 수 있다.

	```javascript
	var fortytwos = { number: 42, fun: function() { return 42; } };
	```

1. 언제든 필요한 곳에서는 함수가 올 수 있다.

	```javascript
	42 + (function() {return 42})();	// => 84
	```

1. 함수의 인자로 함수를 전달받을 수 있다. (물론 전달받은 함수를 함수 내에서 호출할 수 있다.)

	```javascript
	function weirdAdd(number, fun) {
		return number + fun();
	}

	weirdAdd(42, function() { return 42; } );
	```

1. 함수의 반환값으로 함수를 반환할 수 있다.

	```javascript
	function makeFunction() {
		return function(number, fun) {
			return number + func();
		}
	}
	```

특히 위에서 5, 6의 정의를 사용하는 함수를 `고차원(high-order) 함수` 라고 한다. 고차원 함수는 다음 중 하나의 특징을 포함한다.

- 함수를 인자로 받는다.
- 리턴값으로 함수를 반환한다