---
layout: post
title: Zookeeper and Apache Curator
category: blog
tags: [general]
align: left

---

Zookeeper에 대한 간단한 소개와 Apache Curator를 사용하여 개발을 진행하면서 알게된 내용들을 정리해본다.

<!-- more -->

### Zookeeper
* 분산된 시스템의 coordination 서비스. 여러 프로세스들간의 협력, 경합을 조절해준다.
* 데이터는 Tree 형태로 구성된다.
* 분산 시스템에서 공통 설정 정보, 각 서버들의 상태 정보를 공유하는데에 주로 사용된다.


#### Znode
* 주키퍼의 데이터 단위.
* Tree의 각 노드.
* Znode는 디렉토리이면서 동시에 파일이다. 자식 Znode를 가질 수 있고, 데이터를 가질 수도 있다.
* 각 노드의 full path가 데이터를 찾는 key가 된다.
* 모든 Znode는 타임스탬프, 데이터 버전, 크기, 자식 수, owner 등의 통계 정보(Stat)를 갖는다.
* Znode를 생성할 때 `PERSISTENT`모드 혹은 `EPHEMERAL`모드 중 선택할 수 있다.
  * EPHEMERAL 모드로 만들 경우, Zookeeper 서버와 해당 Client간 세션이 끊어지면 노드가 자동으로 삭제된다.
  * EPHEMERAL 모드의 노드는 자식을 가질 수 없다.

