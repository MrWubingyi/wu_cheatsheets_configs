1、简介
      libpcap是unix/linux平台下的网络数据包捕获函数包，大多数网络监控软件都以它为基础。Libpcap可以在绝大多数类unix平台下工作.

2、功能

（1）数据包捕获
      捕获流经本网卡的所有原始数据包，甚至对交换设备中的数据包也能够进行捕获，本功能是嗅探器的基础。
（2）自定义数据包发送
      构造任意格式的原始数据包，并发送到目标网络，本功能是新协议验证、甚至攻击验证的基础。
（3）流量采集与统计
      对所采集到的网络中的流量信息进行按照新规则分类，按指标进行统计，并输出到指定终端。利用这项功能可以分析目标网络的流量特性。
（4）规则过滤
      Libpcap自带规则过滤功能，并提供脚本编程接口，能够按照用户编程的方式对已经采集到的数据包进行过滤，以便提高分析的性能。

3、工作原理
      一个包捕获机制包含三个主要部分，分别是面向底层的包捕获引擎，面向中间层的数据包过滤器，面向应用层的用户接口。      
      Linux操作系统对于数据包的处理流程是从底到上的方式，依次经历网络接口卡、网卡驱动层、数据链路层、IP层、传输层，最后到达应用程序。
      Libpcap也是基于这种原理，Libpcap的捕获机制并不影响Linux操作系统中网络协议栈对数据包的处理。
      对应用程序而言，Libpcap包捕获机制只是提供了一个统一的API接口，用户只需要按照相关的编程流程，简单地调用若干函数就可以捕获到感兴趣的数据包。

      具体来说，Libpcap库主要由三个部分组成，网络分接头、数据包过滤器和用户API。
（1）网络分接头
      网络分接头（Network Tap）是一种链路层旁路机制，负责采集网卡数据包。
（2）数据包过滤器
      数据包过滤器(Packet Filter)是针对数据包的一种过滤机制，在Libpcap中采用BPF(BSD Packet Filter)算法对数据包执行过滤操作，这种算法的基本思想就是基于规则匹配，对伊符合条件的额数据包进行放行。
（3）用户API
      用户API是Libpcap面向上层应用程序提供的编程接口，用户通过调用相关的函数实现数据包的捕获或者发送。
      具体来说，Libpcap的工作原理可以描述为，当一个数据包到达网卡时，Libpcap利用创建的套接字从链路层驱动程序中获得该数据包的拷贝，即旁路机制，同时通过Tap函数将数据包发给BPF过滤器。
      BPF过滤器根据用户已经定义好的过滤过则对数据包进行逐一匹配，若匹配成功则放入内核缓冲区，并传递给用户缓冲区，匹配失败则直接丢弃。如果没有设置过滤规则，所有的数据包都将放入内核缓冲区，并传递给用户缓冲区。
      其具体的工作流程如下图所示：
4、libpcap编译

(1)下载官网链接：https://www.tcpdump.org/release/

后续所有调试与相关代码环境如下：
 CentOS Linux release 7.4.1708 (Core)    libpcap.so.1.11.0
4.2 编译安装
 make clean

 ./configure --with-pcap=linux --prefix=/root/libpcap CC=gcc

 make

 make install
注：
configure 修改自己的安装目录（prefix）=/root/libpcap，和编译器即可(CC)gcc
。
至此libpcap编译成功

有时候你运行程序时发现程序仍提示找不到libpcap库，此时执行以下命令：

find / -name libpacp.so  
find / -name libpacp.so.1
我的libpacp.so.1库在目录：/root/libpcap /lib/ 所以将其拷贝到/usr/lib下一份
cp /root/libpcap /lib/libpcap.so /usr/lib/
cp /root/libpcap /libpcap.so.1 /usr/lib/


要使用libpcap，我们必须包含pcap.h头文件，可以在/root/libpcap/pcap/pcap.h找到，其中包含了每个类型定义的详细说明。

