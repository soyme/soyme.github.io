---
layout: post
title: Proxy 환경에서 Tomcat 설정에 Real IP 셋팅하기
category: blog
tags: [general]
align: left

---

Proxy 환경에서 tomcat 로그에 `127.0.0.1`이 찍힐 때,

<!-- more -->

- Problem: nginx를 사용하는데, tomcat access log에 real IP가 찍히지 않고 `127.0.0.1`이 찍힘. 게다가 코드 내에서 사용하는 모듈중에 http request의 ip를 외부 서버에서 인터셉트해가는 부분이 있는데 여기에도 127.0.0.1이 전달되서 문제임.
- Cuase: proxy를 사용하니까 localhost IP가 찍히게 되는..
- Solve: tomcat의 xml 파일 설정 변경. 다른 방법도 있긴 하지만 이렇게 해결했다.


```
// RemoteIpValve Valve 추가
<Valve className="org.apache.catalina.valves.RemoteIpValve" remoteIpHeader="X-Real-IP" />

// 기존의 AccessLogValve에 requestAttributesEnabled="true"를 추가
<Valve className="org.apache.catalina.valves.AccessLogValve" rotatable="true" fileDateFormat="'.'yyyyMMdd" directory="logs" prefix="access_log" pattern="%h %l %u %t &quot;%r&quot; %s %b &quot;%{Referer}i&quot; &quot;%{User-Agent}i&quot; &quot;-:- - %T %{_usersession_}i - %{page_uid}i - - -&quot; %{NNB}c - - &quot;-&quot;" resolveHosts="false" requestAttributesEnabled="true" />
```