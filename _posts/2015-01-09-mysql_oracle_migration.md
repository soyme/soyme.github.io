---
layout: post
title: MySQL 쿼리를 오라클 쿼리로 변경하기
category: blog
tags: [database]
---
데이터베이스를 MySQL에서 Oracle로 이전하면서 진행했던 쿼리 수정 작업을 정리해본다.

<!-- more -->

### SELECT 1
MySQL에서는 `SELECT 1`과 같은 쿼리가 가능하다. (validationQuery가 보통 이런 식이다.) 그러나 오라클에서는 SELECT 문에 FROM 절이 필수이므로, FROM 절이 필요 없는 쿼리에는 `FROM dual`을 붙여준다.


### 날짜 표기 함수 변경
윗줄이 MySQL 표현이고 아랫줄이 오라클 표현이다.

```
// 현재 시간 (년월일시분초)
DATE_FORMAT(NOW(),'%Y%m%d%H%i%s')
TO_CHAR(SYSDATE,'YYYYMMDDhh24miss')

// 현재 시간 (년월일)
DATE_FORMAT(NOW(),'%Y%m%d')
TO_CHAR(SYSDATE,'YYYYMMDD')

// 1초 후
DATE_FORMAT(DATE_ADD(NOW() , INTERVAL + 1 SECOND),'%Y%m%d%H%i%s')
TO_CHAR(SYSDATE+1/24/60/60,'YYYYMMDDhh24miss')

// 5초 후
DATE_FORMAT(DATE_ADD(NOW() , INTERVAL + 5 SECOND),'%Y%m%d%H%i%s')
TO_CHAR(SYSDATE+5/24/60/60,'YYYYMMDDhh24miss')

// 20분 후
DATE_FORMAT(DATE_ADD(NOW() , INTERVAL + 20 MINUTE),'%Y%m%d%H%i%s')
TO_CHAR(SYSDATE+20/24/60,'YYYYMMDDhh24miss')

// 20분 전
DATE_FORMAT(DATE_ADD(NOW() , INTERVAL - 20 MINUTE),'%Y%m%d%H%i%s')
TO_CHAR(SYSDATE-20/24/60,'YYYYMMDDhh24miss')

// 하루전
TO_CHAR(SYSDATE-1,'YYYYMMDDhh24miss')

// 내일(하루 후)
DATE_FORMAT(DATE_ADD(NOW() , INTERVAL + 1 DAY),'%Y%m%d')
TO_CHAR(SYSDATE+1,'YYYYMMDD')

// 31일전
DATE_FORMAT(DATE_ADD(NOW() , INTERVAL - 31 DAY),'%Y%m%d%H%i%s')
TO_CHAR(SYSDATE-31,'YYYYMMDDhh24miss')

// 31일전 말고 한달 전으로 표현할 수 도 있음
TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMMDDhh24miss')

// 7일전
DATE_FORMAT(DATE_ADD(NOW() , INTERVAL - 7 DAY),'%Y%m%d%H%i%s')
TO_CHAR(SYSDATE-7,'YYYYMMDDhh24miss')

// 현재 월의 마지막날 (년월일)
DATE_FORMAT(LAST_DAY(NOW()), '%Y%m%d')
TO_CHAR(LAST_DAY(SYSDATE),'YYYYMMDD')
```

### LIMIT 처리 변경
윗줄이 MySQL 표현이고 아랫줄이 오라클 표현이다. MySQL은 LIMIT을 적용할 때 인덱스가 0부터이고, 오라클은 1부터임에 유의한다.

##### 최상단의 한 건만 뽑을 때
```
SELECT * FROM TEST LIMIT 1;
SELECT * FROM TEST WHERE rownum = 1;
```

##### 최상단의 N건 뽑을 때.
```
SELECT * FROM TEST LIMIT 0, 2;

SELECT * FROM
  (
  SELECT
    TEST.*,
    row_number() over (ORDER BY 1) as LIMIT_NUM
  FROM TEST
  )
WHERE LIMIT_NUM BETWEEN 1 AND 2
```

##### 내림차순으로 최상단의 N건 뽑을 때
```
SELECT * FROM TEST LIMIT 0, 2 ORDER BY A DESC;

SELECT * FROM
  (
  SELECT
    TEST.*,
    row_number() over (ORDER BY A DESC) as LIMIT_NUM
  FROM TEST
  )
WHERE LIMIT_NUM BETWEEN 1 AND 2
```

### IF NULL 처리 변경
IF(ISNULL(조건컬럼), 'NULL일 때 표시할 값')

-> `NVL('조건컬럼', 'NULL일 때 표시할 값')`

IFNULL(조건컬럼, 'NULL일 때 표시할 값')

-> `NVL('조건컬럼', 'NULL일 때 표시할 값')`

결과 레코드가 한 건도 없을 때도 'NULL일 때 표시할 값'을 나타내고 싶다면

-> `NVL(MAX('조건컬럼'), 'NULL일 때 표시할 값')`

### SEQUENCE
MySQL에서는 AUTO_INCREMENT 옵션이면 다 되었지만, Oracle에서는 시퀀스 또한 별개의 객체로 직접 관리해줘야 한다.

1. AUTO_INCREMENT 컬럼이 존재하는 테이블마다 사용할 SEQUENCE 생성.
2. AUTO_INCREMENT 컬럼이 존재하는 테이블의 INSERT문 수정. INSERT 되는 값으로 [ 시퀀스명.nextval ] 사용
 - 마이바티스에서 `SelectKey`를 사용하는 경우의 쿼리문은 SELECT 시퀀스명.nextval FROM dual

