//
//  ViewController.m
//  ESCGCDDemo
//
//  Created by xiang on 2019/3/18.
//  Copyright © 2019 xiang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

//串行队列
@property(nonatomic,strong)dispatch_queue_t serial_queue;

//并行队列
@property(nonatomic,strong)dispatch_queue_t concurrent_queue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.serial_queue = dispatch_queue_create("串行队列", DISPATCH_QUEUE_SERIAL);
    
    self.concurrent_queue = dispatch_queue_create("并行队列", DISPATCH_QUEUE_CONCURRENT);
    
    [self sync_serial_queue];
    
//    [self async_serial_queue];
    
//    [self sync_concurrent_queue];
    
//    [self async_concurrent_queue];
    
//    [self async_concurrent_barier_queue];
    
//    [self dispatch_after];
    
//    [self dispatch_once];
    
//    [self dispatch_apply];
    
//    [self dispatch_group_1];
    
//    [self dispatch_group_2];
    
//    [self dispatch_group_3];
    
//    [self dispatch_semaphore];
}

/**
 同步串行队列，任务按顺序在当前线程执行
 */
- (void)sync_serial_queue {
    for (int i = 0; i < 20; i++) {
        dispatch_sync(self.serial_queue, ^{
            NSLog(@"%d===%@",i,[NSThread currentThread]);
        });
    }
}

/**
 同步串行对象，任务按顺序在其他线程执行
 */
- (void)async_serial_queue {
    for (int i = 0; i < 20; i++) {
        dispatch_async(self.serial_queue, ^{
            NSLog(@"%d===%@",i,[NSThread currentThread]);
        });
    }
}

/**
 同步并行队列，任务按顺序在当前线程执行
 */
- (void)sync_concurrent_queue {
    for (int i = 0; i < 20; i++) {
        dispatch_sync(self.concurrent_queue, ^{
            NSLog(@"%d===%@",i,[NSThread currentThread]);
        });
    }
}

/**
 异步并行队列，任务不按顺序在其他线程执行
 */
- (void)async_concurrent_queue {
    for (int i = 0; i < 20; i++) {
        dispatch_async(self.concurrent_queue, ^{
            NSLog(@"%d===%@",i,[NSThread currentThread]);
        });
    }
}

/**
 异步并行队列，barrier同步，使barrier前面的任务全部执行完毕，才会执行barrier后面的任务
 */
- (void)async_concurrent_barier_queue {
    for (int i = 0; i < 200; i++) {
        dispatch_async(self.concurrent_queue, ^{
            NSLog(@"%d===%@",i,[NSThread currentThread]);
        });
        if (i == 100) {
            dispatch_barrier_sync(self.concurrent_queue, ^{
                NSLog(@"dispatch_barrier_sync===%d===%@",i,[NSThread currentThread]);
            });
        }
    }
}

/**
 延迟指定时间执行任务
 */
- (void)dispatch_after {
    NSLog(@"%@",[NSDate date]);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"after == %@",[NSDate date]);
    });
}

/**
 在程序运行过程中只执行一次，用于创建单例，线程安全
 */
- (void)dispatch_once {
    for (int i = 0; i < 10; i++) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSLog(@"%d",i);
        });
    }
}

/**
 快速多线程迭代
 */
- (void)dispatch_apply {
    dispatch_apply(10, self.concurrent_queue, ^(size_t index) {
        NSLog(@"dispatch_apply==%zud===%@",index,[NSThread currentThread]);
    });
}

/**
 dispatch group 第一种多线程异步执行后同步到指定线程写法
 */
- (void)dispatch_group_1 {
    dispatch_group_t group_t = dispatch_group_create();
    
    for (int i = 0; i < 10; i++) {
        dispatch_group_async(group_t, self.concurrent_queue, ^{
            NSLog(@"dispatch_group_1===%d===%@",i,[NSThread currentThread]);
        });
    }
    
    dispatch_group_notify(group_t, dispatch_get_main_queue(), ^{
        NSLog(@"转主线程");
    });
}

/**
 dispatch group 第二种多线程异步执行后同步到指定线程写法
 */
- (void)dispatch_group_2 {
    dispatch_group_t groutp_t = dispatch_group_create();
    
    for (int i = 0; i < 10; i++) {
        dispatch_group_enter(groutp_t);
        dispatch_async(self.concurrent_queue, ^{
            NSLog(@"dispatch_group_2===%d===%@",i,[NSThread currentThread]);
            dispatch_group_leave(groutp_t);
        });
    }
    dispatch_group_notify(groutp_t, dispatch_get_main_queue(), ^{
        NSLog(@"转主线程");
    });
}

/**
 dispatch group wait阻塞线程用法
 */
- (void)dispatch_group_3 {
    dispatch_group_t groutp_t = dispatch_group_create();
    
    for (int i = 0; i < 10; i++) {
        dispatch_group_enter(groutp_t);
        dispatch_async(self.concurrent_queue, ^{
            NSLog(@"dispatch_group_3===%d===%@",i,[NSThread currentThread]);
            dispatch_group_leave(groutp_t);
        });
    }
    dispatch_group_wait(groutp_t, DISPATCH_TIME_FOREVER);
    NSLog(@"group end");
}

/**
 dispatch semaphore同步线程，如果为1则可做线程锁使用
 */
- (void)dispatch_semaphore {
    dispatch_semaphore_t semaphore_t = dispatch_semaphore_create(3);
    for (int i = 0; i < 10; i++) {
        dispatch_semaphore_wait(semaphore_t, DISPATCH_TIME_FOREVER);
        dispatch_async(self.concurrent_queue, ^{
            int t = rand() % 5;
            sleep(t);
            NSLog(@"dispatch_semaphore===%d===%@===%d",i,[NSThread currentThread],t);
            dispatch_semaphore_signal(semaphore_t);
        });
    }
    NSLog(@"end");
}

@end
