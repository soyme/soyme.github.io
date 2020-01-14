---
layout: post
title: Java 8 - Stream (스트림)
category: blog
tags: [java]
align: left

---

Java 8에 추가된 Stream API에 대하여 

<!-- more -->

### Java 8 스트림의 특징
1. 선언형 데이터 처리. for 등의 루프와 if 조건문 등을 사용하여 처리 방법을 직접 구현할 필요 없이, 기대하는 동작이 무엇인지 선언만 하면 됨.
2. 여러 연산들을 연결, 조립해서 복잡한 데이터 처리 파이프라인을 만들 수 있음.
3. 멀티쓰레드 코드를 직접 구현할 필요 없이 데이터를 병렬로 처리할 수 있음. 단일쓰레드 모델에도 사용할 수 있긴 하지만, 멀티코어 아키텍처를 최대한 투명하게 활용하도록 구현되어 있음.

#### 스트림의 정의
- 소스에서 추출된 연속된 요소. 데이터 처리 연산을 지원한다.
	- 연속된 요소(Squence of elements) : 컬렉션과 마찬가지로 스트림은 특정 요소의 타입으로 이루어진 연속된 값들의 집합이다. 단 컬렉션은 데이터 중심이고, 스트림은 filter, sorted, map 등 표현 계산식 중심이다.
	- 소스 : 스트림의 소스는 컬렉션, 배열, I/O 리소스 등이 될 수 있다.
	- 데이터 처리 연산 : filter, map, reduce, find, limit, sort 등의 데이터 처리 연산이 있으며 순차적으로 또는 병렬로 실행할 수 있다. 대부분의 스트림 연산은 파이프라인을 구성할 수 있도록 스트림 자기 자신을 반환한다(Builder 패턴과 유사).

#### 스트림과 컬렉션
- 컬렉션 인스턴스의  `stream()` 메서드를 호출하면 스트림으로 변환된다.
- 컬렉션은 가지고 있는 모든 값을 메모리에 저장한다. 컬렉션에는 요소를 자유롭게 추가하거나 삭제할 수 있으며, 추가하려는 요소는 미리 계산되어야 한다. 반면 스트림은  요청할 때에만 요소를 계산하는 고정된 자료구조이다. 스트림 자체에 요소를 추가하거나 제거할 수 없다.
- 스트림은 딱 한 번만 소비할 수 있다. 한 번 탐색된 스트림의 요소는 소비되고, 다시 탐색하려면 초기 데이터 소스에서 새로운 스트림을 다시 만들어야 한다.
- 컬렉션은 외부 반복(external iteration)을 사용하고, 스트림 라이브러리는 내부 반복(internal iternation)을 사용한다.
	- 컬렉션은 요소를 반복하려면 사용자가 직접 for 루프 등을 사용해야 함.
	- 스트림 라이브러리는 처리 연산을 지정해주면 반복을 알아서 처리함(반복을 추상화).

### 스트림 연산
- java.util.stream.Stream 인터페이스는 다양한 연산을 제공한다.
- 대부분 람다표현식을 인수로 받으므로 동작 파라미터화를 활용할 수 있다.

```
List<String> names = list.stream()
    .filter(dish -> dish.getCalories() > 300)
    .map(Dish::getName)
    .limit(3)
    .collect(toList());
```
- 스트림 연산은 중간 연산과 최종 연산으로 구분할 수 있다.
	- 중간 연산: filter, map, limit, sorted, distinct 등등. 중간 연산은 결과 스트림을 반환하므로 여러 중간 연산을 연결하여 파이프라인을 구성할 수 있다.
	- 최종 연산: collect, count, forEach 등등. 스트림을 닫는 연산. 결과를 도출한다. 보통 최종 연산에 의해 List, Integer, void 등 스트림 이외의 결과가 반환된다.
	- 중간 연산은 스트림의 요소를 소비하지 않는 반면 최종 연산은 스트림의 요소를 소비하여 최종 결과를 도출한다.
- laziness : 요청할 때 까지는 아무 연산도 수행하지 않는다.
- short circuit : 예를 들어 위의 예제에서 limit(3)이 주어졌기 때문에 filter  및 map 연산을 모든 요소들에 대해 수행하지 않고, 결과가 3개가 모일 때 까지만 탐색함
- loop fusion : filter와 map은 다른 연산이지만 filter가 전부 끝난다음 map이 수행되는게 아니라 하나의 과정으로 병합됨.

#### Filtering
- 스트림 인터페이스의 `filter`  메서드는 Predicate를 인수로 받아서 테스트결과가 true인 모든 요소들을 스트림으로 반환한다.
- `distinct`  메서드를 이용하면 중복된 요소를 필터링 할 수 있다.

