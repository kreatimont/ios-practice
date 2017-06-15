#import "TestHeader.h"

@implementation TestClass

    + (instancetype)shared
    {
        static TestClass*  instance = nil;
        @synchronized(self)
        {
            if (!instance) {
                instance = [TestClass new];
            }
        }
        return instance;
    }
    
    - (void) printTest
    {
        printf("it`s objective c func");
    }

@end
