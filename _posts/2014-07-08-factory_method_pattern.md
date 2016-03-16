---
layout: post_page
title: 팩토리 메소드 패턴
tag: Java, 디자인패턴
---

`팩토리 메소드 패턴`은 `템플릿 메소드 패턴`을 인스턴스 생성에 적용한 전형적인 예이다. 팩토리(인스턴스를 생성하는 공장)를 템플릿 메소드 패턴으로 구성한 것이 팩토리 메소드 패턴이다.

- 인스턴스를 만드는 방법을 상위 클래스에서 결정한다. 이름이나 구체적인 방법은 결정하지 않는다.
- 구체적인 내용은 하위클래스측에서 구현함으로써 인스턴스 생성을 위한 골격과 실제 인스턴스 생성에 사용되는 클래스를 분리한다.

<!-- more -->

### 구현 예시
```java
package framework;
  
public abstract class Product {
    public abstract void use();
}
```
product(인스턴스)가 가져야 할 인터페이스(API)를 추상메소드로 규정하고, 구현은 하위클래스에게 위임한다.

```java
package framework;
  
public abstract class Factory {
    public final Product create(String owner) {
        Product p = createProduct(owner);
        registerProduct(p);
        return p;
    }
    protected abstract Product createProduct(String owner);
    protected abstract void registerProduct(Product product);
}
```
공장에서는 제품을 생성할 때 생성->등록->반환 순으로 처리된다는 골격을 규정하고, 생성과 등록의 구현은 하위클래스에게 하도록 위임한다. 상위클래스는 createProduct 메소드를 호출하면 Product 인스턴스가 생성되어 반환된다는 정보만 알 뿐 createProduct 메소드의 세부 구현 내용은 몰라도 된다. `new` 키워드를 사용하여 Product 인스턴스를 생성하지 않고, 인스턴스 생성을 위한 메소드를 호출함으로서 구체적인 클래스 이름에 의한 속박에서 상위 클래스를 자유롭게 만든다.

```java
package idcard;
import framework.*;
  
public class IDCard extends Product {
    private String owner;
    IDCard(String owner) {
        System.out.println(owner + "의 카드를 만듭니다.");
        this.owner = owner;
    }
    public void use() {
        System.out.println(owner + "의 카드를 사용합니다.");
    }
    public String getOwner() {
        return owner;
    }
}
```
Product 추상클래스를 상속받아 원하는 제품 클래스를 만든다. 추상메소드 use()를 구현한다. 제품이 사용되는 모습을 구현하되 구체적으로 어떻게 사용되는지는 하위클래스가 결정한다.

```java
package idcard;
import framework.*;
import java.util.*;
  
public class IDCardFactory extends Factory {
    private List owners = new ArrayList();
    protected Product createProduct(String owner) {
        return new IDCard(owner);
    }
    protected void registerProduct(Product product) {
        owners.add(((IDCard)product).getOwner());
    }
    public List getOwners() {
        return owners;
    }
}
```
Factory 추상클래스를 상속받은 하위클래스는, Factory의 추상메소드들을 그 목적에 맞게 구현한다. 제품을 등록-registerProduct, 제품을 생성하여 반환-createProduct한다는 본래의 목적에 맞도록 구현하되, 생성/등록을 구체적으로 어떤 방법으로 할지는 하위클래스가 결정하게 된다.


```java
import framework.*;
import idcard.*;
  
public class Main {
    public static void main(String[] args) {
        Factory factory = new IDCardFactory();
        Product card1 = factory.create("홍길동");
        Product card2 = factory.create("이순신");
        Product card3 = factory.create("강감찬");
        card1.use();
        card2.use();
        card3.use();
    }
}
```
framework 패키지(Factory, Product)는 idcard 패키지(IDCardFactory, IDCard)에 의존하지 않는다. 즉 idcard 패키지에 대한 정보를 전혀 가지고 있지 않다. framework 패키지를 상속받아 구현하였다면 다른 어떤 product들도 같은 방법으로 사용될 수 있다. 이 때 framework 패키지의 내용을 수정할 필요가 없다.
