//
//  QuestionTypeManager.h
//  Quizilla
//
//  Created by Mubin Khalife on 28/05/15.
//  Copyright (c) 2015 Mubin Khalife. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface QuestionTypeManager : NSObject
{
    sqlite3 *dbHandle;
}

-(int)getQuestionTypeId:(NSString *)questionType;
-(NSString *) getQuestionType:(int)questionTypeId;

@end
