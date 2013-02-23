//
//  EditorScreen.h
//  iPhoneCustomFileFormat
//
//  Created by Marin Todorov on 4/7/10.
//  Copyright 2010 Marin Todorov. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CustomFile.h"

@interface EditorScreen : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate,UITextViewDelegate>{
    id detailItem;

    UILabel *detailDescriptionLabel;
	UIButton* currentPhotoButton;
	
	IBOutlet UIImageView* photo;
	IBOutlet UITextField* titleField;
	IBOutlet UITextView* text;
	
	IBOutlet UIButton* hideKeyboard;
}

@property (nonatomic, retain) id detailItem;

@property (nonatomic, retain) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, retain) UIButton* currentPhotoButton;

@property (nonatomic, retain) IBOutlet UIImageView* photo;
@property (nonatomic, retain) IBOutlet UITextField* titleField;
@property (nonatomic, retain) IBOutlet UITextView* text;

@property (nonatomic, retain) IBOutlet UIButton* hideKeyboard;

- (IBAction) hideTextViewKeyboard;
- (IBAction) selectPhoto:(id)sender;
- (IBAction) saveDocument;
- (IBAction) goBack;

- (void)resetView;
- (void)configureView;
@end
