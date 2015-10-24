//
//  GameOverScene.m
//  Exercise6Group6
//
//  Created by ubicomp6 on 10/15/15.
//  Copyright © 2015 cpl. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"

@implementation GameOverScene

-(id)initWithSize:(CGSize)size won:(BOOL)won score:(int )score {
    if (self = [super initWithSize:size]) {
        
        // 1
        self.backgroundColor = [SKColor colorWithRed:2.0 green:1.0 blue:1.0 alpha:1.0];
        
        // 2
        NSString * message,*DisplayScore;
        int userScore;
        
        if (won) {
            message = @"Tap to play again! ";
            DisplayScore = @"Your Score:";
            userScore = score;
        }
        
        // 3
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
        SKLabelNode *labelScore = [SKLabelNode labelNodeWithFontNamed:@"Calibri"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        labelScore.text = [NSString stringWithFormat:@"%@ %d",DisplayScore,userScore];
        labelScore.fontSize = 40;
        labelScore.fontColor = [SKColor blackColor];
        labelScore.position = CGPointMake(self.size.width/2, self.size.height/2 + 50);
        
        [self addChild:labelScore];
        [self addChild:label];
        
        
    }
    return self;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
    SKScene * myScene = [[GameScene alloc] initWithSize:self.size];
    [self.view presentScene:myScene transition: reveal];
}

@end

