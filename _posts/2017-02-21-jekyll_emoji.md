---
layout: post
title: Jekyll 블로그에서 Emoji 사용하기
category: diary
tags: []
align: left

---

Emoji Plugin 달았다.
:laughing::heart: 신난다:bangbang::bangbang:

예전에는 이모지 싫어했었는데, Github 쓰면서 자꾸 보다 보니 정이 들었다.:relaxed:

<!-- more -->


### Jekyll 블로그에 Emoji Plugin 설치하기
엄청 간단하다. 정말 이 세상엔 없는 게 없다..:stuck_out_tongue_closed_eyes:
> [https://github.com/jekyll/jemoji](https://github.com/jekyll/jemoji)



1. `GemFile`에 추가

   ```
   gem 'jemoji'
   ```
2. `_config.yml`에 추가

   ```
   gems:
      - jemoji
   ```
3. 예쁘게 보이도록 적당히 스타일을 추가해줘도 된다.

   ```
   .emoji {
        margin: 0px 2px 3px 2px;
   }
   ```

### Emoji Cheat Sheet
[http://www.webpagefx.com/tools/emoji-cheat-sheet](http://www.webpagefx.com/tools/emoji-cheat-sheet)