---
layout: post
title: Iterator 패턴
category: blog
tags: [java, pattern]
---
무엇인가 많이 모여있는 집합체의 요소들을 통일된 방법으로, 순서대로 접근하는 방법.

<!-- more -->


### 구현 예시

집합체를 나타내는 인터페이스인 Aggregate를 생성하고, Iterator를 만들어서 반환해주는 메소드인 iterator()를 정의한다.

```java
public interface Aggregate {
    public abstract Iterator iterator();
}
```

Aggregate 인터페이스를 구현한 콘크리트 클래스를 작성하고 iterator()를 오버라이드 한다.

```java
public class BookShelf implements Aggregate {
    private Book[] books;
    private int last = 0;
    public BookShelf(int maxsize) {
        this.books = new Book[maxsize];
    }
    public Book getBookAt(int index) {
        return books[index];
    }
    public void appendBook(Book book) {
        this.books[last] = book;
        last++;
    }
    public int getLength() {
        return last;
    }
    public Iterator iterator() {    // BookShelfIterator 타입이 아닌 Iterator 타입으로 반환
        return new BookShelfIterator(this);
    }
}
```

Iterator 인터페이스 내에 집합체의 요소들을 순서대로 접근하기 위한 메소드를 정의한다.

```java
public interface Iterator {
    public abstract boolean hasNext();  // 다음에 next()를 호출해도 괜찮은지를 조사
    public abstract Object next();      // 현재의 요소를 반환하면서, 다음 위치로 이동
}
```

Iterator 인터페이스를 구현한 콘크리트 클래스를 작성하고 hasNext(), next()를 오버라이드한다. 의도에 따라 접근 방향을 정방향, 역방향 등으로 구현 가능하다. 또한 이 클래스는 접근할 집합체인 bookShelf를 인스턴스 변수로 가지고 있다 (aggregation 관계).

```java
public class BookShelfIterator implements Iterator {
    private BookShelf bookShelf;
    private int index;
    public BookShelfIterator(BookShelf bookShelf) {
        this.bookShelf = bookShelf;
        this.index = 0;
    }
    public boolean hasNext() {
        if (index < bookShelf.getLength()) {
            return true;
        } else {
            return false;
        }
    }
    public Object next() {
        Book book = bookShelf.getBookAt(index);
        index++;
        return book;
    }
}
```

마지막으로 메인 클래스를 작성한다.

```java
public class Main {
    public static void main(String[] args) {
        BookShelf bookShelf = new BookShelf(4);
        bookShelf.appendBook(new Book("Around the World in 80 Days"));
        bookShelf.appendBook(new Book("Bible"));
        bookShelf.appendBook(new Book("Cinderella"));
        bookShelf.appendBook(new Book("Daddy-Long-Legs"));

        Iterator it = bookShelf.iterator();  // BookShelfIterator 타입이 아닌 Iterator 타입으로 반환받음
        while (it.hasNext()) {
            Book book = (Book)it.next();
            System.out.println(book.getName());
        }
    }
}
```

### 특징 및 장점
Iterator를 사용하면, 사용(메인 메소드의 while문)과 구현을 분리할 수 있다. 또한 BookShelf 클래스의 구현 방법이 바뀌어도, 메인 메소드는 수정할 필요가 없다.
