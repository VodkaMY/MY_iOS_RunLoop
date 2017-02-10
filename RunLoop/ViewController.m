//
//  ViewController.m
//  RunLoop
//
//  Created by MY on 2017/2/10.
//  Copyright © 2017年 com.gzkiwi.yinpubaoblue. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(nonatomic,strong)dispatch_source_t timer;

@property(nonatomic,strong)NSThread * thread;
@end

@implementation ViewController
//创建线程
- (IBAction)createBtnClick:(UIButton *)sender {
    NSLog(@"创建线程");
    _thread = [[NSThread alloc]initWithTarget:self selector:@selector(task1) object:nil];
    [_thread start];
}
//让线程继续执行任务
- (IBAction)otherBtnClick:(id)sender {
    [self performSelector:@selector(task2) onThread:_thread withObject:nil waitUntilDone:YES];
}
-(void)task1
{
    NSRunLoop * runloop = [NSRunLoop currentRunLoop];
    NSLog(@"%@---",[NSThread currentThread]);
    //为了保证定时器不退出
    //方法一:
//    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:YES];
    //方法二:
    
    
    [runloop addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
//    [runloop run];
    [runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}
-(void)task2
{
    NSLog(@"%@---",[NSThread currentThread]);
}
-(void)run
{
    NSLog(@"%@",[NSThread currentThread]);
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self dispatchSource];
//    [NSThread detachNewThreadSelector:@selector(timer2) toTarget:self withObject:nil];
    
}

-(void)observer
{
    //1.创建监听者
    /*
     第一个参数:怎么分配存储空间
     第二个参数:要监听的状态 kCFRunLoopAllActivities 所有的状态
     第三个参数:时候持续监听
     第四个参数:优先级 总是传0
     第五个参数:当状态改变时候的回调
     */
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        
        /*
         kCFRunLoopEntry = (1UL << 0),        即将进入runloop
         kCFRunLoopBeforeTimers = (1UL << 1), 即将处理timer事件
         kCFRunLoopBeforeSources = (1UL << 2),即将处理source事件
         kCFRunLoopBeforeWaiting = (1UL << 5),即将进入睡眠
         kCFRunLoopAfterWaiting = (1UL << 6), 被唤醒
         kCFRunLoopExit = (1UL << 7),         runloop退出
         kCFRunLoopAllActivities = 0x0FFFFFFFU
         */
        switch (activity) {
            case kCFRunLoopEntry:
                NSLog(@"即将进入runloop");
                break;
            case kCFRunLoopBeforeTimers:
                NSLog(@"即将处理timer事件");
                break;
            case kCFRunLoopBeforeSources:
                NSLog(@"即将处理source事件");
                break;
            case kCFRunLoopBeforeWaiting:
                NSLog(@"即将进入睡眠");
                break;
            case kCFRunLoopAfterWaiting:
                NSLog(@"被唤醒");
                break;
            case kCFRunLoopExit:
                NSLog(@"runloop退出");
                break;
                
            default:
                break;
        }
    });
    
    /*
     第一个参数:要监听哪个runloop
     第二个参数:观察者
     第三个参数:运行模式
     */
    CFRunLoopAddObserver(CFRunLoopGetCurrent(),observer, kCFRunLoopDefaultMode);
    
    //NSDefaultRunLoopMode == kCFRunLoopDefaultMode
    //NSRunLoopCommonModes == kCFRunLoopCommonModes
}

//在runloop中有多个运行模式, 但是runloop只能选择一种模式运行
//runLoopMode类型
/*
 kCFRunLoopDefaultMode
 UITrackingRunLoopMode 界面追踪
 NSDefaultRunLoopMode
 NSRunLoopCommonModes 占位运行模式
 
 */
//GCD中的计时器
-(void)dispatchSource
{
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        NSLog(@"%@----",[[NSRunLoop currentRunLoop] currentMode]);
    });
    dispatch_resume(_timer);
}
-(void)timer1
{
    //创建定时器
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(runNext) userInfo:nil repeats:YES];
    
    //添加定时器到RunLoop中, 指定runloop运行模式为默认模式kCFRunLoopDefaultMode
    //    [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
    //    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
//在子线程中timer不会工作, 创建当前线程的runLoop
//[NSRunLoop currentRunLoop];
-(void)timer2
{
    NSRunLoop * currentRunloop = [NSRunLoop currentRunLoop];
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(runNext) userInfo:nil repeats:YES];
    [currentRunloop run];
}
-(void)runNext
{
    NSLog(@"%@",[[NSRunLoop currentRunLoop] currentMode]);
}


//在RunLoop中有多个运行模式, 但是RunLoop只能选择一种模式运行
/*
 a.CFRunloopRef
 b.CFRunloopModeRef【Runloop的运行模式】
 c.CFRunloopSourceRef【Runloop要处理的事件源】
 d.CFRunloopTimerRef【Timer事件】
 e.CFRunloopObserverRef【Runloop的观察者（监听者）】
 */



//获取线程
-(void)runLoopThread
{
    //1. 获取主线程相对应的RunLoop
    NSRunLoop * mainRunLoop = [NSRunLoop mainRunLoop];
    
    //2. 获得当前线程对应的对象
    NSRunLoop * currentRunLoop = [NSRunLoop currentRunLoop];
    
    NSLog(@"%p %p",mainRunLoop,currentRunLoop);
    CFRunLoopGetMain();         //获取当前主线程RunLoop对象
    CFRunLoopGetCurrent();      //获取当前RunLoop对象
    
    //RunLoop和线程之间的关系
    //一一对应,主线程的runLoop已经创建, 但子线程的需要手动创建
    [[[NSThread alloc]initWithTarget:self selector:@selector(run) object:nil] start];
}
-(void)run1
{
    //如何创建子线程对应的runLoop,currentRunLoop懒加载的,
    NSLog(@"currnetRunLoop-----%@",[NSRunLoop currentRunLoop]);
    NSLog(@"run------%@",[NSThread currentThread]);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
