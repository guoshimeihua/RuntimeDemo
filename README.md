##iOS Crash 杀手排名

> 随着公司嘟嘟牛app用户数量多了起来，崩溃的问题也多了起来，最近这几天终于得空，集中时间处理了一下崩溃的问题，现总结一下，希望对大家有所帮助。

###杀手 NO.1
####NSInvalidArgumentException 异常
出现这个crash的原因有很多，选取了崩溃次数较多的crash。 

**crash 日志1-1**

	-[__NSPlaceholderDictionary initWithObjects:forKeys:count:]: attempt to insert nil object from objects[3]
	
crash日志拿到了，怎么复现该现象呢？我们看到initWithObjects:forKeys:count:，猜测一下应该是NSDictionary初始化时的问题，在看后面的提示attempt to insert nil object，此时就可以做一个猜测，应该是NSDictionary初始化时插入nil对象造成的异常。下面我们写一段代码来验证一下：
	
	NSString *password = nil;
    NSDictionary *dict = @{
                           @"userName": @"bruce",
                           @"password": password
                           };
    NSLog(@"dict is : %@", dict);

运行过后，崩溃信息如下: 


![Crash 日志1-1](http://upload-images.jianshu.io/upload_images/416556-f3368e3fd81bea96.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

上面的崩溃信息证明了我们的猜测。从崩溃日志记录中，查询到该问题的崩溃记录有33条（总崩溃记录304条），占10.85%，崩溃率比较高。为什么会出现这种现象呢？如何解决这样的crash呢？

**崩溃率高的原因是因为自己的框架中采用了去model化的设计思想，不会把后台返回的数据转换成model，而是通过一个reformer机制转换成NSDictionary形式，提供给目标对象使用，在转换成NSDictionary的过程中，后台返回的数据有时可能为空，就会造成插入nil对象，从而导致crash。**

有3种方案可以解决该问题，如下：

方案一：后台在返回数据的时候进行校验，对空值进行处理。但是在项目中有些空值是有特殊的用途，此种方案不可行。

方案二：在转换成NSDictionary的时候，对后台返回的数据进行校验，把空值转换成NSNull对象。**方案可行，但是需要对现有代码做大的改动，每次转换的时候都需要进行校验，太麻烦。业务高速发展时期，这样做成本太高。**

方案三：有没有一种无须改动现有代码又能解决该问题呢？**答案是有的，可以利用Objective-C的runtime来解决该问题。**

**NSDictionary插入nil对象会造成崩溃，但是插入NSNull对象是不会造成崩溃的，只要利用runtime的Swizzle Method把nil对象给转换成NSNull对象就可以把该问题给解决了。**创建一个NSDictionary的类别，利用runtime的Swizzle Method来替换系统的方法。源码实现可以参考Glow团队封装的NSDictionary+NilSafe(Github上可下载到), **全部源码会在文章末尾提供**，现截取其中的部分代码如下：

	+ (instancetype)gl_dictionaryWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt {
    	id safeObjects[cnt];
    	id safeKeys[cnt];
    	NSUInteger j = 0;
    	for (NSUInteger i = 0; i < cnt; i++) {
        	id key = keys[i];
        	id obj = objects[i];
        	if (!key) {
            	continue;
        	}
        	if (!obj) {
            	obj = [NSNull null];
        	}
        	safeKeys[j] = key;
        	safeObjects[j] = obj;
        	j++;
    	}
    	return [self gl_dictionaryWithObjects:safeObjects forKeys:safeKeys count:j];
	}

** crash 日志1-2 **
	
	data parameter is nil

通过日志信息，可以把崩溃问题定位到参数为nil的情况，在看了下堆栈的日志信息，**把问题定位到了NSJSONSerialization序列化的时候，传入data为nil，造成的崩溃。**为了验证是不是该问题，我写了一段代码做了下验证：

	NSData *data = nil;
    NSError *error;
    NSDictionary *orginDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"originDict is : %@", orginDict);

运行后，崩溃信息如下：

