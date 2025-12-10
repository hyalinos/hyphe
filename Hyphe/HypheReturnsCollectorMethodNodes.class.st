"
```smalltalk
""===============================================""
""USAGE EXAMPLES: processPackages: method""
""===============================================""
""Note: Packages names should be string""
""Example 0: Automatically process packages""
| collector result |
collector := HypheReturnsCollectorMethodNodes new.
result := collector processPackages: #(''AI-Algorithms-Graph 'AI-Algorithms-Graph-Components' 'AI-Algorithms-Graph-Tests').

""Inspect results""
result inspect.

""===============================================""
""USAGE EXAMPLES FOR HYPHE RETURNS COLLECTORS""
""===============================================""

""Example 1: Using HypheReturnsCollectorMethodNodes - Simple block execution""
| collector fixture result |
collector := HypheReturnsCollectorMethodNodes new.
fixture := HypheReturnsCollectorTestFixture new.

""Set methods from packages""
collector setMethodsFromPackages: #('Hyphe-Tests').

""Run a block with automatic instrumentation""
result := collector run: [ fixture testSimpleReturn ] instrumentForRecording: true.

""Inspect results""
result isCompleted. ""=> true""
result collections size. ""=> number of collected data items""
result collections first. ""=> HypheReturnDataItem with receiverClass, methodSelector, definingClass, returnClass""


""===============================================""
#('Hyphe-Tests').


""===============================================""
""Example 3: Manual instrumentation (more control)""
| collector testCase result |
collector := HypheReturnsCollectorMethodNodes new.
testCase := HypheReturnsCollectorTestFixture new.

""Set methods from packages""
collector setMethodsFromPackages: #('Hyphe-Tests').

""Manually instrument before running""
collector instrumentForRecording.

""Run without auto-instrumentation (already instrumented)""
result := collector runTest: testCase selector: #testChainedCalls instrumentForRecording: false.

""Manual cleanup.. you probably want to do an Ensure instead""
collector removeInstrumentation.

""Inspect results""
result collections.


""===============================================""
""Example 4: Run multiple tests""
| collector testCase1 testCase2 result |
collector := HypheReturnsCollectorMethodNodes new.

testCase1 := HypheReturnsCollectorTestFixture new.
testCase2 := HypheReturnsCollectorTestFixture new.

""Set methods to record""
collector setMethodsFromPackages: #('Hyphe-Tests').

""Run multiple tests (setTestSelector called internally for each)""
result := collector runMultipleTests: {
    testCase1 -> #testSimpleReturn.
    testCase2 -> #testArithmetic
} instrumentForRecording: true.

""All data collected in one result""
result collections size.


""===============================================""
""Example 5: Run multiple blocks""
| collector fixture result |
collector := HypheReturnsCollectorMethodNodes new.
fixture := HypheReturnsCollectorTestFixture new.

collector setMethodsFromPackages: #('Hyphe-Tests').

result := collector runMultiple: {
    [ fixture testSimpleReturn ].
    [ fixture testArithmetic ].
    [ fixture testWithMessageSends ]
} instrumentForRecording: true.

result collections.


""===============================================""
""Example 6: Reset and reuse collector""
| collector result1 result2 |
collector := HypheReturnsCollectorMethodNodes new.

""First use""
collector setMethodsFromPackages: #('Hyphe-Tests').
result1 := collector run: [ HypheReturnsCollectorTestFixture new testSimpleReturn ] instrumentForRecording: true.

""Reset for new use""
collector reset.

""Second use with different configuration""
collector setMethodsToRecord: { HypheReturnsCollectorTestFixture lookupSelector: #testArithmetic }.
result2 := collector run: [ HypheReturnsCollectorTestFixture new testArithmetic ] instrumentForRecording: true.

result1 collections size.
result2 collections size.


""===============================================""
""Example 7: Filter and analyze collected data""
| collector result methodReturns |
collector := HypheReturnsCollectorMethodNodes new.
collector setMethodsFromPackages: #('Hyphe-Tests').

result := collector run: [ 
    HypheReturnsCollectorTestFixture new testMixedReturnTypes 
] instrumentForRecording: true.

""Find all methods that return strings""
methodReturns := result collections select: [ :item | 
    item returnClass = ByteString 
].

methodReturns do: [ :item |
    Transcript show: 'String returned by: ', item methodSelector printString; cr
].


""===============================================""
""Example 8: Compare collected data across runs""
| collector1 collector2 result1 result2 |
collector1 := HypheReturnsCollectorMethodNodes new.
collector2 := HypheReturnsCollectorMethodNodes new.

collector1 setMethodsFromPackages: #('Hyphe-Tests').
collector2 setMethodsFromPackages: #('Hyphe-Tests').

result1 := collector1 run: [ HypheReturnsCollectorTestFixture new testChainedCalls ] instrumentForRecording: true.
result2 := collector2 run: [ HypheReturnsCollectorTestFixture new testChainedCalls ] instrumentForRecording: true.

""Should collect same methods""
result1 collections size = result2 collections size. ""=> true""


""===============================================""
""Example 9: Inspect data item details""
| collector result dataItem |
collector := HypheReturnsCollectorMethodNodes new.
collector setMethodsFromPackages: #('Hyphe-Tests').

result := collector run: [ HypheReturnsCollectorTestFixture new testSimpleReturn ] instrumentForRecording: true.

dataItem := result collections first.

""All important data captured:""
dataItem receiverClass. ""=> HypheReturnsCollectorTestFixture""
dataItem methodSelector. ""=> #testSimpleReturn""
dataItem definingClass. ""=> HypheReturnsCollectorTestFixture""
dataItem returnClass. ""=> ByteString""


""===============================================""
""Example 10: Error handling""
| collector testCase result |
collector := HypheReturnsCollectorMethodNodes new.
testCase := HypheReturnsCollectorTestFixture new.
testCase setTestSelector: #testThatFails.

collector setMethodsFromPackages: #('Hyphe-Tests').

""Even if test fails, collector handles it gracefully""
result := collector runTest: testCase selector: #testThatFails instrumentForRecording: true.

result hasErrors. ""=> true""
result errorMessage. ""=> error description""
result status. ""=> #error or #testFailure""


```smalltalk

