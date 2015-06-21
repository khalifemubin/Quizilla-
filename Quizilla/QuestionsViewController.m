//
//  QuestionsViewController.m
//  Quizilla
//
//  Created by Mubin Khalife on 18/05/15.
//  Copyright (c) 2015 Mubin Khalife. All rights reserved.
//

#import "QuestionsViewController.h"
#import "ReportCardViewController.h"

@interface QuestionsViewController ()

@end


@implementation QuestionsViewController

-(void) openDatabase
{
    BOOL fileFound;
    BOOL isDirectory;
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"quizilla.db"];
    fileFound = [fileMgr fileExistsAtPath:dbPath isDirectory:&isDirectory];
    
    
    if(!fileFound)
    {
        UIAlertView *noDbFileAlert = [[UIAlertView alloc] initWithTitle:@"No Database" message:@"Sorry but database file could not be located" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [noDbFileAlert show];
        
    }
    else
    {
        if(sqlite3_open([dbPath UTF8String], &db) != SQLITE_OK)
        {
            //NSLog(@"An error has occured while connecting to database: %s",sqlite3_errmsg(db));
            
            UIAlertView *noDbConnectionAlert = [[UIAlertView alloc] initWithTitle:@"No connection" message:@"Cannot connect to database" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [noDbConnectionAlert show];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[self navigationController] setNavigationBarHidden:NO];
    
    _lblResultIcon.backgroundColor = [UIColor clearColor];
    [_lblResultIcon setBackgroundColor:[UIColor clearColor]];
    _btnQuestion.backgroundColor = [UIColor clearColor];
    
    [_hiddenQuestionAnswered setHidden:YES];
    _hiddenQuestionAnswered.text = nil;
    
    UIBarButtonItem* backNavButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(backButtonClicked)];
   
    self.navigationItem.leftBarButtonItem = backNavButton;
    self.navigationItem.title = questionTypeText;

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_btnQuestion.frame];
    imageView.image = [UIImage imageNamed:@"notebook_page.png"];
    [self.view addSubview:imageView];
    [self.view bringSubviewToFront:_btnQuestion];
    _btnQuestion.userInteractionEnabled = NO;
    
    _btnNextQuestionIcon.backgroundColor = [UIColor clearColor];
    UIImageView *imgCorrect = [[UIImageView alloc] initWithFrame:_btnNextQuestionIcon.frame];
    imgCorrect.image = [UIImage imageNamed:@"next_icon.png"];
    [self.view addSubview:imgCorrect];
    [self.view bringSubviewToFront:_btnNextQuestionIcon];
    
    
    _tblAnswerOptions.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _option_list = [NSMutableArray array];
    
    iStartWithQuestion = 0;
    
    sqlite3_stmt *sqlQuizAttemptStmt = nil;
    sqlite3_stmt *sqlQuestionStmt = nil;
    sqlite3_stmt *sqlTruncateQuizAttemptStmt = nil;
    
    //Try and connect to database
    @try
    {
        [self openDatabase];
        
        //First check if previous attempts to quiz has been made
        
        const char *sqlQuizAttempts = [[NSString stringWithFormat:@"SELECT * FROM quiz_attempt WHERE question_type_id=%i",questionType] cStringUsingEncoding:NSASCIIStringEncoding];
        UIAlertView *errQuery = nil;
        
        
        //if(sqlite3_prepare(db, sqlQuizAttempts, -1, &sqlQuizAttemptStmt,NULL) != SQLITE_OK)
        if(sqlite3_prepare_v2(db, sqlQuizAttempts, -1, &sqlQuizAttemptStmt, NULL) != SQLITE_OK)
        {
            NSLog(@"Error in query: %s",sqlite3_errmsg(db));
            errQuery = [[UIAlertView alloc] initWithTitle:@"Invalid Operation" message:@"Error occured while processing.\n Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [errQuery show];
        }
        else
        {
            const char *strQuestion = nil;
            
            _question_list = [NSMutableArray array];
            
            if(_passedQuestionNumber<=0)
            {
                if (sqlite3_step(sqlQuizAttemptStmt)==SQLITE_ROW)
                {
                    NSString *strDeleteAttempts = [NSString stringWithFormat:@"DELETE from quiz_attempt WHERE question_type_id = %i",questionType];
                    
                    const char *deleteAttempts = [strDeleteAttempts UTF8String];
                    sqlite3_prepare_v2(db, deleteAttempts, -1, &sqlTruncateQuizAttemptStmt, NULL );
                    //sqlite3_bind_int(statement, 1, employee.employeeID);
                    if (sqlite3_step(sqlTruncateQuizAttemptStmt) == SQLITE_DONE)
                    {
                        //NSLog(@"Previous auiz attempts truncated successfully");
                    }
                    else
                    {
                        //NSLog(@"Previous quiz attempts could not be truncated.");
                    }
                    
                }
            }
            
            
            //Start from the beginning
            strQuestion = [[NSString stringWithFormat:@"SELECT * FROM questions WHERE question_type_id=%i ", questionType] cStringUsingEncoding:NSASCIIStringEncoding];
            if(sqlite3_prepare_v2(db, strQuestion, -1, &sqlQuestionStmt, NULL) != SQLITE_OK)
            {
                //NSLog(@"Error in query: %s",sqlite3_errmsg(db));
                errQuery = [[UIAlertView alloc] initWithTitle:@"Invalid Operation" message:@"Error occured while processing.\n Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [errQuery show];
            }
            else
            {
                NSString *question = nil;
                NSString *option1 = nil;
                NSString *option2 = nil;
                int correctOption = 0;
                
                
                
                while (sqlite3_step(sqlQuestionStmt)==SQLITE_ROW)
                {
                    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
                    
                    question = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(sqlQuestionStmt, 1)];
                    
                    option1 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(sqlQuestionStmt, 3)];
                    
                    option2 = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(sqlQuestionStmt, 4)];
                    
                    correctOption = sqlite3_column_int(sqlQuestionStmt, 5);
                    
                    [tempDictionary setObject:question forKey:@"question"];
                    [tempDictionary setObject:option1 forKey:@"option1"];
                    [tempDictionary setObject:option2 forKey:@"option2"];
                    [tempDictionary setObject:[NSNumber numberWithInt:correctOption] forKey:@"correctOption"];
                    
                    [_question_list addObject:tempDictionary];
                    
                }
                
                //NSLog(@"%@",_question_list[3]);
            }
            
            //function to call display questions
            iStartWithQuestion = _passedQuestionNumber;
            [self displayQuestionOptions:_passedQuestionNumber];
        }
        
    }
    @catch (NSException *exception)
    {
        // Print exception information
        /*NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );*/
        
        UIAlertView *errAlert = [[UIAlertView alloc] initWithTitle:@"Error Occured" message:@"Application error occured.\n Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errAlert show];
        
        [_btnQuestion setTitle:@"Application error occured.\n Please try again later" forState:UIControlStateNormal];
        
        return;
    }
    @finally {
        sqlite3_finalize(sqlQuizAttemptStmt);
        sqlite3_finalize(sqlQuestionStmt);
        sqlite3_finalize(sqlTruncateQuizAttemptStmt);

        
        if([_passedAnswerChosen length] > 0)
        {
            answerchosen = _passedAnswerChosen;
            
            [iconResult removeFromSuperview];
            iconResult = [[UIImageView alloc] initWithFrame:_lblResultIcon.frame];
            
            int answerOption = [[[_question_list objectAtIndex:iStartWithQuestion] valueForKey:@"correctOption"] intValue];
            
            int indexPathChosen = 0;
            
            if([_passedAnswerChosen isEqual:@"correct"])
            {
                iconResult.image = [UIImage imageNamed:@"correct_mark_icon.png"];
                indexPathChosen = (answerOption - 1);
            }
            else if([_passedAnswerChosen isEqual:@"wrong"])
            {
                iconResult.image = [UIImage imageNamed:@"wrong_mark_icon.png"];
                if (answerOption == 1)
                    indexPathChosen = 1;
                else
                    indexPathChosen = 0;
            }
            
            [self.view addSubview:iconResult];
            [self.view bringSubviewToFront:_lblResultIcon];
            
            //also highlight the answer chosen
            [_tblAnswerOptions reloadData];
            NSIndexPath *defaultIndexPath = [NSIndexPath indexPathForRow:indexPathChosen inSection:0];
            
            [_tblAnswerOptions selectRowAtIndexPath:defaultIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    sqlite3_close(db);
}


-(void)backButtonClicked
{
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"questionsTypeView"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) displayQuestionOptions:(int)questionNumber
{
    NSString *questionProgress = [NSString stringWithFormat:@"%i / %i",(questionNumber+1),(int)_question_list.count];
    
    _lblProgress.text = questionProgress;
    
    [iconResult removeFromSuperview];
    
    NSString *questionToDisplay = [[_question_list objectAtIndex:questionNumber] objectForKey:@"question"];

    [_btnQuestion setTitle:questionToDisplay forState:UIControlStateNormal];
    
    NSString *option1 = [[_question_list objectAtIndex:questionNumber] objectForKey:@"option1"];
    option1 = [NSString stringWithFormat:@"%@%@",@"A) ",option1];
    
    NSString *option2 = [[_question_list objectAtIndex:questionNumber] objectForKey:@"option2"];
    option2 = [NSString stringWithFormat:@"%@%@",@"B) ",option2];
    
    [_option_list addObjectsFromArray:[NSArray arrayWithObjects:option1,option2,nil]];
    
    [_tblAnswerOptions reloadData];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _option_list.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _tblAnswerOptions.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    NSString *dummyIdentifier = @"OptionCellItem";
    
    UITableViewCell *optioncell = [tableView dequeueReusableCellWithIdentifier:dummyIdentifier];
    
    if(optioncell== nil)
    {
        optioncell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dummyIdentifier];
        optioncell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        optioncell.textLabel.numberOfLines = 0;
    }
    
    /*
     //Top border for first cell
     if (indexPath.row == 0) {
        UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        topLineView.backgroundColor = [UIColor grayColor];
        [optioncell.contentView addSubview:topLineView];
    }
     
     //Bottom border for each cell
     UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, optioncell.bounds.size.height, self.view.bounds.size.width,1)];
     
     bottomLineView.backgroundColor = [UIColor grayColor];
     [optioncell.contentView addSubview:bottomLineView];
     */
    
    
    optioncell.textLabel.text = [_option_list objectAtIndex:indexPath.row];
    
    
    [optioncell.contentView.layer setBorderColor:[UIColor grayColor].CGColor];
    [optioncell.contentView.layer setBorderWidth:1.0f];
    
    optioncell.textLabel.font = [UIFont systemFontOfSize:12.0];
    
    return optioncell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

/*To remove extra blank rows in uitableviewcell*/
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int answerOption = [[[_question_list objectAtIndex:iStartWithQuestion] valueForKey:@"correctOption"] intValue];
    
    int optionSelected =(int)(indexPath.row)+1;
    
    _lblResultIcon.backgroundColor = [UIColor clearColor];
    
    [iconResult removeFromSuperview];
    
    iconResult = [[UIImageView alloc] initWithFrame:_lblResultIcon.frame];
    
    if(answerOption==optionSelected)
    {
        iconResult.image = [UIImage imageNamed:@"correct_mark_icon.png"];
    }
    else
    {
        iconResult.image = [UIImage imageNamed:@"wrong_mark_icon.png"];
    }
    
    [self.view addSubview:iconResult];
    [self.view bringSubviewToFront:_lblResultIcon];
    
    //Check if answer modified previously
    NSString *prevAnswered = _hiddenQuestionAnswered.text;
    
    if([prevAnswered length] == 0)
    {
        sqlite3_stmt *insertUpdateQuizAttempt = nil;
        sqlite3_stmt *sqlQuizAttemptStmt = nil;
        
        
        //Insert into the quiz_attempt table
        @try
        {
            const char *sqlQuizAttempts = [[NSString stringWithFormat:@"SELECT * FROM quiz_attempt WHERE question_type_id=%i",questionType] cStringUsingEncoding:NSASCIIStringEncoding];
            
            UIAlertView *errQuery;
            
            if(sqlite3_prepare_v2(db, sqlQuizAttempts, -1, &sqlQuizAttemptStmt, NULL) != SQLITE_OK)
            {
                //NSLog(@"Error in query: %s",sqlite3_errmsg(db));
                errQuery = [[UIAlertView alloc] initWithTitle:@"Invalid Operation" message:@"Error occured while processing.\n Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [errQuery show];
            }
            else
            {
                if (sqlite3_step(sqlQuizAttemptStmt)==SQLITE_ROW)
                {
                    //Update opration - update the correct count if answer is correct
                    _hiddenQuestionAnswered.text = @"answered";
                    
                    if(answerOption==optionSelected)
                    {
                        //update the count of correct answers if current question answered correctly
                        int totalCorrectAttepts = 0;
                        
                        int prevCorrectAttempts = sqlite3_column_int(sqlQuizAttemptStmt, 2);
                        
                        totalCorrectAttepts = prevCorrectAttempts+1;
                        
                        //Now update this count
                        NSString *updateQuizAttempt = [NSString stringWithFormat:@"UPDATE quiz_attempt set correct_attempts = %i WHERE question_type_id = ?",totalCorrectAttepts];
                        
                        const char *update_stmt = [updateQuizAttempt UTF8String];
                        sqlite3_prepare_v2(db, update_stmt, -1, &insertUpdateQuizAttempt, NULL );
                        sqlite3_bind_int(insertUpdateQuizAttempt, 1, questionType);
                        
                        sqlite3_step(insertUpdateQuizAttempt);
                        
                        answerchosen = @"correct";
                    }
                    else
                    {
                        answerchosen = @"wrong";
                    }
                    
                }
                else
                {
                    //Insert operation - insert new record (with correct count value if answered this question correctly)
                    _hiddenQuestionAnswered.text = @"answered";
                    
                    int correctAttemptsInsert = 0;
                    
                    if(answerOption==optionSelected)
                    {
                        correctAttemptsInsert = 1;
                        answerchosen = @"correct";
                    }
                    else
                    {
                        answerchosen = @"wrong";
                    }
                    
                    NSString *insertQuizAttempt = [NSString stringWithFormat:
                                                   @"INSERT INTO quiz_attempt (question_type_id, correct_attempts) VALUES (%i, %i)",
                                                   questionType,correctAttemptsInsert];
                    
                    const char *strSqlInsertQuizAttempt = [insertQuizAttempt UTF8String];
                    if(sqlite3_prepare_v2(db, strSqlInsertQuizAttempt, -1, &insertUpdateQuizAttempt, NULL) == SQLITE_OK)
                    {
                        sqlite3_step(insertUpdateQuizAttempt);
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
            sqlite3_finalize(insertUpdateQuizAttempt);
            sqlite3_finalize(sqlQuizAttemptStmt);
        }
        
    }
    else
    {
        //Don't do anything
    }
    
    
}


-(void) setQuestionType:(int)questionTypePassed
{
    questionType = questionTypePassed;
}

-(void) setQuestionTypeText:(NSString*) questionTypeTextPassed
{
    questionTypeText = questionTypeTextPassed;
}

-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    BOOL bProceedWithNavigation = NO;
    
    if([identifier isEqualToString:@"showReportCard"])
    {
        int iTotalQuestions = (int)_question_list.count;
        
        [_option_list removeAllObjects];
        iStartWithQuestion++;
        
        _hiddenQuestionAnswered.text = nil;
        
        _passedAnswerChosen = nil;
        
        answerchosen = nil;
        
        if(iTotalQuestions>iStartWithQuestion)
        {
            [self displayQuestionOptions:iStartWithQuestion];
            bProceedWithNavigation = NO;
        }
        else
        {
            bProceedWithNavigation = YES;
        }
    }
    
    return bProceedWithNavigation;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showReportCard"])
    {
        ReportCardViewController *vc = [segue destinationViewController];
        [vc setQuestionType:questionType];
        [vc setTotalQuestions:(int)_question_list.count];
    }
}

-(void) backToGenre:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft;
}


-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        LandscapeQuestionsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"landscapeView"];
        [controller setQuestionType:questionType];
        [controller setQuestionTypeText:questionTypeText];
        controller.passedQuestionNumber = iStartWithQuestion;
        controller.passedAnswerChosen = answerchosen;
        [self.navigationController pushViewController:controller animated:YES];
        
        controller.hiddenQuestionAnswered.text = _hiddenQuestionAnswered.text ;
        
    } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        LandscapeQuestionsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"landscapeView"];
        [controller setQuestionType:questionType];
        [controller setQuestionTypeText:questionTypeText];
        controller.passedQuestionNumber = iStartWithQuestion;
        controller.passedAnswerChosen = answerchosen;
        [self.navigationController pushViewController:controller animated:YES];
        controller.hiddenQuestionAnswered.text=_hiddenQuestionAnswered.text;
    } else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
    } else if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
    }
}

@end
