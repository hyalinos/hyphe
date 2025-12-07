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
		'methodToCompiledMethod',
		'propagationLinkCache',
		'recordingLinkCache',
		'instrumentedMethodObjects'
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
    "Initialize the collector for a test case"
    testCase := aTestCase.
    logger := HypheReturnsCollectorLogger new.
    result := HypheReturnsCollectorResult new.
    instrumentedMethods := IdentitySet new.
    instrumentedMethodObjects := OrderedCollection new.  "Keep strong references!"
    installedLinks := OrderedCollection new.
    collectionsData := OrderedCollection new.
    methodToCompiledMethod := Dictionary new.
    logger log: 'HypheReturnsCollector initialized for test: ', aTestCase printString
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> instrumentMethod: aCompiledMethod [
    "Instrument a method by linking:
    1. Send nodes → propagation (works!)
    2. Return nodes → recording (survives method replacement!)"
    | methodAst sendNodes returnNodes methodSelector methodClass propLink recLink |
    
    "Skip if already instrumented or is primitive"
    (instrumentedMethods includes: aCompiledMethod) ifTrue: [ ^ self ].
    aCompiledMethod isPrimitive ifTrue: [ 
        instrumentedMethods add: aCompiledMethod.
        ^ self 
    ].
    
    "Mark as instrumented"
    instrumentedMethods add: aCompiledMethod.
    
    methodSelector := aCompiledMethod selector.
    methodClass := aCompiledMethod methodClass.
    
    logger log: '[INSTRUMENT] ', methodClass name, '>>', methodSelector.
    
    "Get AST, send nodes, and return nodes"
    methodAst := aCompiledMethod ast.
    sendNodes := methodAst sendNodes.
    returnNodes := methodAst allChildren select: [ :node | node isReturn ].
    
    logger log: '[INSTRUMENT] Found ', sendNodes size asString, ' sends, ', returnNodes size asString, ' returns'.
    
    "Get the links"
    propLink := self propagationLink.
    recLink := self recordingLink.
    
    "Install propagation link on each send node"
    sendNodes do: [ :sendNode |
        (sendNode hasMetalink: propLink) 
            ifFalse: [ 
                sendNode link: propLink.
                logger log: '[INSTRUMENT] Linked send: ', sendNode selector asString
            ]
    ].
    
    "Install recording link on RETURN NODES instead of method AST!"
    returnNodes do: [ :returnNode |
        (returnNode hasMetalink: recLink)
            ifFalse: [
                returnNode link: recLink.
                logger log: '[INSTRUMENT] Linked return node'
            ]
    ].
    
    "If no explicit returns, link the method AST (implicit return)"
    returnNodes ifEmpty: [
        (methodAst hasMetalink: recLink)
            ifFalse: [
                methodAst link: recLink.
                logger log: '[INSTRUMENT] Linked method (implicit return)'
            ]
    ]
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> instrumentTestCase [
    "Instrument the test method. CRITICAL: Use lookupSelector: to get the right method!"
    | testMethod testSelector testClass |
    
    testSelector := testCase selector.
    testClass := testCase class.
    
    logger log: '[INSTRUMENT TEST] Looking up ', testClass name, '>>', testSelector.
    
    "Use lookupSelector: to get the actual method that will execute"
    testMethod := testClass lookupSelector: testSelector.
    
    logger log: '[INSTRUMENT TEST] Found method in class: ', testMethod methodClass name.
    
    self instrumentMethod: testMethod
]

{ #category : 'accessing' }
HypheReturnsCollector >> logger [
    ^ logger
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> propagateInstrumentationTo: aCompiledMethod [
    "Called by MetaLink before a message send executes.
    ALWAYS re-instrument because Pharo replaces ReflectiveMethods!"
    
    Transcript show: '[PROPAGATE] CALLBACK INVOKED for ', aCompiledMethod selector; cr.
    logger log: '[PROPAGATE] Callback for: ', aCompiledMethod methodClass name, '>>', aCompiledMethod selector.
    
    "ALWAYS instrument - don't check if already done, because method might have been replaced"
    "Remove from instrumentedMethods so instrumentMethod doesn't skip it"
    instrumentedMethods remove: aCompiledMethod ifAbsent: [].
    
    self instrumentMethod: aCompiledMethod.
    logger log: '[PROPAGATE] Done'
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> propagationLink [
    "Returns the single propagation link used for all send nodes.
    Pattern copied EXACTLY from SelfPropagatingLinkDemo - uses instance variable!"
    
    ^ propagationLinkCache ifNil: [
        propagationLinkCache := MetaLink new
            metaObject: self;
            selector: #propagateInstrumentationTo:;
            arguments: #(methodToExecute).
        "Add to installedLinks for cleanup"
        installedLinks add: propagationLinkCache.
        propagationLinkCache
    ]
]

{ #category : 'data collection' }
HypheReturnsCollector >> recordReturn: returnValue from: aReceiver selector: aSelector definingClass: aDefiningClass [
    "Record a return value from a method execution"
    [
        | receiverClass returnClass dataPoint |
        
        receiverClass := aReceiver class.
        returnClass := returnValue class.
        dataPoint := { receiverClass . aSelector . aDefiningClass . returnClass }.
        collectionsData add: dataPoint.
        
        logger log: 'Recorded: ', receiverClass name, ' >> ', aSelector, 
                    ' returns ', returnClass name, ' (from: ', aDefiningClass name, ')'.
    ] on: Error do: [ :ex |
        logger log: 'Error recording return: ', ex messageText
    ]
]

{ #category : 'data collection' }
HypheReturnsCollector >> recordReturn: returnValue from: aReceiver selector: aSelector method: aCompiledMethod [
    "Old recording method - kept for backward compatibility but not used"
    self recordReturnValue: returnValue inMethod: aCompiledMethod
]

{ #category : 'data collection' }
HypheReturnsCollector >> recordReturnValue: returnValue inMethod: aCompiledMethod [
    "Record a return value from a return node.
    Ultra-defensive: catch ALL errors to prevent breaking test execution."
    
    "Wrap EVERYTHING in error handler - even parameter access"
    [
        | methodClass methodSelector receiverClass returnClass dataPoint |
        
        "Try to get method info"
        [ 
            methodClass := aCompiledMethod methodClass.
            methodSelector := aCompiledMethod selector.
        ] on: Error do: [ :ex |
            "If we can't even get method info, use fallback"
            methodClass := #UnknownClass.
            methodSelector := #unknownSelector.
        ].
        
        "Try to get receiver class"
        [
            receiverClass := methodClass.
        ] on: Error do: [ :ex |
            receiverClass := #UnknownReceiver.
        ].
        
        "Try to get return class"
        [
            returnClass := returnValue class.
        ] on: Error do: [ :ex |
            "If returnValue itself errors, mark it"
            returnClass := #ErrorGettingReturnType.
        ].
        
        "Create and add data point"
        dataPoint := { receiverClass . methodSelector . methodClass . returnClass }.
        collectionsData add: dataPoint.
        
        logger log: '[RECORD] ', receiverClass printString, ' >> ', methodSelector printString, 
                    ' returns ', returnClass printString.
                    
    ] on: Error do: [ :ex |
        "Ultimate fallback: if ANYTHING fails, silently continue"
        "Don't even try to log, just survive"
        [ 
            Transcript show: '[COLLECTOR] Silent error in recordReturnValue: ', ex messageText; cr.
        ] on: Error do: [ "ignore even this" ]
    ]
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> recordingLink [
    "Returns the single recording link used for all return nodes.
    Uses #before control and available reifications for return nodes."
    
    ^ recordingLinkCache ifNil: [
        recordingLinkCache := MetaLink new
            metaObject: self;
            selector: #recordReturnValue:inMethod:;
            arguments: #(value method);
            control: #before.
        "Add to installedLinks for cleanup"
        installedLinks add: recordingLinkCache.
        recordingLinkCache
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
