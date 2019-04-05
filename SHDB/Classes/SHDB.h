//
//  SHDB.h
//  DBDemo
//
//  Created by Simon Mr on 2017/12/7.
//  Copyright © 2017年 Simon Mr. All rights reserved.
//

#define SH_SQLITE_INTEGER @"INTEGER"
#define SH_SQLITE_REAL @"REAL"
#define SH_SQLITE_TEXT @"TEXT"
#define SH_SQLITE_BLOB @"BLOB"
#define SH_SQLITE_NULL @"NULL"

#define SH_SQLITE_MODEL @"Model"
#define SH_SQLITE_ID @"ID"
#define SH_SQLITE_IDKEY @"idKey"
#define SH_SQLITE_DESCRIPTION @"description"
#define SH_SQLITE_DEBUGDESCRIPTION @"debugDescription"

#import "SHDataBase.h"
#import "SHModel.h"

#pragma mark - SingletonMacro

#define SINGLETON_FOR_HEADER \
\
+ (instancetype)getInstance;


#define SINGLETON_FOR_CLASS \
\
+ (instancetype)getInstance { \
static id instance = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
instance = [[self alloc] init]; \
}); \
return instance; \
}
