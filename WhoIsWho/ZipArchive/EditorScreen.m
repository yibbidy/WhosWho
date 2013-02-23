//
//  EditorScreen.m
//  iPhoneCustomFileFormat
//
//  Created by Marin Todorov on 4/7/10.
//  Copyright 2010 Marin Todorov. All rights reserved.
//

#import "EditorScreen.h"


@implementation EditorScreen

@synthesize detailItem, detailDescriptionLabel, currentPhotoButton, hideKeyboard;
@synthesize photo;
@synthesize titleField, text;

#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
	[self configureView];
}

- (void)configureView {
    detailDescriptionLabel.text = [detailItem description];
	
	//empty previously loaded data
	[self resetView];
	
	//if not loading a file return
	if ([@"New document..." compare:detailItem]==NSOrderedSame) {
		return;
	}
	
	//load existing file
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString* documentsDir = [paths objectAtIndex:0];
	NSString* filePath = [documentsDir stringByAppendingPathComponent:[detailItem description]];
	
	CustomFile* currentFile = [[CustomFile alloc] initWithFilePath:filePath];
	[currentFile loadFile];
	
	self.titleField.text = currentFile.title;
	self.text.text = currentFile.text;
	if (currentFile.photo != nil) {
		[self.photo setImage: currentFile.photo ];
	}
	
	[currentFile release];
}

-(void)resetView
{
	self.titleField.text = @"Document title";
	self.text.text = @"Document text";
	[self.photo setImage:nil];
}

#pragma mark -
#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)sender
{
	if ( [sender.text length]>3  ) {
		//finish editing
		[sender resignFirstResponder];
		return YES;
	} else {
		return NO;
	}
}

#pragma mark -
#pragma mark Select Photos

- (IBAction) selectPhoto:(id)sender
{
	self.currentPhotoButton = sender;
	
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePickerController.editing = YES;
    imagePickerController.delegate = self;
    
    [self presentModalViewController:imagePickerController animated:YES];
    
    [imagePickerController release];
	
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	//grab the photo and put it in the placeholder
	[self.photo setImage:image];
	[self.navigationController dismissModalViewControllerAnimated:YES];
	NSLog(@"dismissed");
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Saving Documnet

- (IBAction) saveDocument
{
	//build the file path
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString* documentsDir = [paths objectAtIndex:0];
	
	NSString* fileName = [titleField.text stringByAppendingPathExtension:kFileExtension];
	NSString* filePath = [documentsDir stringByAppendingPathComponent:fileName];
	
	//fill in the file data 
	CustomFile* currentFile = [[CustomFile alloc] initWithFilePath: filePath];
	
	currentFile.photo = photo.image;
	currentFile.title = titleField.text;
	currentFile.text  = text.text;
	
	//save the object
	[currentFile saveFile];
	
	[currentFile release];
}


#pragma mark -
#pragma mark Go Back

-(IBAction)goBack
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
	self.hideKeyboard.hidden = NO;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	self.hideKeyboard.hidden = YES;
}

-(IBAction)hideTextViewKeyboard
{
	[self.text resignFirstResponder];
}

@end
