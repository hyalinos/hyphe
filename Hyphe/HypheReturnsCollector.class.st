Class {
	#name : 'HypheReturnsCollector',
	#superclass : 'Object',
	#instVars : [
		'testCase',
		'logger',
		'result',
		'instrumentedMethods',
		'installedLinks',
		'collectionsData',
		'methodToCompiledMethod'
	],
	#classVars : [
		'ActiveCollector'
	],
	#category : 'Hyphe',
	#package : 'Hyphe'
}

{ #category : 'accessing' }
HypheReturnsCollector class >> activeCollector [
    ^ ActiveCollector
]

{ #category : 'accessing' }
HypheReturnsCollector class >> activeCollector: aCollector [
    ActiveCollector := aCollector
]

{ #category : 'instance creation' }
HypheReturnsCollector class >> on: aTestCase [
    ^ self new initializeWith: aTestCase
]

{ #category : 'metalink callbacks' }
HypheReturnsCollector class >> propagateFrom: aReceiver with: aSelector [
    "Called by before links - delegates to active collector"
    self activeCollector ifNotNil: [ :collector |
        collector propagateFrom: aReceiver with: aSelector
    ]
]

{ #category : 'metalink callbacks' }
HypheReturnsCollector class >> record: returnValue from: aReceiver selector: aSelector [
    "Called by after links - delegates to active collector"
    self activeCollector ifNotNil: [ :collector |
        collector record: returnValue from: aReceiver selector: aSelector
    ]
]

{ #category : 'cleanup' }
HypheReturnsCollector >> cleanup [
    logger log: 'Cleaning up instrumentation (', instrumentedMethods size asString, ' methods, ', installedLinks size asString, ' links)'.
    
    [ 
        installedLinks do: [ :link | 
            [ link uninstall ] on: Error do: [ :ex | 
                logger log: 'Error uninstalling link: ', ex messageText 
            ]
        ].
        
        installedLinks := OrderedCollection new.
        logger log: 'All links uninstalled'
    ] on: Error do: [ :ex |
        Transcript show: 'CRITICAL ERROR during cleanup: '; show: ex messageText; cr.
        logger log: 'CRITICAL ERROR during cleanup: ', ex messageText
    ]
]

{ #category : 'initialization' }
HypheReturnsCollector >> initializeWith: aTestCase [
    testCase := aTestCase.
    logger := HypheReturnsCollectorLogger new.
    result := HypheReturnsCollectorResult new.
    instrumentedMethods := IdentitySet new.
    installedLinks := OrderedCollection new.
    collectionsData := OrderedCollection new.
    methodToCompiledMethod := Dictionary new.
    logger log: 'HypheReturnsCollector initialized for test: ', aTestCase printString
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> instrumentMethod: aCompiledMethod [
    | methodAst afterLink methodSelector methodClass sendNodes |
    
    (instrumentedMethods includes: aCompiledMethod) ifTrue: [ ^ self ].
    
    aCompiledMethod isPrimitive ifTrue: [ 
        instrumentedMethods add: aCompiledMethod.
        ^ self 
    ].
    
    instrumentedMethods add: aCompiledMethod.
    
    methodSelector := aCompiledMethod selector.
    methodClass := aCompiledMethod methodClass.
    
    logger log: 'Instrumenting: ', methodClass name, '>>', methodSelector.
    
    methodAst := aCompiledMethod ast.
    sendNodes := methodAst sendNodes.
    
    methodToCompiledMethod at: methodAst put: aCompiledMethod.
    
    logger log: 'Installing before links on ', sendNodes size asString, ' send nodes'.
    sendNodes do: [ :sendNode |
        [
            | beforeLink |
            logger log: 'Creating before link for: ', sendNode selector asString.
            
            beforeLink := MetaLink new
                metaObject: [ :rcv :sel | 
                    | collector |
                    collector := HypheReturnsCollector activeCollector.
                    collector ifNotNil: [ 
                        collector propagateFrom: rcv with: sel
                    ]
                ];
                selector: #value:value:;
                arguments: #(receiver selector);
                control: #before.
            installedLinks add: beforeLink.
            sendNode link: beforeLink.
            logger log: 'Linked before link'
        ] on: Error do: [ :ex |
            logger log: 'ERROR: ', ex messageText
        ]
    ].
    
    [
        afterLink := MetaLink new
            metaObject: [ :val :rcv :sel | 
                | collector |
                collector := HypheReturnsCollector activeCollector.
                collector ifNotNil: [
                    collector record: val from: rcv sel: sel in: methodClass
                ]
            ];
            selector: #value:value:value:;
            arguments: #(value receiver selector);
            control: #after.
        installedLinks add: afterLink.
        methodAst link: afterLink.
        logger log: 'Linked after link'
    ] on: Error do: [ :ex |
        logger log: 'ERROR: ', ex messageText
    ]
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> instrumentTestCase [
    | testMethod |
    logger log: 'Instrumenting test case method'.
    testMethod := testCase class >> testCase selector.
    self instrumentMethod: testMethod
]

{ #category : 'accessing' }
HypheReturnsCollector >> logger [
    ^ logger
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> propagateFrom: aReceiver with: aSelector [
    [
        | compiledMethod |
        
        logger log: '[PROPAGATE] Called with receiver: ', aReceiver class name, ' selector: ', aSelector asString.
        
        "Lookup the method that will be executed"
        compiledMethod := aReceiver class lookupSelector: aSelector.
        
        compiledMethod ifNil: [ 
            logger log: '[PROPAGATE] DNU detected for selector: ', aSelector.
            ^ self 
        ].
        
        logger log: '[PROPAGATE] Found method: ', compiledMethod methodClass name, '>>', compiledMethod selector.
        
        "Propagate instrumentation to the called method"
        self instrumentMethod: compiledMethod.
        
        logger log: '[PROPAGATE] Instrumentation complete for: ', aSelector asString
    ] on: Error do: [ :ex |
        logger log: '[PROPAGATE] Error in propagateFrom:with: ', ex messageText.
        logger log: '[PROPAGATE] Stack: ', ex signalerContext shortStack asString
    ]
]

{ #category : 'data collection' }
HypheReturnsCollector >> record: returnValue from: aReceiver sel: aSelector in: aMethodClass [
    [
        | receiverClass returnClass dataPoint |
        receiverClass := aReceiver class.
        returnClass := returnValue class.
        dataPoint := { receiverClass . aSelector . aMethodClass . returnClass }.
        collectionsData add: dataPoint.
        logger log: 'Collected: ', receiverClass name, ' >> ', aSelector, ' (method from: ', aMethodClass name, ', returns: ', returnClass name, ')'
    ] on: Error do: [ :ex |
        logger log: 'Error in record:from:sel:in: ', ex messageText
    ]
]

{ #category : 'data collection' }
HypheReturnsCollector >> record: returnValue from: aReceiver selector: aSelector [
    [
        | receiverClass returnClass dataPoint compiledMethod methodClass |
        
        "Look up the method to get its defining class"
        compiledMethod := aReceiver class lookupSelector: aSelector.
        methodClass := compiledMethod 
            ifNotNil: [ compiledMethod methodClass ]
            ifNil: [ aReceiver class "fallback" ].
        
        receiverClass := aReceiver class.
        returnClass := returnValue class.
        dataPoint := { receiverClass . aSelector . methodClass . returnClass }.
        collectionsData add: dataPoint.
        logger log: 'Collected: ', receiverClass name, ' >> ', aSelector, ' (method from: ', methodClass name, ', returns: ', returnClass name, ')'
    ] on: Error do: [ :ex |
        logger log: 'Error in record:from:selector: ', ex messageText
    ]
]

{ #category : 'accessing' }
HypheReturnsCollector >> result [
    ^ result
]

{ #category : 'running' }
HypheReturnsCollector >> run [
    | startTime endTime |
    logger log: 'Starting test execution with instrumentation'.
    result status: #running.
    startTime := DateAndTime now.
    
    self class activeCollector: self.
    
    [ 
        [ 
            self instrumentTestCase.
            logger log: 'Running test case'.
            testCase runCase.
            result status: #completed.
            logger log: 'Test completed successfully'
        ] on: Error do: [ :ex |
            result status: (ex class name = #TestFailure ifTrue: [ #testFailure ] ifFalse: [ #error ]).
            result errorMessage: ex messageText.
            logger log: 'Error during execution: ', ex messageText
        ]
    ] ensure: [
        self class activeCollector: nil.
        endTime := DateAndTime now.
        result executionTime: (endTime - startTime).
        self cleanup.
        logger log: 'Cleanup completed'
    ].
    
    result collections: collectionsData.
    logger log: 'Collected ', collectionsData size asString, ' data points'.
    ^ result
]