"
Class {
	#name : 'HypheReturnsCollectorMethodNodes',
	#superclass : 'HypheReturnsCollectorBase',
	#instVars : [
		'recordingLinkCache'
	],
	#category : 'Hyphe-Collectors',
	#package : 'Hyphe',
	#tag : 'Collectors'
}

{ #category : 'as yet unclassified' }
HypheReturnsCollectorMethodNodes class >> hypheExporter [

	^ OfflineProfilerResultsExporter
]

{ #category : 'as yet unclassified' }
HypheReturnsCollectorMethodNodes class >> runHypheInference: packageNames [

	| collector rawResult processedForExport results|

	results := OrderedCollection new.
	collector := self new.
	rawResult := (collector processPackages: packageNames) asProcessedResults.
	processedForExport := rawResult copy.
	
	processedForExport dictionary ifNotEmpty: [ 
		|flat|
		flat := processedForExport byPackage values flattened.
		flat do: [:item | item optimizeTypes ].
		processedForExport pruneToSingleType; pruneToTop25p.
		^ results := (flat select: [:item |  (item returnsInfo) isNotEmpty]) collect: [:item | { item package . item receiverClass name . item methodSelector . item returnsInfo first returnClass name }]. 
			]
		  ifEmpty: [ ^ OrderedCollection new ]
	
]

{ #category : 'as yet unclassified' }
HypheReturnsCollectorMethodNodes class >> tier [

	^ #observation
]

{ #category : 'initialization' }
HypheReturnsCollectorMethodNodes >> initialize [
    super initialize.
    recordingLinkCache := nil
]

{ #category : 'instrumentation' }
HypheReturnsCollectorMethodNodes >> instrumentForRecording [
    "Instrument all methodsToRecord by installing metalinks on method nodes"
    logger log: '[INSTRUMENT] Starting instrumentation of ', methodsToRecord size asString, ' methods...'.
    
    methodsToRecord do: [ :method |
        [ 
            self instrumentMethod: method 
        ] on: Error do: [ :ex |
            logger log: '[INSTRUMENT] ERROR instrumenting ', method methodClass name, '>>', method selector, ': ', ex messageText
        ]
    ].
    
    logger log: '[INSTRUMENT] Instrumentation complete. Instrumented ', instrumentedMethods size asString, ' methods'
]

{ #category : 'instrumentation' }
HypheReturnsCollectorMethodNodes >> instrumentMethod: aCompiledMethod [
    "Instrument a method node to capture its return value.
    The link fires when the method returns (after execution)."
    | methodAst methodNode recLink |
    
    "Skip if already instrumented"
    (instrumentedMethods includes: aCompiledMethod) ifTrue: [ ^ self ].
    
    "Skip primitives"
    aCompiledMethod isPrimitive ifTrue: [ 
        instrumentedMethods add: aCompiledMethod.
        ^ self 
    ].
    
    "Skip methods with noInstrumentation pragma"
    (self shouldInstrumentMethod: aCompiledMethod) ifFalse: [
        instrumentedMethods add: aCompiledMethod.
        logger log: '[INSTRUMENT] Skipped (pragma): ', aCompiledMethod methodClass name, '>>', aCompiledMethod selector.
        ^ self
    ].
    
    "Mark as instrumented"
    instrumentedMethods add: aCompiledMethod.
    
    logger log: '[INSTRUMENT] ', aCompiledMethod methodClass name, '>>', aCompiledMethod selector.
    
    [
        "Get AST and method node (root node)"
        methodAst := aCompiledMethod ast.
        methodNode := methodAst.
        
        "Get the recording link"
        recLink := self recordingLink.
        
        "Install link on method node (fires after method execution)"
        (methodNode hasMetalink: recLink)
            ifFalse: [
                methodNode link: recLink.
                logger log: '[INSTRUMENT] Linked method node: ', aCompiledMethod selector
            ]
    ] on: Error do: [ :ex |
        logger log: '[INSTRUMENT] ERROR processing method AST: ', ex messageText.
        instrumentedMethods remove: aCompiledMethod ifAbsent: []
    ]
]

{ #category : 'api-running' }
HypheReturnsCollectorMethodNodes >> processPackages: aCollectionOfPackageNames [
    "Process packages: instrument non-test methods, run all tests, return results.
    This is the main entry point for full package analysis."
    | testCaseClasses nonTestCaseMethods testPairs startTime endTime |
    
    logger log: '[PROCESS] Starting processPackages with ', aCollectionOfPackageNames size asString, ' packages'.
    
    "Reset state"
    self reset.
    
    result status: #running.
    startTime := DateAndTime now.
    owningProcess := Processor activeProcess.
    
    [
        [
            "Step 1: Collect test case classes and non-test case methods"
            testCaseClasses := OrderedCollection new.
            nonTestCaseMethods := OrderedCollection new.
            
            aCollectionOfPackageNames do: [ :packageName |
                | package |
                package := PackageOrganizer default packageNamed: packageName ifAbsent: [ nil ].
                package ifNotNil: [
                    logger log: '[PROCESS] Processing package: ', packageName.
                    package definedClasses do: [ :class |
                        (class isTestCase)
                            ifTrue: [ 
                                "Collect test case class"
                                testCaseClasses add: class.
                                logger log: '[PROCESS] Found test case class: ', class name
                            ]
                            ifFalse: [
                                "Collect non-test case methods (both instance and class side)"
                                class methods do: [ :method | nonTestCaseMethods add: method ].
                                class classSide methods do: [ :method | nonTestCaseMethods add: method ].
                            ]
                    ]
                ] ifNil: [
                    logger log: '[PROCESS] WARNING: Package not found: ', packageName
                ]
            ].
            
            logger log: '[PROCESS] Found ', testCaseClasses size asString, ' test case classes'.
            logger log: '[PROCESS] Found ', nonTestCaseMethods size asString, ' non-test case methods'.
            
            "Step 2: Configure methods to instrument (non-test case methods only)"
            self setMethodsToRecord: nonTestCaseMethods.
            
            "Step 3: Instrument all non-test case methods"
            self instrumentForRecording.
            logger log: '[PROCESS] Instrumented ', instrumentedMethods size asString, ' methods'.
            
            "Step 4: Build list of test pairs (testCase -> selector)"
            testPairs := OrderedCollection new.
            testCaseClasses do: [ :testClass |
                testClass allTestSelectors do: [ :selector |
                    testPairs add: (testClass new -> selector)
                ]
            ].
            logger log: '[PROCESS] Found ', testPairs size asString, ' test cases to run'.
            
            "Step 5: Run all tests (this produces results automatically via instrumentation)"
            testPairs do: [ :pair |
                | testCase selector |
                testCase := pair key.
                selector := pair value.
                
                "Set the test selector"
                testCase setTestSelector: selector.
                
                logger log: '[PROCESS] Running test: ', testCase class name, '>>', selector.
                
                "Use runCaseForHyphe for proper setup/tearDown"
                [ testCase runCaseForHyphe ] 
                    on: Error ,TestFailure , TestSkipped, AssertionFailure
                    do: [ :ex |
                        logger log: '[PROCESS] Test failed/error: ', testCase class name, '>>', selector, ' - ', ex messageText
                    ]
            ].
            
            result status: #completed.
            logger log: '[PROCESS] All tests completed'
        ] on: Error do: [ :ex |
            result status: #error.
            result errorMessage: ex messageText.
            logger log: '[PROCESS] Error during processing: ', ex messageText
        ]
    ] ensure: [
        "Step 6: Cleanup (guaranteed via ensure:)"
        self cleanup.
        endTime := DateAndTime now.
        result executionTime: (endTime - startTime).
        result collections: collectionsData asArray.
        logger log: '[PROCESS] Cleanup completed'
    ].
    
    logger log: '[PROCESS] Collected ', collectionsData size asString, ' data points'.
    ^ result
]

{ #category : 'data collection' }
HypheReturnsCollectorMethodNodes >> recordReturnValue: returnValue inContext: aContext [
    "Record a return value from method node instrumentation.
    aContext provides access to receiver and method.
    Ultra-defensive: catch ALL errors to prevent breaking execution."
    
    "GUARD: If inside instrumentation, skip recording"
    (HypheInstrumentationGuard value = true) ifTrue: [ ^ self ].
    
    "GUARD: Only record in the owning process (if set)"
    (owningProcess notNil and: [ Processor activeProcess ~~ owningProcess ]) ifTrue: [ ^ self ].
    
    HypheInstrumentationGuard value: true during: [
        [
            | methodClass methodSelector receiverClass returnClass dataItem aCompiledMethod receiver |
            
            "Try to extract receiver from context"
            [
                receiver := aContext receiver.
            ] on: Error do: [ :ex |
                receiver := nil.
            ].
            
            "Try to extract the compiled method from context"
            [
                aCompiledMethod := aContext method.
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
                receiver ifNotNil: [
                    receiverClass := receiver class.
                ] ifNil: [
                    "Fallback to method class if no receiver"
                    receiverClass := methodClass.
                ]
            ] on: Error do: [ :ex |
                receiverClass := #UnknownReceiver.
            ].
            
            "Try to get return class"
            [
                returnClass := returnValue class.
            ] on: Error do: [ :ex |
                returnClass := #ErrorGettingReturnType.
            ].
            
            "Create and add data item with ALL required fields"
            dataItem := HypheReturnDataItem new
                methodSelector: methodSelector;
                definingClass: methodClass;
                receiverClass: receiverClass;
                returnClass: returnClass;
                yourself.
            collectionsData add: dataItem.
            
            logger log: '[RECORD] ', receiverClass printString, ' >> ', methodSelector printString, 
                        ' (in ', methodClass printString, ') returns ', returnClass printString.
                        
        ] on: Error do: [ :ex |
            "Ultimate fallback: if ANYTHING fails, silently continue"
            [ 
                Transcript show: '[COLLECTOR] Silent error in recordReturnValue: ', ex messageText; cr.
            ] on: Error do: [ "ignore even this" ]
        ]
    ]
]

{ #category : 'instrumentation' }
HypheReturnsCollectorMethodNodes >> recordingLink [
    "Returns the single recording link for capturing return values from method nodes.
    Uses #after control to capture the return value.
    Uses context to get receiver and method information."
    
    ^ recordingLinkCache ifNil: [
        recordingLinkCache := MetaLink new
            metaObject: self;
            selector: #recordReturnValue:inContext:;
            arguments: #(value context);
            control: #after.
        installedLinks add: recordingLinkCache.
        recordingLinkCache
    ]
]

{ #category : 'instrumentation' }
HypheReturnsCollectorMethodNodes >> removeInstrumentation [
    "Remove all installed metalinks"
    installedLinks do: [ :link | 
        [ link uninstall ] on: Error do: [ :ex | 
            logger log: 'Error uninstalling link: ', ex messageText 
        ]
    ].
    
    installedLinks := HypheInternalCollection new.
    instrumentedMethods := IdentitySet new.
    recordingLinkCache := nil
]

{ #category : 'instrumentation' }
HypheReturnsCollectorMethodNodes >> shouldInstrumentMethod: aCompiledMethod [
    "Check if method has noInstrumentation or optionDisabledLink pragmas"
    ^ (aCompiledMethod hasPragmaNamed: #noInstrumentation) not
        and: [ (aCompiledMethod hasPragmaNamed: #optionDisabledLink) not ]
]
