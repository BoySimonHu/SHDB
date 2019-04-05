//
//  DAAppDataBase.h
//  TechnicianApp
//
//  Created by zt on 2019/1/15.
//  Copyright © 2019 Captain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHDB.h"

@interface DAAppDataBase : NSObject

@property (nonatomic, strong) SHDataBase *dataBase;

SINGLETON_FOR_HEADER

- (void)createDB;

@end