![Crash日志 1-2](http://upload-images.jianshu.io/upload_images/416556-6e8c28429b0820d3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这个问题比较好解决，在序列化的时候，统一加入判断，判断data是不是nil即可。

** crash 日志1-3 **
	
	unrecognized selector sent to instance 0x15d23910
	
造成这条崩溃的原因，想必大家都比较熟悉了，**就是一个类调用了一个不存在的方法，造成的崩溃。**解决这样的问题，可以在写一个方法的时候，判断一下其类的类型，不符合类型的不让其调用，也可以使用runtime对常见的方法调用做一下错误兼容。比如我这边经常会出现这样的崩溃：

	-[__NSCFConstantString objectForKeyedSubscript:]: unrecognized selector sent to instance 0x1741af420
	-[NSNull length]: unrecognized selector sent to instance 0x1b21e6ef8	
	-[__NSCFConstantString objectForKeyedSubscript:]: unrecognized selector sent to instance
	-[__NSDictionaryI length]: unrecognized selector sent to instance 0x174264500
	
当这些对象调用这几个不存在的方法的时候，替换成自己定义的一个方法，对它们做一下错误兼容，使应用不会崩溃。现截取部分代码实现，**全部源码会在文章末尾提供**。	

	@implementation NSString (NSRangeException)
    
    + (void)load{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            @autoreleasepool {
                [objc_getClass("__NSCFConstantString") swizzleMethod:@selector(objectForKeyedSubscript:) swizzledSelector:@selector(replace_objectForKeyedSubscript:)];
            }
        });
    }
    
    - (id)replace_objectForKeyedSubscript:(NSString *)key {
        return nil;
    }
    
    @end

小结一下，造成NSInvalidArgumentException异常大概有以下原因: 

* NSDictionary插入nil的对象。NSMutableDictionary也是同样的道理。
* NSJSONSerialization序列化的时候，传入data为nil。
* an unrecognized selector 无法识别的方法

**NSInvalidArgumentException的崩溃记录有149条（总崩溃记录304条），占49.01%，称霸Crash界，杀手排名第一。**

###杀手 NO.2
####SIGSEGV 异常 

SIGSEGV是当SEGV发生的时候，让代码终止的标识。**当去访问没有被开辟的内存或者已经被释放的内存时，就会发生这样的异常。另外，在低内存的时候，也可能会产生这样的异常。**

对于这样的异常，我们可以使用两种方式来解决，一种方式使用Xcode自带的内存分析工具(Leaks)，一种是使用facebook提供的自动化工具来监测内存泄漏问题，如: 
[FBRetainCycleDetector、FBAllocationTracker、FBMemoryProfiler](https://code.facebook.com/posts/583946315094347/automatic-memory-leak-detection-on-ios/)

例子1: 

	dataOut = malloc(dataOutAvailable * sizeof(uint8_t));
	
这是使用Xcode自带的Leaks工具检测到的内存泄漏，通过代码我们看出这是一个C语言使用malloc函数分配了一块内存地址，但是在不使用的时候却忘记了释放其内存地址，这样就造成了内存泄漏，应该在其不使用的时候加上如下代码：
	
	free(dataOut);
	
另外，通过这个例子我们也要特别注意，在使用C语言对象的时候，一定要记得在不使用的时候给释放掉，ARC并不能释放掉这块内存。

例子2:

	Can't add self as subview crash 
	
造成这个崩溃的原因，**一种原因是在push或pop一个视图的时候，并且设置了animated:YES，如果此时动画(animated)还没有完成，这个时候，你在去push或pop另外一个视图的时候，就会造成该异常。** 也有其他原因可以造成这个崩溃，比如：
	
	[self.view addSubview:self.view];
	
复现这个现象，我写了一个下面的代码测试，如下：
	
	- (IBAction)btnAction:(id)sender {
    	UIViewController *test01 = [[UIViewController alloc] init];
    	[self.navigationController pushViewController:test01 animated:YES];
    	[self.navigationController pushViewController:test01 animated:YES];
	}

解决该异常最简单的方式是把animated设置为NO，但是很不友好，把系统自带的动画效果给去掉了。另外一种友好的方式就是通过runtime来进行实现了，通过安全的方式，确保当有控制器正在进行入栈或出栈时，没有其他入栈或出栈操作。**具体源码会在文章末尾提供。**

**SIGSEGV的崩溃记录有57条(总共304条崩溃记录)，占18.75%。在Crash界排名第二。**

###杀手 NO.3
####NSRangeException 异常 

造成这个异常，就是越界异常了，在iOS中我们经常碰到的越界异常有两种，一种是数组越界，一种字符串截取越界，我们通过crash日志来具体分析一下。

** crash 日志3-1 **

	-[__NSArrayM objectAtIndex:]: index 1 beyond bounds for empty array
	-[__NSCFConstantString substringToIndex:]: Index 10 out of bounds; string length 0
	
通过日志可以很明显的知道问题，就是越界造成的，复现该现象也比较简单，在此就略过了。怎么解决呢？

方案一：在对数组取数据的时候，要判断一下数组的长度大于取的index，这个要在平时写代码的时候给规范起来。同样在对字符串进行截取的时候，也需要做类似的判断。但现实的情况是，有时我们会忘了写这样的逻辑判断，就会有潜在的崩溃问题。如何做一下统一的判断呢？即使开发人员忘了写这样的逻辑判断也不会造成崩溃，从框架层面来杜绝这类的崩溃，方案二给出了答案。

方案二：利用runtime的Swizzle Method特性，可以实现从框架层面杜绝这类的崩溃问题，这样做的好处有两点：

1. **开发人员忘了写判断越界的逻辑，也不会造成app的崩溃，对开发人员来说是透明的。**
2. **不需要修改现有的代码，对现有代码的侵入性降低到最低，不需要添加大量重复的逻辑判断代码。**

**全部源码会在文章末尾提供**，现截取部分代码实现：
	
	@implementation NSArray (NSRangeException)

	+ (void)load{
    	static dispatch_once_t onceToken;
    	dispatch_once(&onceToken, ^{
        	@autoreleasepool {
            	[objc_getClass("__NSArray0") swizzleMethod:@selector(objectAtIndex:) swizzledSelector:@selector(emptyObjectIndex:)];
            	[objc_getClass("__NSArrayI") swizzleMethod:@selector(objectAtIndex:) swizzledSelector:@selector(arrObjectIndex:)];
            	[objc_getClass("__NSArrayM") swizzleMethod:@selector(objectAtIndex:) swizzledSelector:@selector(mutableObjectIndex:)];
            	[objc_getClass("__NSArrayM") swizzleMethod:@selector(insertObject:atIndex:) swizzledSelector:@selector(mutableInsertObject:atIndex:)];
        	}
    	});
	}

	- (id)emptyObjectIndex:(NSInteger)index{
    	return nil;
	}

	- (id)arrObjectIndex:(NSInteger)index{
    	if (index >= self.count || index < 0) {
        	return nil;
    	}
    	return [self arrObjectIndex:index];
	}

	- (id)mutableObjectIndex:(NSInteger)index{
    	if (index >= self.count || index < 0) {
        	return nil;
    	}
    	return [self mutableObjectIndex:index];
	}

	- (void)mutableInsertObject:(id)object atIndex:(NSUInteger)index{
    	if (object) {
        	[self mutableInsertObject:object atIndex:index];
    	}
	}

	@end
	
**越界的崩溃记录有46条（总共崩溃记录是304条），占15.13%，在crash界杀手排名第三。**

###杀手 NO.4
####SIGPIPE 异常

先解释一下什么是SIGPIPE异常，通俗一点的描述是这样的：对一个端已经关闭的socket调用两次write，第二次write将会产生SIGPIPE信号，该信号默认结束进程。

那如何解决该问题呢？对SIGPIPE信号可以进行捕获，也可将其忽略，对于iOS系统来说，只需要把下面这段代码放在.pch文件中即可。
	
	// 仅在 IOS 系统上支持 SO_NOSIGPIPE
	#if defined(SO_NOSIGPIPE) && !defined(MSG_NOSIGNAL)
    	// We do not want SIGPIPE if writing to socket.
    	const int value = 1;
    	setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &value, sizeof(int));
	#endif

