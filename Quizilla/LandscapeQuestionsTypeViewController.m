//
//  LandscapeQuestionsTypeViewController.m
//  Quizilla
//
//  Created by Mubin Khalife on 03/06/15.
//  Copyright (c) 2015 Mubin Khalife. All rights reserved.
//

#import "LandscapeQuestionsTypeViewController.h"

@interface LandscapeQuestionsTypeViewController ()

@end

@implementation LandscapeQuestionsTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[self navigationController] setNavigationBarHidden:YES];
}

-(void) viewWillAppear: (BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [[self navigationController] setNavigationBarHidden:YES];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    int questionType;
    QuestionTypeManager *objQuestionType = [[QuestionTypeManager alloc] init];
    
    if([[segue.identifier lowercaseString] isEqualToString:@"programming"])
    {
        questionType = [objQuestionType getQuestionTypeId:@"programming"];
    }
    else if([[segue.identifier lowercaseString] isEqualToString:@"general knowledge"])
    {
        questionType = [objQuestionType getQuestionTypeId:@"General Knowledge"];
    }
    else if([[segue.identifier lowercaseString] isEqualToString:@"sports"])
    {
        questionType = [objQuestionType getQuestionTypeId:@"Sports"];
    }
    
    [segue.destinationViewController setQuestionType:questionType];
    [segue.destinationViewController setQuestionTypeText:[segue.identifier capitalizedString]];
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(toInterfaceOrientation==UIInterfaceOrientationPortrait)
    {
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"questionsTypeView"];
        [self.navigationController pushViewController:controller animated:YES];
    }
}


@end