编写测试程序
 include<stdio.h>

 include<pcap.h>

 int main(int argc,char*argv[])
 {   char *dev,errbuf[PCAP_ERRBUF_SIZE];
    dev=pcap_lookupdev(errbuf);
    if(dev==NULL)
    {
        fprintf(stderr,"couldn't find defult device:%s\n");
        return(2);
    }
    printf("device: %s\n",dev);
    return(0);}
输入
 gcc -o device test.c -g–lpcap
编译
注意后面的 -lpcap ，否则会提示“pcap_lookupdev 未定义的引用”的错误；

lpcap会链接/lib64/当中的/lib64/libpcap.so.1 (0x00007f4c138c7000)

 getop()
 while (opt=getopt(argc,argv,"hi:n:")!=-1)
 {

    switch (opt)
    {
    case 'h':
    printf("usage: %s [-h] [-i interface] [-n count] [BPF expression]\n", argv[0]);
            exit(0);
        break;
    case 'i':
    strcpy(device, optarg);
            break;
    break;
    case 'n':
     count = atoi(optarg);
    break;
    }

 }
识别输入参数
 int getopt (int ___argc, char *const *___argv, const char *__shortopts)
例如 ./device –h –i 123 –n 1233
i:n:表示i后可加空格加参数，n后可加空格加参数
i::表示i后必须不加空格加参数，如-i12346


1.获取网络接口

首先我们需要获取监听的网络接口：
函数原型
char * pcap_lookupdev(char * errbuf)
上面这个函数返回第一个合适的网络接口的字符串指针，如果出错，则errbuf存放出错信息字符串，errbuf至少应该是PCAP_ERRBUF_SIZE个字节长度的。注意，很多libpcap函数都有这个参数。
pcap_lookupdev()一般可以在跨平台的，且各个平台上的网络接口名称都不相同的情况下使用。
经测试，本机第一个设备为nflog，无法使用，且编译提示建议使用pcap_findalldevs函数，1.10.0版本以后不建议使用该接口
 pcap_geterr(handle)

函数原型
 char *pcap_geterr(pcap_t *p)
返回最后一个pcap库错误消息。
 pcap_findalldevs(pcap_if_t ** alldevs, char * errbuf);
返回所有的网络接口名称。
参数详解
alldevs是pcap_if_t结构体指针
 struct pcap_if {

  struct pcap_if *next; 
  char *name;   /*设备名称 */
  char *description;  /* textual description of interface, or NULL */
  struct pcap_addr *addresses;
  bpf_u_int32 flags;  /* PCAP_IF_ interface flags */

 };

 struct pcap_addr {

  struct pcap_addr *next;
  struct sockaddr *addr;    /* 地址 */
  struct sockaddr *netmask; /* 掩码 for that address */
  struct sockaddr *broadaddr; /* broadcast address for that address */
  struct sockaddr *dstaddr; /* P2P destination address for that address */

 };
用于存储查找到的所有网络设备信息。errbuf C语言字符串缓存区用于缓冲错误信息。

函数原型
 pcap_lookupnet(const char *dev, bpf_u_int32 *net, bpf_u_int32 *mask, char * errbuf);
第一个参数：输入Dev设备名称
第二个参数：输出net ip地址
第三个参数：输出mask 子网掩码
第四个参数：errbuf错误信息的数组



2.释放网络接口
定义收到停止信号时，关闭捕获

   //定义收到停止信号时进行的操作
    signal(SIGINT, stop_capture);
    signal(SIGTERM, stop_capture);
    signal(SIGQUIT, stop_capture);

 void stop_capture(int signo)
 {

    struct pcap_stat stats;

    if (pcap_stats(handle, &stats) >= 0) {
        printf("\n%d packets captured\n", packets);
        printf("%d packets received\n", stats.ps_recv);
        printf("%d packets dropped\n\n", stats.ps_drop);
    }
    pcap_close(handle);
    exit(0);

 }
数据包统计函数、
函数原型 
 int pcap_stats(pcap_t *p, struct pcap_stat *ps)