**SIGPIPE的崩溃记录有11条(总共304条崩溃记录)，占3.61%。在Crash界排名第四。**

###杀手 NO.5
####SIGABRT 异常

**这是一个让程序终止的标识，会在断言、app内部、操作系统用终止方法抛出。通常发生在异步执行系统方法的时候。如CoreData、NSUserDefaults等，还有一些其他的系统多线程操作。**

> 注意：这并不一定意味着是系统代码存在bug，代码仅仅是成了无效状态，或者异常状态。

**SIGABRT崩溃记录9条(总共304条崩溃记录)，占2.96%。Crash界排名第五。**


###杀手总结
前面5大crash杀手，占了89.46%的崩溃率，解决了这5大crash杀手，基本上你的app就很健壮了，剩下的崩溃问题就需要具体问题具体分析了。

[源码下载地址](https://github.com/guoshimeihua/RuntimeDemo.git)

*参考文章：*
http://zhijianshusheng.github.io/2016/07/11/%E6%8C%89%E5%91%A8%E5%88%86%E7%B1%BB/20160711-0718/%E5%AF%BC%E8%87%B4iOS%E5%B4%A9%E6%BA%83%E7%9A%84%E6%9C%80%E5%B8%B8%E8%A7%815%E5%A4%A7%E5%85%83%E5%87%B6/
https://code.facebook.com/posts/583946315094347/automatic-memory-leak-detection-on-ios/
http://tech.glowing.com/cn/how-we-made-nsdictionary-nil-safe/
http://stackoverflow.com/questions/19560198/ios-app-error-cant-add-self-as-subview
https://my.oschina.net/moooofly/blog/474604
http://devma.cn/blog/2016/11/10/ios-beng-kui-crash-jie-xi/
