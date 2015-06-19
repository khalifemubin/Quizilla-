//
//  LandscapeQuestionsViewController.h
//  Quizilla
//
//  Created by Mubin Khalife on 02/06/15.
//  Copyright (c) 2015 Mubin Khalife. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "QuestionTypesViewController.h"
#import "QuestionsViewController.h"

@interface LandscapeQuestionsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    sqlite3 *db;
    int iStartWithQuestion;
    int questionType;
    UIImageView *iconResult;
    NSString *answerchosen;
}



-(void)setQuestionType:(int)questionTypePassed;
@property(assign,nonatomic) int passedQuestionNumber;
@property(assign,nonatomic) NSString *passedAnswerChosen;


@property (strong,nonatomic) NSMutableArray *question_list;

@property (strong,nonatomic) NSMutableArray *option_list;

@property (strong, nonatomic) IBOutlet UIButton *btnQuestion;

@property (strong, nonatomic) IBOutlet UITableView *tblAnswerOptions;

@property (strong, nonatomic) IBOutlet UILabel *lblResultIcon;

@property (strong, nonatomic) IBOutlet UIButton *btnNextQuestionIcon;

@property (strong, nonatomic) IBOutlet UITextField *hiddenQuestionAnswered;



@end
