---
layout: post
title: node.js heapdump 생성하기
category: blog
tags: [general, javascript]

---
> FATAL ERROR: CALL_AND_RETRY_2 Allocation failed - process out of memory

유지보수를 맡고있는 node로 된 batch 서비스가 자꾸 죽는다.. :cry:

<!-- more -->

1. `npm install heapdump`
2. 메인이 되는 js 파일에 `var heapdump = require('heapdump');`

이렇게만 하면 일단 준비는 완료.

heapdump를 생성하고자 하는 타이밍에 `kill -SIGUSR2 <pid>` 를 날리면 동일 디렉토리에 heapdump 파일이 생긴다.

혹은 코드 내의 원하는 곳에 `heapdump.writeSnapshot(filename);` 을 명시적으로 넣어도 됨. `filename`은 지정하지 않을시 기본 파일명(heapdump-현재시간..이었나)으로 생성됨. setInterval을 이용하여 특정 시간 간격으로 writeSnapshot을 호출하는 것도 한 가지 방법임.

이렇게 생성된 heapdump 파일을 어떻게 보냐면
크롬 브라우저의 개발자도구 > Profiles 에서 Load만 하면 촤르륵 뜸 >.<