```
// 리스트에서 짝수만 필터링하여 중복을 제거하여 출력한다.
numberList.stream()
    .filter(i -> i % 2 == 0)
    .distinct()
    .forEach(System.out::println);
```

#### Slicing
- `takeWhile`  메서드를 이용하면 스트림의 앞부분 중 일부를 잘라낼 수 있다. 인수로 전달한 Predicate의 테스트 결과가 false인 요소가 처음으로 나왔을 때 반복 작업을 중단한다. 스트림의 요소들이 이미 정렬되어있는 경우 유용하다.
- `dropWhile` 메서드는 takeWhile 메서드와 반대 개념이다. 인수로 전달한 Predicate의 테스트 결과가 처음으로 false가 되는 지점까지 발견된 요소를 버리고, 남은 뒷 부분을 반환한다.
- `limit(n)`  메서드는 스트림의 요소의 최대 갯수 n를 지정한다. 처음 n개 까지만 취하고 n개가 넘는 경우 나머지 뒷 부분은 버린다.
- `skip(n)` 메서드는 처음 n개 요소를 버리고, 나머지 뒷 부분을 반환한다.

#### Mapping
- 특정 객체에서 특정 데이터를 선택해서 모으는 작업.
- `map` 메서드는 인수로 받은 Function을 각 요소에 적용시킨 결과들을 새로운 스트림으로 만든다.
- 아래의 코드는 Dish 타입의 스트림에서 Dish 객체들의 이름을 추출해(getName) String 타입의 스트림으로 매핑한다.

```
List<String> dishNames = menu.stream()
    .map(Dish::getName)
    .collect(toList());
```

- `flatMap` 메서드는 map과 비슷하지만, Function을 적용시킨 결과들을 `flattening` 하여 새로운 스트림으로 만든다.
	- flattening : [["a", "b", "c"],  ["d", "e"]] -> ["a", "b", "c", "d", "e"]

#### Searching
- `anyMatch` 메서드는 스트림의 요소 중 단 하나라도 주어진 Predicate와 일치하는지 검사하여 boolean을 리턴한다.
- `allMatch` 메서드는 스트림의 모든 요소가 주어진 Predicate와 일치하는지 검사하여 boolean을 리턴한다.
- `noneMatch` 메서드는 allMatch와 반대로 스트림의 모든 요소가 Predicate와 일치하지 않는다면 boolean을 리턴한다.
- `findAny` 메서드는 스트림에서 랜덤의 요소 한 개를 반환한다. 단 비어있는 스트림일수도 있기 때문에 Optional<T> 타입으로 반환한다.
- `findFirst` 메서드는 스트림의 첫 번째 요소를 반환한다.  단 비어있는 스트림일수도 있기 때문에 Optional<T> 타입으로 반환한다.
- 위에 나열한 메서드들은 short circuit 기법을 사용한다. 즉 자바의 `&&`, `||` 과 같은 방식인데, 결과를 찾는 즉시 반환하며 전체 스트림을 처리하지는 않는다.
- 위에 나열한 메서드들은 boolean 혹은 값을 반환하므로 최종 연산이다.
- `min` 메서드와 `max` 메서드는 Comparator 인터페이스를 인수로 받아서 스트림의 요소 중 최소값 혹은 최대값을 찾는다. 단 비어있는 스트림일수도 있기 때문에 Optional<T> 타입으로 반환한다.

#### Reducing
- 스트림 요소들을 조합 및 처리하여 값으로 도출하는 최종 연산.
- `reduce` 메서드는 초기값 인수와 두 요소를 조합해서 새로운 값을 만드는 BinaryOperator 인터페이스 인수를 받는다.

```
// 숫자들의 합을 구하는 전통적인 iteration 코드
int sum = 0;
for (int n : numbers) {
	sum += n;
}

// 스트림 및 reduce 메서드 이용
int result = numbers.stream().reduce(0, (n1, n2) -> n1 + n2);

// 초기값을 넣지 않을 경우.
// 비어있는 스트림일 경우를 위하여 Optional 인터페이스로 랩핑해줘야 함.
Optional<Integer> result3 = numbers.stream().reduce((n1, n2) -> n1 + n2);
```

- Java 8의 Integer 클래스에서 제공하는 static 메서드인 Integer.sum을 이용하면 직접 람다 코드를 구현할 필요가 없이 간단히 처리 가능하다. (sum, max, min 등등)

```
// Integer 클래스의 static sum 메서드 사용 (메서드 레퍼런스 이용)
int result2 = numbers.stream().reduce(0, Integer::sum);
```

- `count` 메서드는 스트림 요소 갯수를 long 타입으로 반환한다.

