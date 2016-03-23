---
layout: post
title: Double Ended Linked List
category: blog
tags: [java, algorithm]
---
`Double Ended Linked List`란 리스트의 맨 앞을 가리키는 HEAD 포인터 뿐 아니라, 리스트의 맨 뒤를 가리키는 TAIL 포인터 또한 가지고 있는 링크드리스트이다. 이는 `Double Linked List`와 다르다. 더블 링크드리스트는 각 노드가 prevNode 및 nextNode의 링크를 모두 가지고 있는 것이고, 지금 여기서의 Double Ended 링크드리스트는 리스트 전체에서 한 개의 HEAD 포인터와 한 개의 TAIL를 가지고 있는 것이다.

<!-- more -->

### 구현 예제
- 원소가 하나도 없을 때 뿐 아니라 디큐시에 원소가 하나만 있을 때도 고려 필요
- enqueue를 맨 앞, 맨 뒤, 원하는 위치에서 할 수 있도록 구현 (가장 첫 위치는 1으로 가정)
- dequeue를 맨 앞, 맨 뒤에 할 수 있도록 구현
- 큐 순회하며 데이터 출력하는 printQueue 메소드도 구현

허허.. 복잡하다 제대로 한건지 모르겠넹

```java
public class LinkedListQueue {
  
    private Node head = null;
    private Node tail = null;
     
    public void enqueueAtTail(int data) {
         
        Node newNode = new Node(data, null);
         
        if(head == null)  // 큐가 비어있다면
            head = newNode;
        else
            tail.setNextNode(newNode);
  
        tail = newNode;
         
        System.out.println("< EnQueueAtTail: " + newNode.getData());
        printQueue();
    }
     
    public void enqueueAtHead(int data) {
        Node newNode = new Node(data, null);
         
        newNode.setNextNode(head);
        head = newNode;
        if(tail == null)  // 빈 큐였었다면
            tail = newNode;        
  
        System.out.println("< EnQueueAtHead: " + newNode.getData());
        printQueue();
    }
     
    public void enqueueAtIndex(int data, int index) {
         
        if(index <= 1) {
            enqueueAtHead(data);
        }
        else {
            Node prevNode = head;
             
            int i = 2;
            while(i < index && prevNode != null) {
                prevNode = prevNode.getNextNode();
                i++;
            }
             
            if(prevNode == null) {
                System.out.println("Index Error");
                return;
            }
             
            Node nextNode = prevNode.getNextNode();
            Node newNode = new Node(data, null);
            prevNode.setNextNode(newNode);
             
            if(nextNode == null)
                tail = newNode;
            else
                newNode.setNextNode(nextNode);
             
            System.out.println("< EnQueueAtIndex: " + newNode.getData());
            printQueue();
        }
         
    }
     
    public int dequeueAtHead() {
        if(head == null) // 큐가 비어있다면
            return -1;
         
        Node newNode = head;
        head = head.getNextNode();
         
        if(head == null) // 큐에 원소가 하나밖에 없었다면, 이제 빈 큐가 됨
            tail = null;
         
        System.out.println("> DeQueueAtHead: " + newNode.getData());
        printQueue();
         
        return newNode.getData();
    }
     
    public int dequeueAtTail() {
        if(head == tail) {
            dequeueAtHead();
        }
         
        if(head == null) // 큐가 비어있다면
            return -1;
         
        Node prevNode = head;
  
        while(prevNode.getNextNode().getNextNode() != null) {
            prevNode = prevNode.getNextNode();
        }
         
        prevNode.setNextNode(null);
         
        Node newNode = tail;  // prevNode.getNextNode(); 와 동일
        tail = prevNode;
         
        System.out.println("> DeQueueAtTail: " + newNode.getData());
        printQueue();
         
        return newNode.getData();
    }    
     
    public void printQueue() {
        Node node = head;
        while(node != null) {
            System.out.print(node.getData() + ", ");
            node = node.getNextNode();
        }
        System.out.println();
    }
     
    public static void main(String[] args) {
        LinkedListQueue queue = new LinkedListQueue();
        queue.enqueueAtHead(3);
        queue.enqueueAtHead(2);
  
        queue.enqueueAtHead(1);
        queue.dequeueAtTail();
        queue.dequeueAtTail();
        queue.dequeueAtTail();
    }
}
  
class Node {
    private int data;
    private Node nextNode;
     
    public Node(int data, Node nextNode) {
        this.data = data;
        this.nextNode = nextNode;
    }
  
    public int getData() {
        return data;
    }
  
    public void setData(int data) {
        this.data = data;
    }
  
    public Node getNextNode() {
        return nextNode;
    }
  
    public void setNextNode(Node nextNode) {
        this.nextNode = nextNode;
    }
}
```