函数功能：向pcap_stat结构赋值。成功时返回0。这些数值包括了从开始捕获数据以来至今共捕获到的数据包统计。如果出错或不支持数据包统计，则返回-1，且可调用pcap_perror()或pcap_geterr()函数来获取错误消息。

2.在操作为网络接口后，我们应该要释放它：
函数原型
 void pcap_close(pcap_t *handle) 
函数功能：关闭handle参数相应的文件，并释放资源。该函数用于关闭pcap_open_live()获取的pcap_t的网络接口对象并释放相关资源。

3.打开网络接口
   handle = pcap_open_live(device, BUFSIZ, 1, 1000, errbuf);
函数原型
 pcap_t * pcap_open_live(const char * device, int snaplen, int promisc, int to_ms, char * errbuf)
上面这个函数会返回指定接口的pcap_t类型指针，后面的所有操作都要使用这个指针。
第一个参数：是第一步获取的网络接口字符串，可以直接使用硬编码。
第二个参数：是对于每个数据包，从开头要抓多少个字节，我们可以设置这个值来只抓每个数据包的头部，而不关心具体的内容。典型的以太网帧长度是1518字节，但其他的某些协议的数据包会更长一点，但任何一个协议的一个数据包长度都必然小于65535个字节。
第三个参数：指定是否打开混杂模式(Promiscuous Mode)，0表示非混杂模式，任何其他值表示混合模式。如果要打开混杂模式，那么网卡必须也要打开混杂模式，可以使用如下的命令打开eth0混杂模式：
ifconfig eth0 promisc
第四个参数：指定需要等待的毫秒数，超过这个数值后，第3步获取数据包的这几个函数就会立即返回。0表示一直等待直到有数据包到来。
第五个参数：是存放出错信息的数组。


过滤器函数
 pcap_compile(handle, &bpf, filter, 0, netmask)
用于将字符串str编译为过滤器程序。

函数原型
 int pcap_compile(pcap_t *p, struct bpf_program *fp,char *str, int optimize, bpf_u_int32 netmask)
将str参数指定的字符串编译到过滤程序中。

fp是一个bpf_program结构的指针，在pcap_compile()函数中被赋值。
optimize参数控制结果代码的优化。
netmask参数指定本地网络的网络掩码。
 pcap_setfilter(handle, &bpf)
函数原型
 int pcap_setfilter(pcap_t *p, struct bpf_program *fp)
指定一个过滤程序。
fp参数是bpf_program结构指针，通常取自pcap_compile()函数调用。出错时返回-1；成功时返回0。





4.获取数据包
打开网络接口后就已经开始监听了
第一步 获取包头长度
/// @brief 获取头长度
/// @param handle 
void get_link_header_len(pcap_t* handle)
{
    int linktype;
 
    // Determine the datalink layer type.
    if ((linktype = pcap_datalink(handle)) == PCAP_ERROR) {
        fprintf(stderr, "pcap_datalink(): %s\n", pcap_geterr(handle));
        return;
    }
 
    // Set the datalink layer header size.
    switch (linktype)
    {
    case DLT_NULL:
        linkhdrlen = 4;
        break;
 
    case DLT_EN10MB:
        linkhdrlen = 14;
        break;
 
    case DLT_SLIP:
    case DLT_PPP:
        linkhdrlen = 24;
        break;
 
    default:
        printf("Unsupported datalink (%d)\n", linktype);
        linkhdrlen = 0;
    }
}


 pcap_datalink(handle)
函数原型   
int pcap_datalink(pcap_t *p)
返回数据链路层类型，例如
DLT_EN10MB。
DLT_NULL
DLT_SLIP
DLT_PPP



如何知道收到了数据包呢?有下面3种方法：
 a)u_char * pcap_next(pcap_t * p, struct pcap_pkthdr * h)
如果返回值为NULL，表示没有抓到包；这个函数只要收到一个数据包后就会立即返回。
第一个参数是第2步返回的pcap_t类型的指针
第二个参数是保存收到的第一个数据包的pcap_pkthdr类型的指针
pcap_pkthdr类型的定义如下：