### length 0인 empty String ('') -> NULL 처리
MySQL에서는 length 0인 empty string을 하나의 값으로서 사용할 수 있으나, 오라클에서는 empty string을 NULL과 같이 처리한다. 즉 not null인 컬럼의 값을 '' 으로 셋팅이 불가능하다. 이에 따른 쿼리 변경 및 application 소스 수정이 필요함. 꽤 많은 작업이 필요할수도 ㅠㅠ

### CONCAT()
MySQL에서는 CONCAT 함수의 인자 수가 제한이 없으나, Oracle에서는 두 개의 인자만 갖는다.
CONCAT(1,2,3,4,5) 이랬던 것을 아래와 같이 수정

 - 1 \|\| 2 \|\| 3 \|\| 4 \|\| 5  이렇게 해도 되고
 - CONCAT( CONCAT( CONCAT (CONCAT(1,2), 3), 4), 5) 그냥 이렇게 해도 된다.

### GROUP_CONCAT()
MySQL에서는 GROUP_CONCAT()이 있고, 오라클에서는 이와 유사한 기능을 해주는 WM_CONCAT()이 있다.

그리고 MySQL에서는 GROUP_CONCAT을 쓰면 자동으로 해당 컬럼으로 GroupBy 처리가 된다. 또한 GROUPBY 조건에 포함되지 않는 컬럼을 SELECT 절에 포함할 때는, 최상위의 레코드의 값을 사용하는 것 같다. 하지만 오라클은 GROUPBY 조건에 포함되지 않는 컬럼을 SELECT 절에 포함시키지 못한다. 즉 SELECT절에 있는 컬럼들을 모두 GroupBy 조건으로 이용해야 한다.

### 조인할 때 조인 대상이 되는 테이블의 'AS' 제거
오라클에서는 AS 키워드를 넣지 않더라.. 그냥 이렇게 `AS` 키워드만 빼면 됨.
SELECT * FROM TABLE1 INNER JOIN TABLE2 AS T2 ON TABLE1.ID=T2.ID;
 > SELECT * FROM TABLE1 INNER JOIN TABLE2 T2 ON TABLE1.ID=T2.ID;

### 참고사항
 - INSERT INTO ON DUPLICATE KEY UPDATE : INSERT를 날린 후, 키가 중복될때는 UPDATE
 - INSERT IGNORE INTO : INSERT를 날린 후, 키가 중복되도 에러(?)를 발생하지 않고 그냥 넘어감
 - REPLACE INTO : (중복되든 아니든) DELETE를 일단 날린 후, 새로 INSERT


### INSERT INTO ON DUPLICATE KEY UPDATE
```
MERGE INTO 테이블명
    USING DUAL ON (ID = #{id}) // KEY 중복 조건
    WHEN MATCHED THEN
        // KEY 중복 조건이 만족할 때에는 기존 레코드 UPDATE
        UPDATE SET A='값', B='값'

        WHEN NOT MATCHED THEN
            // 중복 조건이 만족하지 않을 때에는 신규 레코드 INSERT
            INSERT (ID, A, B) VALUES ('#{id}', '값', '값')
```

### INSERT IGNORE INTO
```
MERGE INTO 테이블명
    USING DUAL ON (ID = #{id})  // KEY 중복 조건
    WHEN NOT MATCHED THEN
        // 중복 조건이 만족하지 않을 때에는 신규 레코드 INSERT
        INSERT (ID, A, B) VALUES ('#{id}', '값', '값')
```

### REPLACE INTO
굳이 중복되는 행을 꼭 DELETE하고 싶다면 소스상에서 처리한다. UPDATE로 처리해도 괜찮다면 INSERT INTO ON DUPLICATE KEY UPDATE와 비슷하게 처리한다.

### 하나의 쿼리로 2개의 테이블을 UPDATE 하는 경우
```
UPDATE TABLE1, TABLE2
SET TABLE1.A='값', TABLE2.B='값'
WHERE 조인조건
```
MySQL에서는 이게 가능하지만 오라클에서는 불가능하다. 쿼리상에서 처리하는 방법은 아직까지는 찾지 못함. 마이바티스나 소스 내에서 처리로 변경.

### RIGHT, LEFT 함수
MySQL에는 있지만 오라클에는 없다. SUBSTR 함수를 이용하여 동일하게 표시 가능하다.

```
SUBSTR("문자열", 3)		// 3번째자리부터 나옴. LEFT 함수 대신 사용 가능
SUBSTR("문자열", 3, 4)	// 3번째자리부터  4문자 나옴
SUBSTR("문자열", -3)		// 맨 뒤에서부터 3문자 나옴. RIGHT 함수 대신 사용 가능
```

### GROUP BY 절에 테이블의 alias명 사용
```
SELECT 컬럼명 AS 별칭 FROM TEST
GROUP BY 별칭
```
MySQL에서는 이게 가능하나, 오라클에서는 GROUP BY 절에서 alias명을 사용할 수 없다. 그냥 원래 컬럼명을 사용하던가, 아니면 SELECT 문으로 한번 더 감싸주면 된다.

```
SELECT * FROM
(SELECT 컬럼명 AS 별칭 FROM TEST)
GROUP BY 별칭;
```
