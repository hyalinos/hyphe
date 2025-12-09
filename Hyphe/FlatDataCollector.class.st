Class {
	#name : 'FlatDataCollector',
	#superclass : 'Object',
	#instVars : [
		'collectedData'
	],
	#category : 'Hyphe-Mycelium',
	#package : 'Hyphe',
	#tag : 'Mycelium'
}

{ #category : 'as yet unclassified' }
FlatDataCollector class >> collect [

	^ (self new collect) collectedData. 
]

{ #category : 'as yet unclassified' }
FlatDataCollector >> collect [ 

	Mycelium mycelium accept: self.
]

{ #category : 'accessing' }
FlatDataCollector >> collectedData [

	^ collectedData
]

{ #category : 'visiting' }
FlatDataCollector >> initialize [

	collectedData :=OrderedCollection new
]

{ #category : 'visiting' }
FlatDataCollector >> visitMethod: m [

	(m collected) accept: self
]

{ #category : 'visiting' }
FlatDataCollector >> visitPackage: p [

	(p classes) do: [:c | c accept: self  ]
	
]