struct pcap_pkthdr
 {

  struct timeval ts;    /* time stamp */
  bpf_u_int32 caplen;   /* length of portion present */
  bpf_u_int32 len;      /* length this packet (off wire) */

 };
b)   
 int pcap_loop(pcap_t * p, int cnt, pcap_handler callback, u_char * user)
第一个参数是第2步返回的pcap_t类型的指针
第二个参数是需要抓的数据包的个数，一旦抓到了cnt个数据包，pcap_loop立即返回。负数的cnt表示pcap_loop永远循环抓包，直到出现错误。
第三个参数是一个回调函数指针，它必须是如下的形式：void callback(u_char * userarg, const struct pcap_pkthdr * pkthdr, const u_char * packet)
callback是pcap_handler类型的变量

第一个参数是pcap_loop的最后一个参数，当收到足够数量的包后pcap_loop会调用callback回调函数，同时将pcap_loop()的user参数传递给它
第二个参数是收到的数据包的pcap_pkthdr类型的指针
第三个参数是收到的数据包数据

 
通过callback打印出抓到包的内容
 void packet_handler(u_char *user, const struct pcap_pkthdr *packethdr, const u_char *packetptr)
<blockquote>
 {
</blockquote>
    struct iphdr* iphdr;
    struct icmp* icmphdr;
    struct tcphdr* tcphdr;
    struct udphdr* udphdr;
    char iphdrInfo[256];
    char srcip[256];
    char dstip[256];
    struct in_addr ip_in_addr={NULL};
<blockquote>
     // 跳过网卡层  linkhdrlen字节.
</blockquote>
 packetptr += linkhdrlen;
 //将pcaket指针指向ip头
<blockquote>
    iphdr = (struct ip*)packetptr;
   // ip_in_addr.s_addr=iphdr->saddr;
    strcpy(srcip, inet_ntoa(*(struct in_addr*)(&iphdr->saddr)));
    ip_in_addr.s_addr=iphdr->daddr;
    strcpy(dstip, inet_ntoa(ip_in_addr));
    sprintf(iphdrInfo, "ID:%d TOS:0x%x, TTL:%d IpLen:%d DgLen:%d Protocil:%d SrcIP:%s DstIP:%s",
            ntohs(iphdr->id), iphdr->tos, iphdr->ttl,
            4*iphdr->ihl, ntohs(iphdr->tot_len),iphdr->protocol,srcip,dstip);
    printf("%s\n", iphdrInfo);
</blockquote>
 <br />c)   int pcap_dispatch(pcap_t * p, int cnt, pcap_handler callback, u_char * user)
这个函数和pcap_loop()非常类似，只是在超过to_ms毫秒后就会返回(to_ms是pcap_open_live()的第4个参数)

 

 

5.分析数据包
我们既然已经抓到数据包了，那么我们要开始分析了，这部分留给读者自己完成，具体内容可以参考相关的网络协议说明。要特别注意一点，网络上的数据是网络字节顺序的，因此分析前需要转换为主机字节顺序(ntohs()函数)。
这里是编写的callback函数，用于处理pcap_loop发回的数据包
pcap_loop中的回调函数格式：
 void packet_handler(u_char *user, const struct pcap_pkthdr *packethdr, const u_char *packetptr)
这是一个用户提供的有着三个参数的子函数。定义为：

这三个参数中，user,是传递给pcap_dispatch（）的那个参数；packethdr,是个pcap_pkthdr类型的指针，是savefile中的数据报的头指针，packetptr，指向数据报数据；这个函数允许用户定义子集的数据报过滤程序；


 pcap_open_offline(file_name,errBuf);
函数原型：pcap_t *pcap_open_offline(char *fname, char *ebuf) 
函数功能：打开以前保存捕获数据包的文件，用于读取。 
参数说明：fname参数指定打开的文件名。该文件中的数据格式与tcpdump和tcpslice兼容。”-“为标准输入。ebuf参数则仅在pcap_open_offline()函数出错返回NULL时用于传递错误消息。



