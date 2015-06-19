//
//  ReportCardViewController.h
//  Quizilla
//
//  Created by Mubin Khalife on 26/05/15.
//  Copyright (c) 2015 Mubin Khalife. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "QuestionTypeManager.h"
#import "LandScapeReportCardViewController.h"

@interface ReportCardViewController : UIViewController
{
    sqlite3 *dbHandle;
}

-(void) setQuestionType:(int)questionTypePassed;

-(void) setTotalQuestions:(int)totalQuestionPassed;

@property (assign,nonatomic) int questionType;

@property (assign,nonatomic) int totalQuestions;

@property (strong, nonatomic) IBOutlet UILabel *lblResultQuizGenre;

@property (strong, nonatomic) IBOutlet UILabel *lblTotalQuestions;

@property (strong, nonatomic) IBOutlet UILabel *lblTotalCorrect;

@property (strong, nonatomic) IBOutlet UILabel *lblScore;

@end
