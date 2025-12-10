"
Organizes the results of collectors and calculates counts and percentages.
Offers a merge functionality, and different views of the data (grouped by method keys, grouped by package, grouped by receiver class)
"
Class {
	#name : 'HypheProcessedReturns',
	#superclass : 'Object',
	#instVars : [
		'dictionary',
		'byPackage',
		'byReceiverClass'
	],
	#category : 'Hyphe-CollectorsProcessing',
	#package : 'Hyphe',
	#tag : 'CollectorsProcessing'
}

{ #category : 'accessing' }
HypheProcessedReturns >> at: aKey [
    ^ dictionary at: aKey
]

{ #category : 'accessing' }
HypheProcessedReturns >> at: aKey ifAbsent: aBlock [
    ^ dictionary at: aKey ifAbsent: aBlock
]

{ #category : 'accessing' }
HypheProcessedReturns >> at: aKey put: aValue [
    dictionary at: aKey put: aValue
]

{ #category : 'private' }
HypheProcessedReturns >> buildByPackageDictionary [
    "Organize items by their package name"
    byPackage := Dictionary new.
    self values do: [ :item |
        item package ifNotNil: [
            byPackage 
                at: item package 
                ifAbsentPut: [ OrderedCollection new ].
            (byPackage at: item package) add: item ] ]
]

{ #category : 'private' }
HypheProcessedReturns >> buildByReceiverClassDictionary [
    "Organize items by their receiver class"
    byReceiverClass := Dictionary new.
    self values do: [ :item |
        | className |
        className := item receiverClass name.
        byReceiverClass 
            at: className 
            ifAbsentPut: [ OrderedCollection new ].
        (byReceiverClass at: className) add: item ]
]

{ #category : 'organizing' }
HypheProcessedReturns >> buildOrganizedViews [
    "Build the byPackage and byReceiverClass dictionaries after processing"
    self resolveAllPackages.
    self buildByPackageDictionary.
    self buildByReceiverClassDictionary
]

{ #category : 'as yet unclassified' }
HypheProcessedReturns >> byMethodKey [
"Keys are string like ReceiverClass>>selector"
^dictionary 
]

{ #category : 'accessing' }
HypheProcessedReturns >> byPackage [
    ^ byPackage
]

{ #category : 'accessing' }
HypheProcessedReturns >> byReceiverClass [
    ^ byReceiverClass
]

{ #category : 'accessing' }
HypheProcessedReturns >> dictionary [
    ^ dictionary
]

{ #category : 'initialization' }
HypheProcessedReturns >> initialize [
    super initialize.
    dictionary := Dictionary new.
    byPackage := Dictionary new.
    byReceiverClass := Dictionary new
]

{ #category : 'accessing' }
HypheProcessedReturns >> keys [
    ^ dictionary keys
]

{ #category : 'merging' }
HypheProcessedReturns >> merge: aHypheProcessedReturns [
    "Merge another HypheProcessedReturns into self, updating counts and recalculating percentages"
    aHypheProcessedReturns keys do: [ :key |
        | incomingItem existingItem |
        incomingItem := aHypheProcessedReturns at: key.
        
        existingItem := self at: key ifAbsent: [ nil ].
        existingItem
            ifNil: [
                "Key doesn't exist, add it as is"
                self at: key put: incomingItem ]
            ifNotNil: [
                "Key exists, merge the returnsInfo"
                self mergeReturnsInfo: incomingItem into: existingItem ] ].
    
    "Rebuild organized views after merging"
    self buildOrganizedViews
]

{ #category : 'private' }
HypheProcessedReturns >> mergeReturnsInfo: incomingItem into: existingItem [
    "Merge returnsInfo from incomingItem into existingItem and recalculate percentages"
    | returnClassCounts totalCount |
    returnClassCounts := Dictionary new.
    
    "Collect counts from existing item"
    existingItem returnsInfo do: [ :ri |
        returnClassCounts 
            at: ri returnClass 
            put: ri count ].
    
    "Add counts from incoming item"
    incomingItem returnsInfo do: [ :ri |
        returnClassCounts 
            at: ri returnClass 
            ifPresent: [ :existingCount | 
                returnClassCounts at: ri returnClass put: existingCount + ri count ]
            ifAbsentPut: [ ri count ] ].
    
    "Calculate total and rebuild returnsInfo with new percentages"
    totalCount := returnClassCounts values sum.
    existingItem returnsInfo: OrderedCollection new.
    
    returnClassCounts keysAndValuesDo: [ :returnClass :count |
        | percentage returnsInfo |
        percentage := count / totalCount asFloat.
        returnsInfo := HypheReturnsInfo new
            returnClass: returnClass
            count: count
            percentage: percentage.
        existingItem addReturnsInfo: returnsInfo ]
]

{ #category : 'private' }
HypheProcessedReturns >> pruneToSingleType [

	
	self byPackage values flattened do: [: item |
		(item returnsInfo size < 2) ifFalse: [ 
			|max|
			max := item returnsInfo detectMax: [ :i | i percentage ].
			item returnsInfo: (OrderedCollection new add: max; yourself)
			 ] 
		  ]
]

{ #category : 'private' }
HypheProcessedReturns >> pruneToTop25p [

	
	|allReturnsItem counts threshhold|
	allReturnsItem := self byPackage values flattened.
	counts := (allReturnsItem collect: [ :item | item returnsInfo first count ]) sorted.
	threshhold := counts at: ((counts size * 0.25) ceiling max: 1).
	allReturnsItem do: [: item |
		(item returnsInfo first count < threshhold ) ifTrue: [ 
			item returnsInfo: (OrderedCollection new)
			] 
		  ]
	
	
]

{ #category : 'private' }
HypheProcessedReturns >> resolveAllPackages [
    "Resolve package for each item in the dictionary"
    self values do: [ :item | item resolvePackage ]
]

{ #category : 'accessing' }
HypheProcessedReturns >> values [
    ^ dictionary values
]
