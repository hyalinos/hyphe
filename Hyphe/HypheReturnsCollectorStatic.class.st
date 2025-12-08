Class {
	#name : 'HypheReturnsCollectorStatic',
	#superclass : 'Object',
	#instVars : [
		'testCase',
		'logger',
		'result',
		'instrumentedMethods',
		'installedLinks',
		'collectionsData',
		'recordingLinkCache',
		'owningProcess',
		'domainPackages',
		'domainMethods'
	],
	#category : 'Hyphe',
	#package : 'Hyphe'
}

{ #category : 'instance creation' }
HypheReturnsCollectorStatic class >> on: aTestCase forPackages: packageNames [
    ^ self new initializeWith: aTestCase forPackages: packageNames
]

{ #category : 'instance creation' }
HypheReturnsCollectorStatic class >> onMethod: aCompiledMethod forPackages: packageNames [
    ^ self new initializeForMethod: aCompiledMethod withPackages: packageNames
]

{ #category : 'cleanup' }
HypheReturnsCollectorStatic >> cleanup [
    "Clean up all instrumentation"
    logger log: 'Cleaning up instrumentation (', instrumentedMethods size asString, ' methods, ', installedLinks size asString, ' links)'.
    
    [ 
        installedLinks do: [ :link | 
            [ link uninstall ] on: Error do: [ :ex | 
                logger log: 'Error uninstalling link: ', ex messageText 
            ]
        ].
        
        installedLinks := HypheInternalCollection new.
        logger log: 'All links uninstalled'
    ] on: Error do: [ :ex |
        Transcript show: 'CRITICAL ERROR during cleanup: '; show: ex messageText; cr.
        logger log: 'CRITICAL ERROR during cleanup: ', ex messageText
    ]
]

{ #category : 'instrumentation' }
HypheReturnsCollectorStatic >> collectDomainMethods [
    "Traverse all packages and collect methods to instrument"
    logger log: '[COLLECT] Gathering methods from domain packages...'.
    
    domainPackages do: [ :packageName |
        | package |
        package := PackageOrganizer default packageNamed: packageName ifAbsent: [ nil ].
        package ifNotNil: [
            logger log: '[COLLECT] Processing package: ', packageName.
            package definedClasses do: [ :class |
                "Instance methods"
                class methods do: [ :method |
                    domainMethods add: method
                ].
                "Class-side methods"
                class classSide methods do: [ :method |
                    domainMethods add: method
                ]
            ]
        ] ifNil: [
            logger log: '[COLLECT] WARNING: Package not found: ', packageName
        ]
    ].
    
    logger log: '[COLLECT] Found ', domainMethods size asString, ' methods in domain packages'
]

{ #category : 'accessing' }
HypheReturnsCollectorStatic >> domainMethods [
    ^ domainMethods
]

{ #category : 'accessing' }
HypheReturnsCollectorStatic >> domainPackages [
    ^ domainPackages
]

{ #category : 'initialization' }
HypheReturnsCollectorStatic >> initializeForMethod: aCompiledMethod [
    logger := HypheReturnsCollectorLogger new.
    result := HypheReturnsCollectorResult new.
    instrumentedMethods := IdentitySet new.
    installedLinks := HypheInternalCollection new.
    collectionsData := HypheInternalCollection new.
    domainMethods := OrderedCollection new.
    owningProcess := nil.
    logger log: 'HypheReturnsCollectorStatic initialized for method: ', aCompiledMethod printString.
    logger log: 'Domain packages: ', domainPackages asString
]

{ #category : 'initialization' }
HypheReturnsCollectorStatic >> initializeForMethod: aCompiledMethod withPackages: packageNames [
    domainPackages := packageNames asArray.
    testCase := nil.
    self initializeForMethod: aCompiledMethod
]

{ #category : 'initialization' }
HypheReturnsCollectorStatic >> initializeWith: aTestCase forPackages: packageNames [
    "Initialize the collector for a test case and domain packages"
    testCase := aTestCase.
    domainPackages := packageNames asArray.
    self initializeForMethod: (aTestCase class lookupSelector: aTestCase selector)
]

{ #category : 'instrumentation' }
HypheReturnsCollectorStatic >> instrumentDomainMethods [
    "Instrument all methods in domain packages"
    logger log: '[INSTRUMENT] Starting instrumentation of ', domainMethods size asString, ' methods...'.
    
    domainMethods do: [ :method |
        [ 
            self instrumentMethod: method 
        ] on: Error do: [ :ex |
            logger log: '[INSTRUMENT] ERROR instrumenting ', method methodClass name, '>>', method selector, ': ', ex messageText
        ]
    ].
    
    logger log: '[INSTRUMENT] Instrumentation complete. Instrumented ', instrumentedMethods size asString, ' methods'
]

{ #category : 'instrumentation' }
HypheReturnsCollectorStatic >> instrumentMethod: aCompiledMethod [
    "Instrument a method with recording link only (no propagation).
    Install on send nodes to capture return values.
    SKIP inlined sends to avoid bytecode generation errors."
    | methodAst sendNodes methodSelector methodClass recLink skippedCount linkedCount |
    
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
    
    "Wrap entire instrumentation in error handler"
    [
        "Get AST and send nodes"
        methodAst := aCompiledMethod ast.
        sendNodes := methodAst sendNodes.
        
        logger log: '[INSTRUMENT] Found ', sendNodes size asString, ' sends'.
        
        "Get the recording link"
        recLink := self recordingLink.
        
        skippedCount := 0.
        linkedCount := 0.
        
        "Install recording link on send nodes, skipping inlined and control flow"
        sendNodes do: [ :sendNode |
            (self shouldSkipInstrumentingSendNode: sendNode) ifFalse: [
                (sendNode hasMetalink: recLink)
                    ifFalse: [
                        "Wrap link installation in error handler"
                        [
                            sendNode link: recLink.
                            linkedCount := linkedCount + 1.
                            logger log: '[INSTRUMENT] Linked send: ', sendNode selector asString
                        ] on: Error do: [ :ex |
                            skippedCount := skippedCount + 1.
                            logger log: '[INSTRUMENT] ERROR linking send ', sendNode selector asString, 
                                ': ', ex messageText
                        ]
                    ]
            ] ifTrue: [
                skippedCount := skippedCount + 1.
                logger log: '[INSTRUMENT] Skipped inlined/control send: ', sendNode selector asString
            ]
        ].
        
        logger log: '[INSTRUMENT] Complete for method - Linked: ', linkedCount asString, 
                    ' Skipped: ', skippedCount asString
                    
    ] on: Error do: [ :ex |
        logger log: '[INSTRUMENT] ERROR processing method AST: ', ex messageText.
        "Remove from instrumented if failed"
        instrumentedMethods remove: aCompiledMethod ifAbsent: []
    ]
]

{ #category : 'instrumentation' }
HypheReturnsCollectorStatic >> instrumentTestCase [
    "Instrument the test method"
    | testMethod testSelector testClass |
    
    testSelector := testCase selector.
    testClass := testCase class.
    
    logger log: '[INSTRUMENT TEST] Looking up ', testClass name, '>>', testSelector.
    
    testMethod := testClass lookupSelector: testSelector.
    
    logger log: '[INSTRUMENT TEST] Found method in class: ', testMethod methodClass name.
    
    self instrumentMethod: testMethod
]

{ #category : 'accessing' }
HypheReturnsCollectorStatic >> logger [
    ^ logger
]

{ #category : 'data collection' }
HypheReturnsCollectorStatic >> recordReturnValue: returnValue fromReceiver: aReceiver [
    "Record a return value. Method info must be inferred from receiver.
    This is the safest approach with minimal reifications."
    
    "GUARD: If inside instrumentation, skip recording"
    (HypheInstrumentationGuard value = true) ifTrue: [ ^ self ].
    
    "GUARD: Only record in the owning process (if set)"
    (owningProcess notNil and: [ Processor activeProcess ~~ owningProcess ]) ifTrue: [ ^ self ].
    
    HypheInstrumentationGuard value: true during: [
        [
            | receiverClass returnClass dataItem |
            
            "Try to get receiver class"
            [
                receiverClass := aReceiver class.
            ] on: Error do: [ :ex |
                receiverClass := #UnknownReceiver.
            ].
            
            "Try to get return class"
            [
                returnClass := returnValue class.
            ] on: Error do: [ :ex |
                returnClass := #ErrorGettingReturnType.
            ].
            
            "Create data item WITHOUT method info (we cant reliably get it)"
            dataItem := HypheReturnDataItem new
                methodSelector: #unknownSelector;
                definingClass: receiverClass;
                receiverClass: receiverClass;
                returnClass: returnClass;
                yourself.
            collectionsData add: dataItem.
            
            logger log: '[RECORD] ', receiverClass printString, 
                        ' returns ', returnClass printString.
                        
        ] on: Error do: [ :ex |
            [ 
                Transcript show: '[COLLECTOR] Silent error: ', ex messageText; cr.
            ] on: Error do: [ "ignore" ]
        ]
    ]
]

{ #category : 'data collection' }
HypheReturnsCollectorStatic >> recordReturnValue: returnValue fromReceiver: aReceiver inContext: aContext [
    "Record a return value from a method execution.
    aContext is the execution context, from which we extract the method.
    Ultra-defensive: catch ALL errors to prevent breaking test execution."
    
    "GUARD: If inside instrumentation, skip recording"
    (HypheInstrumentationGuard value = true) ifTrue: [ ^ self ].
    
    "GUARD: Only record in the owning process (if set)"
    (owningProcess notNil and: [ Processor activeProcess ~~ owningProcess ]) ifTrue: [ ^ self ].
    
    HypheInstrumentationGuard value: true during: [
        [
            | methodClass methodSelector receiverClass returnClass dataItem aCompiledMethod |
            
            "Try to extract the compiled method from context"
            [
                aCompiledMethod := (aContext respondsTo: #method) 
                    ifTrue: [ aContext method ]
                    ifFalse: [ 
                        "Fallback: try to get from receiver and selector"
                        (aContext respondsTo: #selector) 
                            ifTrue: [ aReceiver class lookupSelector: aContext selector ]
                            ifFalse: [ nil ]
                    ].
            ] on: Error do: [ :ex |
                aCompiledMethod := nil.
            ].
            
            "Try to get method info"
            [ 
                aCompiledMethod ifNotNil: [
                    methodClass := aCompiledMethod methodClass.
                    methodSelector := aCompiledMethod selector.
                ] ifNil: [
                    methodClass := #UnknownClass.
                    methodSelector := #unknownSelector.
                ]
            ] on: Error do: [ :ex |
                methodClass := #UnknownClass.
                methodSelector := #unknownSelector.
            ].
            
            "Try to get receiver class from actual receiver"
            [
                receiverClass := aReceiver class.
            ] on: Error do: [ :ex |
                receiverClass := #UnknownReceiver.
            ].
            
            "Try to get return class"
            [
                returnClass := returnValue class.
            ] on: Error do: [ :ex |
                returnClass := #ErrorGettingReturnType.
            ].
            
            "Create and add data item"
            dataItem := HypheReturnDataItem new
                methodSelector: methodSelector;
                definingClass: methodClass;
                receiverClass: receiverClass;
                returnClass: returnClass;
                yourself.
            collectionsData add: dataItem.
            
            logger log: '[RECORD] ', receiverClass printString, ' >> ', methodSelector printString, 
                        ' returns ', returnClass printString.
                        
        ] on: Error do: [ :ex |
            "Ultimate fallback: if ANYTHING fails, silently continue"
            [ 
                Transcript show: '[COLLECTOR] Silent error in recordReturnValue: ', ex messageText; cr.
            ] on: Error do: [ "ignore even this" ]
        ]
    ]
]

{ #category : 'data collection' }
HypheReturnsCollectorStatic >> recordReturnValue: returnValue fromReceiver: aReceiver inMethod: aCompiledMethod [
    "Record a return value from a method execution with the actual receiver.
    Ultra-defensive: catch ALL errors to prevent breaking test execution."
    
    "GUARD: If inside instrumentation, skip recording"
    (HypheInstrumentationGuard value = true) ifTrue: [ ^ self ].
    
    "GUARD: Only record in the owning process (if set)"
    (owningProcess notNil and: [ Processor activeProcess ~~ owningProcess ]) ifTrue: [ ^ self ].
    
    HypheInstrumentationGuard value: true during: [
        [
            | methodClass methodSelector receiverClass returnClass dataItem |
            
            "Try to get method info"
            [ 
                methodClass := aCompiledMethod methodClass.
                methodSelector := aCompiledMethod selector.
            ] on: Error do: [ :ex |
                methodClass := #UnknownClass.
                methodSelector := #unknownSelector.
            ].
            
            "Try to get receiver class from actual receiver"
            [
                receiverClass := aReceiver class.
            ] on: Error do: [ :ex |
                receiverClass := #UnknownReceiver.
            ].
            
            "Try to get return class"
            [
                returnClass := returnValue class.
            ] on: Error do: [ :ex |
                returnClass := #ErrorGettingReturnType.
            ].
            
            "Create and add data item with ALL fields"
            dataItem := HypheReturnDataItem new
                methodSelector: methodSelector;
                definingClass: methodClass;
                receiverClass: receiverClass;
                returnClass: returnClass;
                yourself.
            collectionsData add: dataItem.
            
            logger log: '[RECORD] ', receiverClass printString, ' >> ', methodSelector printString, 
                        ' returns ', returnClass printString.
                        
        ] on: Error do: [ :ex |
            "Ultimate fallback: if ANYTHING fails, silently continue"
            [ 
                Transcript show: '[COLLECTOR] Silent error in recordReturnValue: ', ex messageText; cr.
            ] on: Error do: [ "ignore even this" ]
        ]
    ]
]

{ #category : 'data collection' }
HypheReturnsCollectorStatic >> recordReturnValue: returnValue inMethod: aCompiledMethod [
    "Record a return value from a method execution.
    Ultra-defensive: catch ALL errors to prevent breaking test execution."
    
    "GUARD: If inside instrumentation, skip recording"
    (HypheInstrumentationGuard value = true) ifTrue: [ ^ self ].
    
    "GUARD: Only record in the owning process (if set)"
    (owningProcess notNil and: [ Processor activeProcess ~~ owningProcess ]) ifTrue: [ ^ self ].
    
    HypheInstrumentationGuard value: true during: [
        [
            | methodClass methodSelector receiverClass returnClass dataItem |
            
            "Try to get method info"
            [ 
                methodClass := aCompiledMethod methodClass.
                methodSelector := aCompiledMethod selector.
            ] on: Error do: [ :ex |
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
                returnClass := #ErrorGettingReturnType.
            ].
            
            "Create and add data item"
            dataItem := HypheReturnDataItem new
                methodSelector: methodSelector;
                definingClass: methodClass;
                returnClass: returnClass;
                yourself.
            collectionsData add: dataItem.
            
            logger log: '[RECORD] ', receiverClass printString, ' >> ', methodSelector printString, 
                        ' returns ', returnClass printString.
                        
        ] on: Error do: [ :ex |
            "Ultimate fallback: if ANYTHING fails, silently continue"
            [ 
                Transcript show: '[COLLECTOR] Silent error in recordReturnValue: ', ex messageText; cr.
            ] on: Error do: [ "ignore even this" ]
        ]
    ]
]

{ #category : 'instrumentation' }
HypheReturnsCollectorStatic >> recordingLink [
    "Returns the single recording link for capturing return values.
    Only reifies value and receiver - no methodToExecute to avoid argument issues."
    
    ^ recordingLinkCache ifNil: [
        recordingLinkCache := MetaLink new
            metaObject: self;
            selector: #recordReturnValue:fromReceiver:;
            arguments: #(value receiver);
            control: #after.
        installedLinks add: recordingLinkCache.
        recordingLinkCache
    ]
]

{ #category : 'accessing' }
HypheReturnsCollectorStatic >> result [
    ^ result
]

{ #category : 'running' }
HypheReturnsCollectorStatic >> run [
    | startTime endTime testReturnValue testMethod |
    result status: #running.
    startTime := DateAndTime now.
    owningProcess := Processor activeProcess.
    
    [
        [
            self collectDomainMethods.
            self instrumentDomainMethods.
            self instrumentTestCase.
            
            testReturnValue := testCase runCaseForHyphe.
            testMethod := testCase class lookupSelector: testCase selector.
            self recordReturnValue: testReturnValue 
                fromReceiver: testCase 
                inMethod: testMethod.
            
            result status: #completed.
        ] on: Error do: [ :ex |
            result status: #error.
            result errorMessage: ex messageText.
        ]
    ] ensure: [
        self cleanup.
        endTime := DateAndTime now.
        result executionTime: (endTime - startTime).
        result collections: collectionsData asArray.
    ].
    
    ^ result
]

{ #category : 'running' }
HypheReturnsCollectorStatic >> runOn: aReceiver method: aCompiledMethod [
    | startTime endTime returnValue |
    result status: #running.
    startTime := DateAndTime now.
    owningProcess := Processor activeProcess.
    
    [
        [
            self collectDomainMethods.
            self instrumentDomainMethods.
            self instrumentMethod: aCompiledMethod.
            
            returnValue := aReceiver perform: aCompiledMethod selector.
            self recordReturnValue: returnValue 
                fromReceiver: aReceiver 
                inMethod: aCompiledMethod.
            
            result status: #completed.
        ] on: Error do: [ :ex |
            result status: #error.
            result errorMessage: ex messageText.
        ]
    ] ensure: [
        self cleanup.
        endTime := DateAndTime now.
        result executionTime: (endTime - startTime).
        result collections: collectionsData asArray.
    ].
    
    ^ result
]

{ #category : 'instrumentation' }
HypheReturnsCollectorStatic >> shouldInstrumentMethod: aCompiledMethod [
    "Check if method has noInstrumentation or optionDisabledLink pragmas"
    ^ (aCompiledMethod hasPragmaNamed: #noInstrumentation) not
        and: [ (aCompiledMethod hasPragmaNamed: #optionDisabledLink) not ]
]

{ #category : 'instrumentation' }
HypheReturnsCollectorStatic >> shouldSkipInstrumentingSend: selector [
    "Skip control flow methods and other problematic selectors.
    This is a selector-based check, complementing the AST node check."
    ^ #(ifTrue: ifFalse: ifTrue:ifFalse: ifFalse:ifTrue: 
        ifNil: ifNotNil: ifNil:ifNotNil: ifNotNil:ifNil:
        whileTrue: whileFalse: whileTrue whileFalse 
        and: or: not
        timesRepeat: to:do: to:by:do:
        repeat caseOf: caseOf:otherwise:
        cull: cull:cull: cull:cull:cull:
        on:do: ensure: ifCurtailed:) includes: selector
]

{ #category : 'instrumentation' }
HypheReturnsCollectorStatic >> shouldSkipInstrumentingSendNode: aSendNode [
    "Check if we should skip instrumenting this send node.
    Returns true if the node is inlined or otherwise problematic."
    
    "Check if node is inlined (special compiler optimization)"
    [ 
        (aSendNode respondsTo: #isInlined) ifTrue: [
            aSendNode isInlined ifTrue: [ ^ true ]
        ]
    ] on: Error do: [ :ex |
        "If we cant check, be safe and skip it"
        logger log: '[INSTRUMENT] Cannot check if inlined, skipping: ', ex messageText.
        ^ true
    ].
    
    "Also check the selector against known control flow patterns"
    ^ self shouldSkipInstrumentingSend: aSendNode selector
]
