//
//  LandscapeReportCardViewController.m
//  Quizilla
//
//  Created by Mubin Khalife on 04/06/15.
//  Copyright (c) 2015 Mubin Khalife. All rights reserved.
//

#import "LandscapeReportCardViewController.h"

@interface LandscapeReportCardViewController ()

@end

@implementation LandscapeReportCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[self navigationController] setNavigationBarHidden:YES];
    
    NSString *quizGenre = nil;
    sqlite3_stmt *sqlResultStmt = nil;
    sqlite3_stmt *sqlTruncateQuizAttemptStmt = nil;
    
    QuestionTypeManager *objQuestionType = [[QuestionTypeManager alloc] init];
    
    quizGenre = [objQuestionType getQuestionType:_questionType];
    
    
    _lblResultQuizGenre.text = [NSString  stringWithFormat:@"Report Card - %@",quizGenre];
    _lblTotalQuestions.text = [NSString stringWithFormat:@"Total Questions : %i",_totalQuestions];
    
    @try
    {
        BOOL fileFound;
        BOOL isDirectory;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"quizilla.db"];
        fileFound = [fileMgr fileExistsAtPath:dbPath isDirectory:&isDirectory];
        
        if(!fileFound)
        {
            UIAlertView *noDbFileAlert = [[UIAlertView alloc] initWithTitle:@"Application Error" message:@"Sorry but report could not be generated" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [noDbFileAlert show];
            
        }
        else
        {
            if(sqlite3_open([dbPath UTF8String], &dbHandle) != SQLITE_OK)
            {
                //NSLog(@"An error has occured while connecting to database: %s",sqlite3_errmsg(dbHandle));
                
                UIAlertView *noDbConnectionAlert = [[UIAlertView alloc] initWithTitle:@"No connection" message:@"Cannot connect to database" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                [noDbConnectionAlert show];
            }
            else
            {
                const char *sqlQuizResult = [[NSString stringWithFormat:@"SELECT * FROM quiz_attempt WHERE question_type_id = %i ORDER BY attempt_id DESC LIMIT 1",_questionType] cStringUsingEncoding:NSASCIIStringEncoding];
                
                UIAlertView *errQuery = nil;
                
                if(sqlite3_prepare_v2(dbHandle, sqlQuizResult, -1, &sqlResultStmt, nil) != SQLITE_OK)
                {
                    //NSLog(@"Error in query: %s",sqlite3_errmsg(dbHandle));
                    errQuery = [[UIAlertView alloc] initWithTitle:@"Invalid Operation" message:@"Error occured while processing.\n Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [errQuery show];
                }
                else
                {
                    int totalcorrectAnswers;
                    
                    //Fetch the result
                    if(sqlite3_step(sqlResultStmt)==SQLITE_ROW)
                    {
                        totalcorrectAnswers = sqlite3_column_int(sqlResultStmt, 2);
                    }
                    else
                    {
                        totalcorrectAnswers  = 0;
                    }
                    
                    _lblTotalCorrect.text = [NSString stringWithFormat:@"Total Correct Answers : %i",totalcorrectAnswers];
                    
                    double dScorePercent;
                    
                    if(totalcorrectAnswers>0)
                    {
                        dScorePercent = ((double)totalcorrectAnswers/(double) _totalQuestions)*100;
                        _lblScore.text = [NSString stringWithFormat:@"Score : %.2f %@",dScorePercent,@"%"];
                    }
                    else
                    {
                        _lblScore.text = @"Score : 0%";
                        dScorePercent = 0;
                    }
                    
                    
                    if(dScorePercent < 40)
                    {
                        _lblScore.backgroundColor = [UIColor redColor];
                    }
                    else if (dScorePercent > 40 && dScorePercent < 70)
                    {
                        _lblScore.backgroundColor = [UIColor yellowColor];
                    }
                    else
                    {
                        _lblScore.backgroundColor = [UIColor greenColor];
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
        return;
    }
    @finally {
        sqlite3_finalize(sqlResultStmt);
        sqlite3_finalize(sqlTruncateQuizAttemptStmt);
        sqlite3_close(dbHandle);
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) setQuestionType:(int)questionTypePassed
{
    _questionType = questionTypePassed;
}

-(void)setTotalQuestions:(int)totalQuestionPassed
{
    _totalQuestions = totalQuestionPassed;
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(toInterfaceOrientation==UIInterfaceOrientationPortrait)
    {
        ReportCardViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportCardView"];
        controller.questionType = _questionType;
        controller.totalQuestions = _totalQuestions;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}


@end
