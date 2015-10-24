

#import "GameScene.h"
#import "GameOverScene.h"
static const uint32_t projectileCategory = 0x1 << 0;
static const uint32_t cupcakeCategory = 0x1 << 1;

@import AVFoundation;

@interface GameScene() <SKPhysicsContactDelegate>

@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@property (nonatomic) SKSpriteNode *basket;
@property (nonatomic) SKSpriteNode *background;
@property (nonatomic) SKSpriteNode *clouds;
@property (nonatomic) SKSpriteNode *box;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) int cupcakesCollected;
@property (nonatomic) AVAudioPlayer *cupcakeEatSound;
@property (nonatomic) SKLabelNode *timeLabel;
@property (nonatomic) SKLabelNode *scoreLabel;
@end


@implementation GameScene
SKLabelNode *countDown;
BOOL startGamePlay;
NSTimeInterval startTime;

@synthesize basket, backgroundMusicPlayer, lastSpawnTimeInterval, lastUpdateTimeInterval, cupcakesCollected, scoreLabel, cupcakeEatSound, background, clouds, timeLabel, box;

-(id)initWithSize:(CGSize)size {
    if(self = [super initWithSize:size]){
        startGamePlay = YES;
        //self.backgroundColor = [SKColor colorWithRed: (0.15) green:(0.45) blue: (0.3) alpha:(1.0)];
        
        countDown = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
        countDown.fontSize = 40;
        countDown.position = CGPointMake(880, 650);
        countDown.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        countDown.fontColor = [SKColor whiteColor ];
        countDown.name = @"countDown";
        countDown.zPosition = 100;
        
        timeLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
        timeLabel.fontSize = 30;
        timeLabel.position = CGPointMake(300, 700);
        timeLabel.zPosition = 2;
        
        [self addChild:timeLabel];

        [self addChild:countDown];
    }
    
    return self;
}

-(void)didMoveToView:(SKView *)view {
    cupcakesCollected = 0;
    NSURL * backgroundMusicUrl = [[NSBundle mainBundle] URLForResource:@"gameplay" withExtension:@"mp3"];
    NSError *error;
    self.backgroundMusicPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicUrl error: &error];
    self.backgroundMusicPlayer.numberOfLoops = -1;
    [self.backgroundMusicPlayer prepareToPlay];
    [self.backgroundMusicPlayer play];
    /* Setup your scene here */
    
    //font type
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
    
    scoreLabel.text = @"Score: 0", cupcakesCollected;
    scoreLabel.fontSize = 40;
    scoreLabel.position = CGPointMake(850.00, 700.00);
    scoreLabel.color = [UIColor greenColor];
    scoreLabel.zPosition = 2;
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
    
    basket = [SKSpriteNode spriteNodeWithImageNamed:@"FATBOY"];
    basket.xScale = 0.5;
    basket.yScale = 0.5;
    basket.position = CGPointMake(500,100);
    basket.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:basket.size];
    
    //moving the basket
    basket.physicsBody.dynamic = YES;
    basket.physicsBody.categoryBitMask = projectileCategory;
    basket.physicsBody.contactTestBitMask = cupcakeCategory;
    basket.physicsBody.collisionBitMask = 0;
    basket.physicsBody.usesPreciseCollisionDetection = YES;
    
    background = [SKSpriteNode spriteNodeWithImageNamed:@"gameBG"];
    background.xScale = 1;
    background.yScale = 1;
    background.position = CGPointMake(500,400);
    
    clouds = [SKSpriteNode spriteNodeWithImageNamed:@"clouds.png"];
    clouds.xScale = 1;
    clouds.yScale = 1;
    clouds.zPosition = 1;
    clouds.position = CGPointMake(500,450);
    
    box = [SKSpriteNode spriteNodeWithImageNamed:@"box"];
    box.xScale = 0.23;
    box.yScale = 0.23;
    box.zPosition = 1.5;
    box.alpha = 0.65;
    box.position = CGPointMake(880,680);
    
    [self addChild:clouds];
    [self addChild:box];
    [self addChild:background];
    [self addChild:basket];
    [self addChild:scoreLabel];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

}

-(void)addCupcake {
    SKSpriteNode *cupcake = [SKSpriteNode spriteNodeWithImageNamed:@"cupcakeTest"];
    cupcake.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:cupcake.size];
    cupcake.physicsBody.dynamic = YES;
    cupcake.physicsBody.categoryBitMask = cupcakeCategory;
    cupcake.physicsBody.contactTestBitMask = projectileCategory;
    cupcake.physicsBody.collisionBitMask = 0;
    [cupcake setScale:0.3];
    
    //Determine where to spawn the cupcake along the X axis
    int minX = cupcake.size.width / 2;
    int maxX = self.frame.size.width - cupcake.size.width / 2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    //create a cupcake
    cupcake.position = CGPointMake(actualX, self.frame.size.width);
    [self addChild:cupcake];
    
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random()%rangeDuration) + minDuration;
    
    SKAction *actionMove = [SKAction moveTo:CGPointMake(actualX, -cupcake.size.width/2) duration:actualDuration ];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [cupcake runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}


-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addCupcake];
    }
}

-(void) update:(NSTimeInterval)currentTime {
    
    if(startGamePlay){
        startTime = currentTime;
        startGamePlay = NO;
    }
    int countDownInt = 6 - (int)(currentTime-startTime);
    if(countDownInt > 0){  //if counting down to 0 show counter
        countDown.text = [NSString stringWithFormat:@"Time Left: %i", countDownInt];
    }else { //if not show message, dismiss, whatever you need to do.
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.4];
        SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:YES score:cupcakesCollected];
        [self.view presentScene:gameOverScene transition:reveal];
    }
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if(timeSinceLast > 1) {
        timeSinceLast = 1.0/60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

-(void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];

    if(positionInScene.x < 50) {
        positionInScene.x = 75;
    }
    else if(positionInScene.x > 950) {
        positionInScene.x = 950;
    }
    SKAction *actionMove = [SKAction moveToX:positionInScene.x duration:0.5];
    [basket runAction:actionMove];

}

-(void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
}

-(void) objectFallsToBottom{
    
}


-(void) didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody, *secondBody;
    
    if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if((firstBody.categoryBitMask & projectileCategory) != 0 &&
       (secondBody.categoryBitMask & cupcakeCategory) != 0) {
        [self basket:(SKSpriteNode*)firstBody.node didCollideWithBasket:(SKSpriteNode*) secondBody.node];
    }
}


-(void)basket:(SKSpriteNode*) basket didCollideWithBasket:(SKSpriteNode*)egg {
    [egg removeFromParent];
    self.cupcakesCollected++;
    scoreLabel.text = [NSString stringWithFormat:@"Score: %d",cupcakesCollected];
    NSURL * cupcakeEatUrl = [[NSBundle mainBundle] URLForResource:@"eat sound effect" withExtension:@"mp3"];
    NSError *error;
    self.cupcakeEatSound =[[AVAudioPlayer alloc] initWithContentsOfURL:cupcakeEatUrl error: &error];
    self.cupcakeEatSound.numberOfLoops = 0;
    [self.cupcakeEatSound prepareToPlay];
    [self.cupcakeEatSound play];

}


@end
