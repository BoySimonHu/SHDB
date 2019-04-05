//
//  DAAppDataBase.m
//  TechnicianApp
//
//  Created by zt on 2019/1/15.
//  Copyright © 2019 Captain. All rights reserved.
//

#import "DAAppDataBase.h"

#import "DAStatisticsModel.h"

@implementation DAAppDataBase

SINGLETON_FOR_CLASS

- (void)createDB {
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"userNumber"];
    if(token.length == 0){
        return;
    }
    
    NSString *path = [[NSString alloc] initWithString:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_data.db", token]]];
    NSLog(@"%@", path);
    _dataBase = [SHDataBase dataBase:_dataBase anPath:path];
    
    [self configTable];
}

- (void)deleteTable {
    
}

- (void)configTable {
    
    [[DAStatisticsModel alloc] createTableInDB:self.dataBase];
    [[DAStatisticsModel alloc] updateTableAddColumn];
}

@end