####  Sorting
- `sorted` 메서드는 Comparator 인터페이스를 인수로 받아 정렬하여 스트림을 반환하는 중간 연산이다.

#### For-each
- `forEach` 메서드는 Consumer 인터페이스를 인수로 받아 코드를 실행하여 void형을 반환하는 최종 연산이다.
- 병렬 스트림에서는 forEach의 실행 순서를 보장할 수 없다. 스트림의 순서대로 조회하고 싶은 경우 `forEachOrdered`를 사용해야 한다. 단 병렬성으로 얻는 이점이 떨어진다.

#### Collecting
- 스트림의 요소들을 모아서 결과를 만들 때 `collect` 메서드를 사용한다.
- collect 메서드는 `Collector` 인스턴스를 인수로 받는다.
	- 예제에서 흔히 사용했던 `collect(toList())` 를 보자. toList()는 스트림의 모든 요소를 List에 수집해주는 Collector를 반환하는 팩토리 메서드이다.


### Stateless vs Stateful 연산
- map, filter 등은 일반적으로 (파라미터로 넘긴 코드 블록이 상태를 가지고 있지 않는 한) 내부 상태를 가지지 않는 stateless 연산이다.
- 하지만 reduce, sum, max 같은 연산은 중간 결과를 저장할 내부 상태가 필요한 stateful 연산이다. 단 스트림에서 처리하는 요소들의 개수와는 관계없이 내부 상태의 크기는 한정(bounded)되어 있다. (stateful bound)
- 또한 sorted, distinct 같은 연산도 stateful 연산이다. 단 이들은 정렬 혹은 중복 제거를 수행하기 위하여 스트림의 모든 요소를 버퍼에 저장해야 한다. 따라서 스트림의 크기가 너무 크거나 무한이라면 문제가 생길 수 있다. (stateful unbound)


### 기본형(Primitive Type) 특화 스트림
```
int calories = menuList.stream()
			.map(Dish::getCalories) // Stream<Dish> 타입 반환
			.reduce(0, Integer::sum);
```
- 위의 코드에는 Boxing 비용이 숨어있다. 내부적으로 합계를 계산하기 위해 Integer를 기본형(Primitive Type)으로 언박싱해야 한다.
- Java 8의 스트림 API에서는 박싱 과정을 효율적으로 처리할 수 있도록 Int, Long, Double 세가지 타입에 대해 기본형 특화 스트림을 제공한다. 
	- IntStream, LongStream, DoubleStream
- 기본형 특화 스트림들은 sum, max, average 등의 숫자 관련 유틸리티 메서드를 제공한다.
- 기본형 특화 스트림들은 다시 객체 스트림으로 복원이 가능하다.

#### 기본형 특화 스트림으로 변환하기
- map 대신 mapToInt, mapToDouble, mapToLong 메서드를 사용
- 기본형 특화 스트림으로 변환 후 sum 메서드를 사용하면 쉽게 합계를 구할 수 있음. 
	- 빈 스트림일 경우 sum 메서드는 기본값 0을 반환함.

```
int calories = menuList.stream()		  // Stream<Dish> 타입 반환
    .mapToInt(Dish::getCalories) // IntStream 타입 반환
    .sum();		// IntStream 인터페이스의 sum 메서드 이용
```

#### 기본형 특화 스트림에서 객체 스트림으로 변환하기
```
IntStream is = menuList.stream().mapToInt(Dish:getCalories);

// boxed 메서드 이용
Stream<Integer> stream = intStream.boxed();

// mapToObj 메서드 이용
Stream<Integer> stream2 = intStream.mapToObj(n -> n);
```

#### 기본값 Optional
- 기본형 특화 스트림이 비어있을 경우, sum 메서드는 기본값 0을 반환한다.
- 반면 max, min 등의 메서드 등은 기본값이 아닌 Optional 타입을 반환형으로 가진다.
	- OptionalInt, OptionalDouble, OptionalLong

```
OptionalInt maxCalories = menuList.stream( // Stream 타입 반환
    .mapToInt(Dish::getCalories) // IntStream 타입 반환
    .max();

// 값이 없을 경우 사용할 기본값을 명시적으로 설정
int max = maxCalories.orElse(-1);
```


### 스트림 생성
#### 컬렉션을 스트림으로 변환
- `stream()`,  `parallelStream()` 메서드 이용

#### 숫자 범위를 지정하여 숫자 스트림 생성
- IntStream, LongStream 에서는 range, rangeClosed 메서드를 제공한다. 두 메서드 모두 시작값과 종료값을 인수로 받는데, 해당 범위 내의 숫자들을 스트림으로 생성한다.
- `range` 메서드는 시작값과 종료값이 결과에 포함되지 않는다.
- `rangeClosed` 메서드는 시작값과 종료값이 결과에 포함된다.

