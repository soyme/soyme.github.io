---
layout: post
title: Proxy 환경에서 톰캣 설정에 Real IP 셋팅하기
category: blog
tags: []
align: left

---

간만에 유의미한 이슈를 맞이하여 포스팅해본다.

- 문제: nginx를 사용하는데, tomcat access log에 real IP가 찍히지 않고 `127.0.0.1`이 찍힘. 게다가 코드 내에서 사용하는 모듈중에 http request의 ip를 외부 서버에서 인터셉트해가는 부분이 있는데 여기에도 127.0.0.1이 전달되서 문제임.
- 원인: proxy 사용하니까 localhost ip가 찍히는거지..
- 해결: tomcat xml 파일 설정 변경

<!-- more -->

```
 <Valve className="org.apache.catalina.valves.RemoteIpValve" remoteIpHeader="X-Real-IP" />

<Valve className="org.apache.catalina.valves.AccessLogValve" rotatable="true"
fileDateFormat="'.'yyyyMMdd" directory="logs" prefix="access_log"
pattern="%h %l %u %t &quot;%r&quot; %s %b &quot;%{Referer}i&quot; &quot;%{User-Agent}i&quot; &quot;-:- - %T %{_usersession_}i - %{page_uid}i - - -&quot; %{NNB}c - - &quot;-&quot;"
resolveHosts="false" requestAttributesEnabled="true" />
```
