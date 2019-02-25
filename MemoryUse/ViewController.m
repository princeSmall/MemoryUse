//
//  ViewController.m
//  MemoryUse
//
//  Created by le tong on 2019/2/25.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "ViewController.h"
#import <mach/mach.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    for (int i = 0; i < 100000;  i++) {
        UIView *view = [[UIView alloc]init];
        [self.view addSubview:view];
    }
    NSLog(@"%lld",[self memoryUsage]);
    NSLog(@"%lld",[self memoryUse]);
    // Do any additional setup after loading the view, typically from a nib.
}

/**
 当我们想去获取 iOS 应用的占用内存时，通常我们能找到的方法是这样的，用 resident_size：
 但是测试的时候，我们会发现这个跟我们在 Instruments 里面看到的内存大小不一样，有时候甚至差别很大

 @return memorySize
 */
- (int64_t)memoryUsage {
    int64_t memoryUsageInByte = 0;
    struct task_basic_info taskBasicInfo;
    mach_msg_type_number_t size = sizeof(taskBasicInfo);
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t) &taskBasicInfo, &size);
    
    if(kernelReturn == KERN_SUCCESS) {
        memoryUsageInByte = (int64_t) taskBasicInfo.resident_size;
        NSLog(@"Memory in use (in bytes): %lld", memoryUsageInByte);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kernelReturn));
    }
    
    return memoryUsageInByte;
}

/**
 更加准确的方式应该是用 phys_footprint：

 @return memorySize
 */
- (int64_t)memoryUse {
    int64_t memoryUsageInByte = 0;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn == KERN_SUCCESS) {
        memoryUsageInByte = (int64_t) vmInfo.phys_footprint;
        NSLog(@"Memory in use (in bytes): %lld", memoryUsageInByte);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kernelReturn));
    }
    return memoryUsageInByte;
}

@end
