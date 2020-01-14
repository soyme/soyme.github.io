---
layout: post
title: AWS EC2, node.js로 웹서비스 구축하기
category: diary
tags: []
align: left

---

문득 취미삼아 개발할만한 서비스 아이디어가 생각나서 최근 몇일간 버닝해보았다.
일단 다 만들어놓고 나니 홍보를 어떻게 하고 유저를 어떻게 끌어모아야 할지 고민이긴 하지만, 굉장히 오랜만에 서비스 하나를 처음부터 만들어서 서버에 띄워놓으니 은근히 뿌듯하다.

수행했던 일련의 과정을 간략하게 적어본다.


<!-- more -->

### Setting
* AWS 셋팅
  * EC2 프리티어로 기본 설치
  * security group에 사용할 각종 포트번호 추가
  * billing alarm 추가 
* 도메인 구입. 이용한 업체는 호스팅케이알 (https://www.hosting.kr)
* AWS Route 53 으로 도메인, 서브도메인 설정
* 각종 로그 파일들과, html static 파일이 위치할 디렉토리 구조 셋팅.
* 서버에 nginx 설치 후 config 셋팅 및 구동

  ~~~ bash
  $ sudo vi /etc/nginx/nginx.conf
  $ sudo service nginx restart
  ~~~
 
* 서버에 nodejs 설치 - [link](https://nodejs.org/en/download/package-manager/#enterprise-linux-and-fedora)
* 서버에 mysql 설치

  ~~~ bash
  # ec2 security group에 3306 포트 추가 후,
  $ sudo yum update -y
  $ sudo yum install mysql56-server
  $ sudo service mysqld start
  $ mysqladmin -u root password 
  $ mysql -u root -p
  ~~~

* 서버에 redis 설치 - 세션 관리를 redis로 할거라서
  * EC2 security group 에 16379, 6379 포트를 추가
  * https://openmind8735.com/aws/redis/2017/07/21/aws-ec2-%EC%9D%B8%EC%8A%A4%ED%84%B4%EC%8A%A4%EC%97%90-redis-%EC%84%A4%EC%B9%98%ED%95%98%EA%B8%B0/ 이거 따라하니 슝슝 잘 됨.
* 소셜 로그인을 위해서 Google API key 발급. 일단 구글만 달려고 함.

### Development & Deployment
* local에서 열심히 개발 및 테스트. 사실 이 과정이 가장 오래 걸리지만..
* real database 셋팅
  * 로컬에서 개발시는 로컬 DB를 사용했던지라 서버의 DB도 셋팅
  * Database 스키마가 어느정도 확정되면 서버 mysql에 생성.
  * 코드에 사용된 쿼리들 점검하고 필요한 인덱스 생성해줌. (데이터가 얼마나 쌓이겠냐마는 그래도..)
* 서버에 git 설치하고, git repo 생성.
* local에서 push, 서버에서 pull
* 드디어 서버에서 run!
  * nohup으로 node app을 띄우는게 잘 안됌.
  * StrongLoop 설치하려고 하니 자꾸 에러나서 결국 해결 못함.
  * 포기하고 forever 설치
* 서비스 개시 `forever start ./app.js`

### TO DO
* log file rotation 설정 필요
* warn level 이상의 에러 로깅시 이메일 등을 통해 나에게 알람이 올 수 있도록
* 무언가 하나가 죽었거나 제대로 돌아가지 않을 때를 대비한 health check 스크립트. 역시 나에게 알람이 오도록
* 코드 리팩토링.