---
layout: post
title: 오라클 / MySQL 쿼리 결과 랜덤으로 가져오기
category: blog
tags: [database]
---
조회된 쿼리 결과 중 랜덤으로 N건만 출력하는 방법.

<!-- more -->

### MySQL
```
SELECT *
FROM table
ORDER BY RAND()
LIMIT 5
```

### Oracle
```
SELECT *
FROM
(
  SELECT * FROM table
  ORDER BY dbms_random.value
)
WHERE rownum <= 5
```