#### Watch
* 특정 Znode의 변경(생성/삭제/업데이트/자식 변경)에 대한 알림을 받고자 할 때 Watcher를 등록한다.
* getData(), getChildren(), exist() 등 모든 읽기 작업에 watch를 설정할 수 있다.
* watch는 기본적으로 한 번 발생하면 끝나는 일회성 트리거이다. 한 번 알림을 받고 계속해서 알림을 받으려면 watch를 다시 등록해야 한다.
* 이러한 단점을 극복하기 위해 Zookeeper 3.6+ 부터는 영구적, 재귀적으로 watch를 할 수 있는 [PersistentWatcher](https://github.com/apache/curator/pull/335)가 추가되었다. 
  * 하지만 우리는 Zookeeper 3.4 버전을 사용 중...  :cry:

### Curator
* Zookeepr를 위한 JVM client library.
* [Zookeeper Receipes](https://zookeeper.apache.org/doc/r3.6.0/recipes.html)에서 가이드 되어있는 고차원 기능들이 모두 구현되어 있어서 그대로 사용하면 된다.
  * [https://curator.apache.org/curator-recipes/index.html](https://curator.apache.org/curator-recipes/index.html)
* 기본적인 사용법은 Apache Curator [document](https://curator.apache.org/getting-started.html)에 잘 정리되어있다.
* 그 외에 개발을 진행하면서 알게 된 것들, 인상 깊었던 것들을 아래에 적어본다.


#### Watch Event Loss
- Watcher를 등록한다고 하더라도, 모든 변경에 대한 이벤트를 받는다고 보장하지 못한다.
- Watcher는 기본적으로 한 번 발생하는 일회성 트리거이므로 한 번 이벤트가 발생한 뒤에도 계속 알림을 받으려면 Watcher를 다시 등록하는 작업이 필요하다. 여기서 다시 등록하는 사이에 발생한 이벤트들은 놓치게 된다.
- 즉 이벤트를 놓치면 절대 안되는 경우 무언가 다른 조치가 필요할 것이다.

#### NOT use ZooKeeper for Queue
* Zookeeper를 일종의 메시지 큐로 사용할 수 있도록 몇몇의 [Queue 레시피](https://curator.apache.org/curator-recipes/distributed-queue.html)들이 존재한다. 하지만 공식적으로, 주키퍼를 Queue로 사용하는 것은 권장하지 않는다고 한다.
* 대용량 메세지 큐가 필요한 것이라면 RabbitMQ나 Kafka 등이 적합하다.
* 참고: [https://cwiki.apache.org/confluence/display/CURATOR/TN4](https://cwiki.apache.org/confluence/display/CURATOR/TN4)
> ZooKeeper has a 1MB transport limitation. In practice this means that ZNodes must be relatively small. Typically, queues can contain many thousands of messages.
ZooKeeper can slow down considerably on startup if there are many large ZNodes. This will be common if you are using ZooKeeper for queues. You will need to significantly increase initLimit and syncLimit.<br><br>
If a ZNode gets too big it can be extremely difficult to clean. getChildren() will fail on the node. At Netflix we had to create a special-purpose program that had a huge value for jute.maxbuffer in order to get the nodes and delete them.
ZooKeeper can start to perform badly if there are many nodes with thousands of children.<br><br>
The ZooKeeper database is kept entirely in memory. So, you can never have more messages than can fit in memory.


#### Queue items's path name
- Recipe의 Queue를 사용하면 znode 이름을 마음대로 지정할 수 없다. Zookeeper의 Reciepe 문서에 그렇게 가이드되어있다. 생각해보면 Queue이기 때문에 key-value 형태로 사용하는 것이 아니라, 단일 item으로 사용하는 것이 자연스럽다.
> The distributed clients put something into the queue by calling create() with a pathname ending in "queue-", with the sequence and ephemeral flags in the create() call set to true. Because the sequence flag is set, the new pathnames will have the form path-to-queue-node/queue-X, where X is a monotonic increasing number
- 우리 시스템은 다른 컴포넌트에서 znode를 produce 해주면 내 쪽에서는 consume 하는 구조였다. 하지만 내부적인 이유로 미리 정해진 znode 이름을 사용해야 했기 때문에 Reciepe Queue의 구현을 그대로 사용할 수 없었다.
- 이쯤부터 Zookeeper 말고 Kafka를 사용해야 하나 조금 고민이 되었다. 분산 락을 이용해야 해서 Zookeeper를 사용한 것이긴 한데 Queue도, Watcher도 사용하기 애매한 상황이었다.


### Curator Cache
- Apache Curator에서 제공하는 Cache는 말 그대로 캐시이다. Zookeeper 데이터의 일정 부분을 로컬 메모리에 유지하고, 내부적으로 Watcher를 등록한다. 이벤트가 발생하면 sync를 맞추는 것이다.
- Cache의 데이터는 가장 최신의 데이터가 아닐 수도 있다.
- Watcher와 유사하게, Cache된 노드들이 변경되었을 때 처리할 Event Listener를 등록할 수 있다.
- Zookeeper 3.4 에서는 NodeCache, PathChildrenCache, TreeCache를 사용할 수 있다.
- Zookeeper 3.6+ 에 추가된 [CuratorCache](https://curator.apache.org/curator-recipes/curator-cache.html)는 위에서 언급한 3가지 캐시의 기능을 모두 포함하고 있어서 기존의 Cache 클래스들은 Deprecated 되었다.

#### NodeCache
한 개의 노드에 대한 캐시를 구성한다. 해당 노드 자체의 생성/변경/삭제를 감시할 수 있다.

#### PathChildrenCache (PathCache)
* 특정한 path에 대한 캐시를 구성한다.
* 캐시한 path의 하위에 자식 노드가 생성/변경/삭제되었을 경우에는 EventListner가 호출되지만, 자식 밑에 또 자식이 추가/삭제되는 것 까지는 감시되지 않는다.
  * `/root`에 대해 PathChildrenCache를 생성할 경우, `/root/child1`에 대한 변경은 watch가 되지만 `/root/child1/child2`, `/root/child1/child2/child3` 등에 대해서는 watch가 되지 않는다.
  * 자식 노드 이하에도 watch를 하고 싶다면 모든 자식들에 대하여 새로운 Cache를 재귀적으로 생성해야 한다. [참고](https://stackoverflow.com/questions/12098084/is-it-possible-to-watch-for-events-on-all-descendant-nodes-in-zookeeper)
* 모든 하위 노드들에 대해 감시가 필요한 경우 후술할 TreeCache가 좀 더 적합하다.

```java
final PathChildrenCache cache = new PathChildrenCache(client, "root", true);
final PathChildrenCacheListener listener = new PathChildrenCacheListener() {
    @Override
    public void childEvent(CuratorFramework client, PathChildrenCacheEvent event) throws Exception {
        final String path = event.getData().getPath();
        switch (event.getType()) {
            case INITIALIZED:
                System.out.println("Initialized: " + path);
                break;
            case CHILD_ADDED: {
                System.out.println("Node added: " + path);
                break;
            }
            case CHILD_UPDATED: {
                System.out.println("Node changed: " + path);
                break;
            }
            case CHILD_REMOVED: {
                System.out.println("Node removed: " + path);
                break;
            }
            default:
                System.out.println("Connection changed: " + event.getType() + ", path: " + path);
        }
    }
};

cache.getListenable().addListener(listener);
cache.start()
```


#### TreeCache
* 특정 path 하위의 모든 노드들에 대해 생성/변경/삭제를 감시한다.
* 몇단계의 depth까지 감시할지 지정할 수도 있다.
* path 구조와 Stat(통계정보)만 캐시할지, 노드의 데이터까지 캐시할지 선택할 수 있다.
* iterate() 메소드를 이용하여 Tree를 탐색할 수 있다.

```java
final TreeCache cache = TreeCache.newBuilder(client, "/root").setCacheData(true).setMaxDepth(3).build();

final TreeCacheListener listener = new TreeCacheListener(){
    @Override
    public void childEvent(CuratorFramework client, TreeCacheEvent event) throws Exception {
        final String path = event.getData().getPath();
        switch (event.getType()){
            case INITIALIZED:
                System.out.println("Initialized: " + path);
                break;
            case NODE_ADDED: {
                System.out.println("Node added: " + path);
                break;
            }
            case NODE_UPDATED: {
                System.out.println("Node changed: " + path);
                break;
            }
            case NODE_REMOVED: {
                System.out.println("Node removed: " + path);
                break;
            }
            default:
                System.out.println("Connection changed: " + event.getType() + ", path: " + path);
        }
    }
};

cache.getListenable().addListener(listener);
cache.start();
```
 



---

References
- [Zookeeper Programming Guide](https://zookeeper.apache.org/doc/r3.6.0/zookeeperProgrammers.html)
- [Zookeeper Reciepes](https://zookeeper.apache.org/doc/r3.6.0/recipes.html#sc_recipes_Queues)
- [Apache Curator Reciepes](https://curator.apache.org/curator-recipes/index.html)