```
IntStream is = IntStream.rangeClosed(1, 100);
```

#### 값으로 스트림 생성
- `Stream.of` 메서드를 이용하면 임의의 값들을 스트림으로 만들 수 있다.

```
Stream<String> s1 = Stream.of("Java", "C", "C++");
Stream<String> s2 = Stream.of("Python", "Ruby");

IntStream is = IntStream.of(1, 2, 3, 4, 5);
```

#### 두 개의 스트림을 합쳐서 새로운 스트림 생성
- `Stream.concat` 메서드를 사용하면 두 개의 스트림을 이어붙일 수 있다.

```
Stream<Integer> s1 = Stream.of(1, 2, 3);
Stream<Integer> s2 = Stream.of(4, 5, 6);
 
Stream<Integer> concatStream = Stream.concat(s1, s2);
```

#### Empty 스트림 생성
- `Stream.empty()` 메서드를 사용하면 빈 스트림을 만들거나, 스트림을 비울 수 있다.

#### Nullable 스트림 생성
- 객체의 값이 null이 될 수도 있는 경우 `Stream.ofNullable` 메서드를 이용한다. 만약 객체의 값이 null일 경우 empty 스트림을 반환해준다.

```
// System.getProperty(env)의 값은 존재할 수도 있고 null 일수도 있음
Stream<String> s = Stream.ofNullable(System.getProperty(env));
```

#### 배열로 스트림 생성
- `Arrays.stream` 메서드를 사용하면 배열을 인수로 전달하여 스트림을 만들 수 있다.

```
int numbers = {2, 3, 5, 7, 9};
IntStream is = Arrays.stream(numbers);

// 추출할 인덱스 지정
IntStream is2 = Arrays.stream(numbers, 0, 2);
```

#### 파일로 스트림 생성
- `Files.lines` 메서드를 사용하면 인수로 주어진 파일의 행들을 스트림으로 반환한다.
- 스트림 인터페이스는 AutoCloseable 인터페이스를 구현하므로, finally 블록 등에서 자원을 직접 해제해줄 필요가 없다.

#### 문자열로 스트림 생성

```
// 문자열의 각 문자들로 char 스트림 생성
IntStream charsStream = "String".chars();

// 정규식을 이용하여 문자열 스트림 생성
Stream<String> stringStream = Pattern.compile(" ").splitAsStream("Java C C++");
```

#### Random 난수로 스트림 생성
- Random 인스턴스의 `ints`, `doubles`, `longs` 메서드로 원하는 개수만큼 난수 스트림을 생성할 수 있다.

```
IntStream ints = new Random().ints(3);
DoubleStream doubles = new Random().doubles(4);
LongStream longs = new Random().longs(5);
```

#### Stream builder로 스트림 생성
```
Stream.Builder<String> builder = Stream.builder();
Stream<String> s = builder.add("String").add("String").add("String").build();
```

#### 무한 스트림 (Infinity Stream) 생성
- Stream.iterate 메서드, Stream.generate 메서드의 두 가지 방법이 있다.

##### iterate 메서드
- `iterate` 메서드는 `연속된 일련의 값`을 만들 때 사용한다. 초기값과 람다식을 인수로 받는다. 요청할 때마다 새로운 값을 순차적으로 생산한다.
- 끝이 따로 없는 무한 스트림이며, unbounded stream 이라고도 한다.

```
// 0 부터 시작하여 무한 스트림 생성
Stream.iterate(0, n -> n + 4)
		 .limit(10).forEach(System.out::println);
```

- iterate 메서드의 두 번째 인수로 Predicate를 전달하면 언제까지 스트림을 생성할지 지정할 수 있다.

```
// 0 ~ 99 까지만 스트림 생성
IntStream.iterate(0, n -> n < 100, n -> n + 4)
 			.forEach(System.out::println);

// takeWhile을 이용해서 동일한 효과를 낼 수도 있다
IntStream.iterate(0, n -> n + 4)
			.takeWhile(n -> n < 100)
 			.forEach(System.out::println);
```

##### generate 메서드
- `generate` 메서드는 Supplier<T> 인터페이스를 인수로 받아서 새로운 값을 생산한다.
- 요구할 때마다 람다식을 수행해 값을 생산해낸다는 점은 iterate와 같지만, generate는 값들을 연속적으로  생산하지는 않는다.

```
System.generate(Math::random)
		 .limit(5)
		 .forEach(System.out::println);
```


---

References
- Java 8 in Action - 한빛미디어


