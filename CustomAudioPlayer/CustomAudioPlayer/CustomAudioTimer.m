//
//  CustomAudioTimer.m
//  CustomAudioPlayer
//
//  Created by Singularity on 2020/12/25.
//

#import "CustomAudioTimer.h"

@implementation CustomAudioTimer

+ (dispatch_source_t)timeCountStartWithInterval:(float)interval handler:(dispatch_block_t)event_handle{
    /**
     *   GCD 计时器应用
     *   dispatch Queue :决定了将来回调的方法在哪里执行。
     *   dispatch_source_t timer  是一个OC对象
     *   DISPATCH_TIME_NOW  第二个参数：定时器开始时间,也可以使用如下的方法，在Now 的时间基础上再延时多长时间执行以下任务。

     dispatch_time(dispatch_time_t when, int64_t delta)
     
     *   intervalInSeconds  第三个参数:定时器开始后的间隔时间（纳秒 NSEC_PER_SEC）
     *  leewayInSeconds 第四个参数：间隔精准度，0代标最精准，传入一个大于0的数，代表多少秒的范围是可以接收的,主要为了提高程序性能，积攒一定的时间，Runloop执行完任务会睡觉，这个方法让他多睡一会，积攒时间，任务也就相应多了一点，而后一起执行
     */
    
    if (interval <= 0) {
        interval = 1.0;
    }

    /** 获取一个全局的线程来运行计时器*/
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    /** 创建一个计时器  （ DISPATCH_SOURCE_TYPE_TIMER）*/
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

    /** 设置定时器的各种属性（何时开始，间隔多久执行）  GCD 的时间参数一般为纳秒 （1 秒 = 10 的 9 次方 纳秒）*/
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, interval * NSEC_PER_SEC, 0);

    // 任务回调
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (event_handle) {
                event_handle();
            }
        });
        
    });

    // 开始定时器任务（定时器默认开始是暂停的，需要复位开启）
    dispatch_resume(timer);
    
    return timer;
}

+ (void)resumeTimer:(dispatch_source_t)timer{
    if (!timer) {
        return;
    }
    dispatch_resume(timer);
}

+ (void)suspendTimer:(dispatch_source_t)timer{
    if (!timer) {
        return;
    }
    //挂起的时候注意，多次暂停的操作会导致线程锁的现象，即多少次暂停，,dispatch_resume和dispatch_suspend调用次数需要平衡，如果重复调用dispatch_resume则会崩溃,因为重复调用会让dispatch_resume代码里if分支不成立，从而执行了DISPATCH_CLIENT_CRASH("Over-resume of an object")导致崩溃
    dispatch_suspend(timer);
}

+ (void)cancelTimer:(dispatch_source_t)timer{
    if (!timer) {
        return;
    }
    //默认是重复执行的，可以在事件响应回调中通过dispatch_source_cancel方法来设置为只执行一次
    dispatch_source_set_event_handler(timer, ^{
        
        dispatch_source_cancel(timer);
    });
}

@end
