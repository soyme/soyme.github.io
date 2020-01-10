---
layout: post
title: MapReduce 기본 개념
category: blog
tags: [general]
---

대용량 데이터를 다루는 문제가 주어졌을 때, 여러대의 프로세서에 분산시켜 병렬적으로 처리할 수 있다. `MapReduce`는 이러한 문제를 해결하기 위해 사용하는 하나의 프로그래밍 모델이다. 또는 이러한 프로그래밍 모델을 구현한 프레임워크이다.

MapReduce는 크게 Map() 함수와 Reduce() 함수로 구성된다. Map() 함수를 통해 원하는 데이터를 추출하고, Reduce() 함수를 통해 summarize 한다는 컨셉이다.

### MapReduce example
아래와 같이 1~5 단계가 `순차적으로` 수행된다.

##### 1. prepare the Map() input
파일시스템, DBMS 등 storage에서 raw data를 읽어온 뒤 적당한 크기의 chunk 단위로 쪼갠다. 그리고 각 chunk들을 각각의 Map() 프로세서들에게 할당한다.

##### 2. Map(key, value) 
각각의 input에 대하여 병렬적으로 Map() 함수가 수행된다. Map() 함수의 내용은 사용자가 원하는 방향으로 구현한다. 각 input에 대한 처리를 통해 새로운 key-value 쌍을 output으로 만들어내는데 이 때 key-value 쌍은 0개일수도, 여러개일수도 있다.

예를 들어, 문장에서 나오는 단어 갯수를 카운트하는 경우

```
input: { "line1" : "word1 word2 word2 word3 word3 word3 ..." }
output: {
    "word1" : "1",
  	"word2" : "2",
   	"word3" : "3"
}
```

##### 3. Shuffle the Map() output to the Reduce() input
Map() 함수가 만들어낸 모든 output에 대하여, key를 기준으로 grouping한다. 그리고 grouping한 각각의 데이터를 Reduce() 프로세서들에게 할당한다.

```
Map() output 1:   { "word1" : "1", "word2" : "2", "word3" : "3" } 
Map() output 2:  { "word2" : "4", "word3" : "5", "word4" : "6" }

Shuffle's result: {
	{ "word1" : ["1"] }, 
	{ "word2" : ["2", "4"] },
	{ "word3" : ["3" , "5"] },
	{ "word4" : ["6"] }	
}
```

##### 4. Reduce(key, list of values)
각각의 input에 대하여 병렬적으로 Reduce() 함수가 수행된다. Reduce() 함수의 내용은 사용자가 원하는 방향으로 구현한다. 일반적으로 input data에 대한 summary를 만든다.

```
input:  { "word3" : ["3" , "5"]  }
output:  { "word3" : "8" }
```

##### 5. Produce final output
Reduce() 함수가 만들어낸 모든 output을 취합하여 원하는 형태의 최종 output을 만들어 낸다.

```
Reduce() output 1:   { "word2" : "6" }
Reduce() output 2:  { "word3" : "8" }

final output:	{
	{ "word2" : "6" },
	{ "word3" : "8" }
}
```

------

Reference: <https://en.wikipedia.org/wiki/MapReduce>