函数名称：void pcap_dump(u_char *user, struct pcap_pkthdr *h,u_char *sp) 
函数功能：向调用pcap_dump_open()函数打开的文件输出一个数据包。该函数可作为pcap_dispatch()函数的回调函数。
    pcap_dump_close(pcap_dfile);
 
函数原型：
 void pcap_dump_close(pcap_dumper_t *p)
函数功能：关闭相应的被打开文件。

pcap_t* p = pcap_open_dead(LINKTYPE_ETHERNET,65535);//创建一个pcap_t句柄而不打开捕获操作
函数原型：pcap_t* p = pcap_open_dead(int LINKTYPE, int snaplen);
函数功能：创建一个pcap_t句柄而不打开捕获操作
参数说明：LINKTYPE为网络类型，第二个参数：是对于每个数据包，从开头要抓多少个字节，我们可以设置这个值来只抓每个数据包的头部，而不关心具体的内容。典型的以太网帧长度是1518字节，但其他的某些协议的数据包会更长一点，但任何一个协议的一个数据包长度都必然小于65535个字节。


    pcap_dfile = pcap_dump_open(p,file_name_out);
函数原型：pcap_dumper_t *pcap_dump_open(pcap_t *p, char *fname) 
函数功能：打开用于保存捕获数据包的文件，用于写入。 
参数说明：fname 参数为”-“时表示标准输出。出错时返回NULL。p参数为调用pcap_open_offline()或pcap_open_live()函数后返回的 pcap结构指针。fname参数指定打开的文件名。如果返回NULL，则可调用pcap_geterr()函数获取错误消 息。


6.过滤数据包
我们抓到的数据包往往很多，如何过滤掉我们不感兴趣的数据包呢?几乎所有的操作系统(BSD, AIX, Mac OS, Linux等)都会在内核中提供过滤数据包的方法，主要都是基于BSD Packet Filter(BPF)结构的。libpcap利用BPF来过滤数据包。
过滤数据包需要完成3件事：

构造一个过滤表达式
编译这个表达式
应用这个过滤器
a)  BPF使用一种类似于汇编语言的语法书写过滤表达式，不过libpcap和tcpdump都把它封装成更高级且更容易的语法了，具体可以man tcpdump，以下是一些例子： 

语法	涵义
src host 192.168.1.177 	只接收源ip地址是192.168.1.177的数据包
dst port 80 	只接收tcp/udp的目的端口是80的数据包
not tcp	只接收不使用tcp协议的数据包
tcp[13] == 0x02 and (dst port 22 or dst port 23)	只接收SYN标志位置位且目标端口是22或23的数据包（tcp首部开始的第13个字节）
icmp[icmptype] == icmp-echoreply or icmp[icmptype] == icmp-echo	只接收icmp的ping请求和ping响应的数据包
ehter dst 00:e0:09:c1:0e:82	只接收以太网mac地址是00:e0:09:c1:0e:82的数据包
ip[8] == 5	只接收ip的ttl=5的数据包（ip首部开始的第8个字节）


b)   构造完过滤表达式后，我们需要编译它，使用如下函数：
 int pcap_compile(pcap_t * p, struct bpf_program * fp, char * str, int optimize, bpf_u_int32 netmask)
fp：这是一个传出参数，存放编译后的bpf
str：过滤表达式
optimize：是否需要优化过滤表达式
metmask：简单设置为0即可

c)   最后我们需要应用这个过滤表达式：
int pcap_setfilter(pcap_t * p,  struct bpf_program * fp)
第二个参数fp就是前一步pcap_compile()的第二个参数

应用完过滤表达式之后我们便可以使用pcap_loop()或pcap_next()等抓包函数来抓包了。

 

7.网卡ip与掩码格式转换
 int pcap_lookupnet(const char * device, bpf_u_int32 * netp, bpf_u_int32 * maskp, char * errbuf)
可以获取指定设备的ip地址，子网掩码等信息

netp：传出参数，指定网络接口的ip地址

maskp：传出参数，指定网络接口的子网掩码

pcap_lookupnet()失败返回-1
我们使用inet_ntoa()将其转换为可读的点分十进制形式的字符串
