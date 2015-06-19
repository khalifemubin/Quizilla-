//
//  QuestionTypeManager.m
//  Quizilla
//
//  Created by Mubin Khalife on 28/05/15.
//  Copyright (c) 2015 Mubin Khalife. All rights reserved.
//

#import "QuestionTypeManager.h"

@implementation QuestionTypeManager

-(int)getQuestionTypeId:(NSString *)questionType
{
    int returnQuestionTypeId = 0;
    
    sqlite3_stmt *stmtFetchQuestionType = nil;
    
    @try
    {
        BOOL fileFound;
        BOOL isDirectory;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"quizilla.db"];
        fileFound = [fileMgr fileExistsAtPath:dbPath isDirectory:&isDirectory];
        
        if(!fileFound)
        {
            //NSLog(@"Cannot locate database file '%@' ",dbPath);
            returnQuestionTypeId = 0;
        }
        else
        {
            if(sqlite3_open([dbPath UTF8String], &dbHandle) != SQLITE_OK)
            {
                //NSLog(@"An error has occured while connecting to database: %s",sqlite3_errmsg(dbHandle));
                returnQuestionTypeId = 0;
            }
            else
            {
                const char *sqlQuestionType = [[NSString stringWithFormat:@"SELECT * FROM questions_type WHERE lower(question_type) = lower('%@')",questionType] cStringUsingEncoding:NSASCIIStringEncoding];
                
                
                if(sqlite3_prepare_v2(dbHandle, sqlQuestionType, -1, &stmtFetchQuestionType, nil) != SQLITE_OK)
                {
                    //NSLog(@"Error in query: %s",sqlite3_errmsg(dbHandle));
                    returnQuestionTypeId = 0;
                }
                else
                {
                    if(sqlite3_step(stmtFetchQuestionType)==SQLITE_ROW)
                    {
                        returnQuestionTypeId = sqlite3_column_int(stmtFetchQuestionType, 0);
                        //NSLog(@"Return type id obtained is %i ",returnQuestionTypeId);
                    }
                    else
                    {
                        returnQuestionTypeId = 0;
                    }
                }

            }
        }

    }
    @catch (NSException *exception)
    {
        // Print exception information
        /*NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );*/
        returnQuestionTypeId = 0;
    }
    @finally {
        sqlite3_finalize(stmtFetchQuestionType);
        sqlite3_close(dbHandle);
    }

    return returnQuestionTypeId;
}

-(NSString *) getQuestionType:(int)questionTypeId
{
    NSString *returnQuestionType;
    
    sqlite3_stmt *stmtFetchQuestionType = nil;
    
    @try
    {
        BOOL fileFound;
        BOOL isDirectory;
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"quizilla.db"];
        fileFound = [fileMgr fileExistsAtPath:dbPath isDirectory:&isDirectory];
        
        if(!fileFound)
        {
            //NSLog(@"Cannot locate database file '%@' ",dbPath);
            returnQuestionType = nil;
        }
        else
        {
            if(sqlite3_open([dbPath UTF8String], &dbHandle) != SQLITE_OK)
            {
                //NSLog(@"An error has occured while connecting to database: %s",sqlite3_errmsg(dbHandle));
                returnQuestionType=nil;
            }
            else
            {
                const char *sqlQuestionType = [[NSString stringWithFormat:@"SELECT * FROM questions_type WHERE qtype_id = %i",questionTypeId] cStringUsingEncoding:NSASCIIStringEncoding];
                
                if(sqlite3_prepare_v2(dbHandle, sqlQuestionType, -1, &stmtFetchQuestionType, nil) != SQLITE_OK)
                {
                    //NSLog(@"Error in query: %s",sqlite3_errmsg(dbHandle));
                    returnQuestionType = nil;
                }
                else
                {
                    if(sqlite3_step(stmtFetchQuestionType)==SQLITE_ROW)
                    {
                        
                        returnQuestionType = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(stmtFetchQuestionType, 1)];
                    }
                    else
                    {
                        returnQuestionType = nil;
                    }
                }
                
            }
        }
        
    }
    @catch (NSException *exception)
    {
        // Print exception information
        /*NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );*/
        returnQuestionType = nil;
    }
    @finally {
        sqlite3_finalize(stmtFetchQuestionType);
        sqlite3_close(dbHandle);
    }
    
    return returnQuestionType;
}

@end
