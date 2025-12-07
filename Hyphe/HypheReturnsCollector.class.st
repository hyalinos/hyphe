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
		'instrumentedMethodObjects',
		'owningProcess'
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
HypheReturnsCollector >> initializeForMethod: aCompiledMethod [
    "Initialize the collector for any compiled method"
    logger := HypheReturnsCollectorLogger new.
    result := HypheReturnsCollectorResult new.
    instrumentedMethods := IdentitySet new.
    instrumentedMethodObjects := OrderedCollection new.
    installedLinks := OrderedCollection new.
    collectionsData := OrderedCollection new.
    methodToCompiledMethod := Dictionary new.
    owningProcess := nil. "Set lazily during execution"
    logger log: 'HypheReturnsCollector initialized for method: ', aCompiledMethod printString
]

{ #category : 'initialization' }
HypheReturnsCollector >> initializeWith: aTestCase [
    "Initialize the collector for a test case"
    testCase := aTestCase.
    self initializeForMethod: (aTestCase class lookupSelector: aTestCase selector)
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> instrumentMethod: aCompiledMethod [
    "Instrument a method:
    1. Send nodes → propagation link (#before)
    2. Send nodes → recording link (#after) to capture return value
    Skip control flow methods to avoid bytecode generation errors"
    | methodAst sendNodes methodSelector methodClass propLink recLink |
    
    "Skip if already instrumented"
    (instrumentedMethods includes: aCompiledMethod) ifTrue: [ ^ self ].
    
    "Skip primitives"
    aCompiledMethod isPrimitive ifTrue: [ 
        instrumentedMethods add: aCompiledMethod.
        ^ self 
    ].
    
    "Skip methods with noInstrumentation or optionDisabledLink pragmas"
    (self shouldInstrumentMethod: aCompiledMethod) ifFalse: [
        instrumentedMethods add: aCompiledMethod.
        logger log: '[INSTRUMENT] Skipped (pragma): ', aCompiledMethod methodClass name, '>>', aCompiledMethod selector.
        ^ self
    ].
    
    "Mark as instrumented"
    instrumentedMethods add: aCompiledMethod.
    
    methodSelector := aCompiledMethod selector.
    methodClass := aCompiledMethod methodClass.
    
    logger log: '[INSTRUMENT] ', methodClass name, '>>', methodSelector.
    
    "Get AST and send nodes"
    methodAst := aCompiledMethod ast.
    sendNodes := methodAst sendNodes.
    
    logger log: '[INSTRUMENT] Found ', sendNodes size asString, ' sends'.
    
    "Get the links"
    propLink := self propagationLink.
    recLink := self recordingLink.
    
    "Install both links on send nodes, skipping control flow"
    sendNodes do: [ :sendNode |
        "Skip control flow methods"
        (self shouldSkipInstrumentingSend: sendNode selector) ifFalse: [
            "Propagation on send node"
            (sendNode hasMetalink: propLink)
                ifFalse: [ 
                    sendNode link: propLink.
                    logger log: '[INSTRUMENT] Linked send (prop): ', sendNode selector asString
                ].
            "Recording on send node to capture its return value"
            (sendNode hasMetalink: recLink)
                ifFalse: [
                    sendNode link: recLink.
                    logger log: '[INSTRUMENT] Linked send (rec): ', sendNode selector asString
                ]
        ] ifTrue: [
            logger log: '[INSTRUMENT] Skipped control flow send: ', sendNode selector asString
        ]
    ]
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> instrumentTestCase [
    "Instrument the test method using lookupSelector:"
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
    Guard prevents recursive instrumentation."
    
    "GUARD: If inside instrumentation, skip"
    (HypheInstrumentationGuard value = true) ifTrue: [ ^ self ].
    
    "GUARD: Only propagate in the owning process (if set)"
    (owningProcess notNil and: [ Processor activeProcess ~~ owningProcess ]) ifTrue: [ ^ self ].
    
    "Transcript output guarded to prevent instrumentation"
    HypheInstrumentationGuard value: true during: [
        Transcript show: '[PROPAGATE] CALLBACK INVOKED for ', aCompiledMethod selector; cr
    ].
    
    HypheInstrumentationGuard value: true during: [
        logger log: '[PROPAGATE] Callback for: ', aCompiledMethod methodClass name, '>>', aCompiledMethod selector.
        
        "Remove from instrumentedMethods so instrumentMethod doesn't skip it"
        instrumentedMethods remove: aCompiledMethod ifAbsent: [].
        
        self instrumentMethod: aCompiledMethod.
        logger log: '[PROPAGATE] Done'
    ]
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> propagationLink [
    "Returns the single propagation link used for all send nodes."
    
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
HypheReturnsCollector >> recordReturnValue: returnValue inMethod: aCompiledMethod [
    "Record a return value from a method execution.
    Ultra-defensive: catch ALL errors to prevent breaking test execution.
    Guard prevents recursive instrumentation during recording."
    
    "GUARD: If inside instrumentation, skip recording"
    (HypheInstrumentationGuard value = true) ifTrue: [ ^ self ].
    
    "GUARD: Only record in the owning process (if set)"
    (owningProcess notNil and: [ Processor activeProcess ~~ owningProcess ]) ifTrue: [ ^ self ].
    
    HypheInstrumentationGuard value: true during: [
        "Wrap EVERYTHING in error handler - even parameter access"
        [
            | methodClass methodSelector receiverClass returnClass dataItem |
            
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
            
            "Create and add data item"
            dataItem := HypheReturnDataItem new
                receiverClass: receiverClass;
                methodSelector: methodSelector;
                definingClass: methodClass;
                returnClass: returnClass;
                yourself.
            collectionsData add: dataItem.
            
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
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> recordingLink [
    "Returns the single recording link for capturing return values.
    Uses #after control to get return value from stack via #value reification.
    Uses methodToExecute to get the CALLED method, not the caller."
    
    ^ recordingLinkCache ifNil: [
        recordingLinkCache := MetaLink new
            metaObject: self;
            selector: #recordReturnValue:inMethod:;
            arguments: #(value methodToExecute);
            control: #after.
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

	| startTime endTime testReturnValue |
	logger log: 'Starting test execution with instrumentation'.
	result status: #running.
	startTime := DateAndTime now.

	self class activeCollector: self.


	"Set owning process in the forked process"
	owningProcess := Processor activeProcess.

	[
		[
			self instrumentTestCase.
			logger log: 'Running test case'.
			"Use runCaseForHyphe to run setUp/tearDown and get actual return value"
			testReturnValue := testCase runCaseForHyphe.
			"Manually record test method return value"
			self
				recordReturnValue: testReturnValue
				inMethod: (testCase class lookupSelector: testCase selector).
			result status: #completed.
			logger log: 'Test completed successfully' ]
			on: Error
			do: [ :ex |
					result status: (ex class name = #TestFailure
							 ifTrue: [ #testFailure ]
							 ifFalse: [ #error ]).
					result errorMessage: ex messageText.
					logger log: 'Error during execution: ' , ex messageText ] ]
		ensure: [
				self class activeCollector: nil.
				endTime := DateAndTime now.
				result executionTime: endTime - startTime.
				self cleanup.
				logger log: 'Cleanup completed' ].

	result collections: collectionsData.
	logger log:
		'Collected ' , collectionsData size asString , ' data points'.
	^ result
]

{ #category : 'running' }
HypheReturnsCollector >> runOn: aReceiver method: aCompiledMethod [
    "Run instrumentation on any method with a receiver in a new process"
    | startTime endTime returnValue semaphore |
    logger log: 'Starting execution with instrumentation'.
    result status: #running.
    startTime := DateAndTime now.
    semaphore := Semaphore new.
    
    self class activeCollector: self.
    
    [
        "Set owning process in the forked process"
        owningProcess := Processor activeProcess.
        
        [ 
            [ 
                self instrumentMethod: aCompiledMethod.
                logger log: 'Running method'.
                returnValue := aReceiver perform: aCompiledMethod selector.
                "Manually record method return value"
                self recordReturnValue: returnValue inMethod: aCompiledMethod.
                result status: #completed.
                logger log: 'Execution completed successfully'
            ] on: Error do: [ :ex |
                result status: #error.
                result errorMessage: ex messageText.
                logger log: 'Error during execution: ', ex messageText
            ]
        ] ensure: [
            self class activeCollector: nil.
            endTime := DateAndTime now.
            result executionTime: (endTime - startTime).
            self cleanup.
            logger log: 'Cleanup completed'.
            semaphore signal
        ]
    ] fork.
    
    "Wait for completion"
    semaphore wait.
    
    result collections: collectionsData.
    logger log: 'Collected ', collectionsData size asString, ' data points'.
    ^ result
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> shouldInstrumentMethod: aCompiledMethod [
    "Return true if this method should be instrumented.
    Skip methods with special pragmas that disable instrumentation.
    Skip TestCase infrastructure and Exception handling to avoid freezing.
    Wrap everything in error handler to prevent freezes."
    
    [
        | methodClass |
        
        "Check for <primitive:...> pragma (primitive:, primitive:error:, etc)"
        (aCompiledMethod pragmas anySatisfy: [ :pragma | 
            pragma selector asString beginsWith: 'primitive:' ]) ifTrue: [ ^ false ].
        
        "Check for <noInstrumentation> pragma"
        (aCompiledMethod pragmas anySatisfy: [ :pragma | 
            pragma selector = #noInstrumentation ]) ifTrue: [ ^ false ].
        
        "Check for <metaLinkOptions: #( #+ optionDisabledLink )> pragma"
        (aCompiledMethod pragmas anySatisfy: [ :pragma | 
            pragma selector = #metaLinkOptions: and: [ 
                pragma arguments notEmpty and: [
                    pragma arguments first includes: #optionDisabledLink
                ]
            ]
        ]) ifTrue: [ ^ false ].
        
        methodClass := aCompiledMethod methodClass.
        
        "Skip Exception and Error classes - critical for error handling"
        (methodClass notNil and: [ 
            methodClass includesBehavior: Exception ]) ifTrue: [ ^ false ].
        
        "Skip BlockClosure and related classes - critical for control flow"
        (methodClass notNil and: [
            (#(BlockClosure FullBlockClosure Context Process Semaphore) 
                includes: methodClass name) ]) ifTrue: [ ^ false ].
        
        "Skip TestCase assertion and infrastructure methods to avoid freezing"
        (methodClass notNil and: [ methodClass includesBehavior: TestCase ]) ifTrue: [
            | selector |
            selector := aCompiledMethod selector.
            "Skip assertion methods and test infrastructure"
            (#(assert: deny: assert:equals: assert:description: deny:description:
               assert:identicalTo: deny:identicalTo:
               should: shouldnt: should:raise: shouldnt:raise:
               should:raise:description: shouldnt:raise:description:
               assert:closeTo: deny:closeTo:
               assertEmpty: denyEmpty:
               fail signalFailure: 
               setUp tearDown runCase performTest
               cleanUpInstanceVariables
               executeShould:inScopeOf:
               assertCollection:equals:
               assertCollection:hasSameElements:) includes: selector) ifTrue: [ ^ false ]
        ].
        
        "Skip our own instrumentation classes"
        (methodClass notNil and: [
            (#(HypheReturnsCollector HypheReturnsCollectorLogger 
               HypheReturnsCollectorResult HypheReturnDataItem) 
                includes: methodClass name) ]) ifTrue: [ ^ false ].
        
        "Skip Transcript (StThreadSafeTranscript) - uses mutex causing deadlocks"
        (methodClass notNil and: [
            methodClass name = #StThreadSafeTranscript
        ]) ifTrue: [ ^ false ].
        
        "Skip Mutex and Monitor classes - synchronization primitives"
        (methodClass notNil and: [
            (#(Mutex Monitor RecursionLock) includes: methodClass name)
        ]) ifTrue: [ ^ false ].
        
        ^ true
    ] on: Error do: [ :ex |
        "On any error, skip instrumentation to be safe"
        Transcript show: '[shouldInstrumentMethod] Error checking method: ', ex messageText; cr.
        ^ false
    ]
]

{ #category : 'instrumentation' }
HypheReturnsCollector >> shouldSkipInstrumentingSend: aSelector [
    "Return true if this send should not be instrumented to avoid bytecode errors.
    Uses direct comparison to avoid instrumentation loops with includes:."
    
    "Control flow and special methods that cause bytecode generation issues"
    "Use direct = checks instead of includes: to avoid instrumentation loops"
    aSelector == #ifTrue: ifTrue: [ ^ true ].
    aSelector == #ifFalse: ifTrue: [ ^ true ].
    aSelector == #ifTrue:ifFalse: ifTrue: [ ^ true ].
    aSelector == #ifFalse:ifTrue: ifTrue: [ ^ true ].
    aSelector == #ifNil: ifTrue: [ ^ true ].
    aSelector == #ifNotNil: ifTrue: [ ^ true ].
    aSelector == #ifNil:ifNotNil: ifTrue: [ ^ true ].
    aSelector == #ifNotNil:ifNil: ifTrue: [ ^ true ].
    aSelector == #whileTrue ifTrue: [ ^ true ].
    aSelector == #whileFalse ifTrue: [ ^ true ].
    aSelector == #whileTrue: ifTrue: [ ^ true ].
    aSelector == #whileFalse: ifTrue: [ ^ true ].
    aSelector == #to:do: ifTrue: [ ^ true ].
    aSelector == #to:by:do: ifTrue: [ ^ true ].
    aSelector == #timesRepeat: ifTrue: [ ^ true ].
    aSelector == #and: ifTrue: [ ^ true ].
    aSelector == #or: ifTrue: [ ^ true ].
    aSelector == #cull: ifTrue: [ ^ true ].
    aSelector == #cull:cull: ifTrue: [ ^ true ].
    aSelector == #cull:cull:cull: ifTrue: [ ^ true ].
    aSelector == #value ifTrue: [ ^ true ].
    aSelector == #value: ifTrue: [ ^ true ].
    aSelector == #value:value: ifTrue: [ ^ true ].
    aSelector == #value:value:value: ifTrue: [ ^ true ].
    aSelector == #ensure: ifTrue: [ ^ true ].
    aSelector == #ifCurtailed: ifTrue: [ ^ true ].
    aSelector == #on:do: ifTrue: [ ^ true ].
    
    ^ false
]
