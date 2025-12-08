"
Shows the tools and their corresponding confidence level. Confidence level can be changed.
"
Class {
	#name : 'HyToolsConfidencePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'toolsData',
		'table',
		'saveButton',
		'resetButton',
		'cancelButton',
		'originalData',
		'parentTable'
	],
	#category : 'Hyphe-UI',
	#package : 'Hyphe',
	#tag : 'UI'
}

{ #category : 'as yet unclassified' }
HyToolsConfidencePresenter class >> openWithData: aTable [

	^ self new
		parentTable: aTable;
		open
]

{ #category : 'initialization' }
HyToolsConfidencePresenter >> cancel [

	self window close
]

{ #category : 'initialization' }
HyToolsConfidencePresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		add: table;
		add: (SpBoxLayout newLeftToRight
			add: saveButton;
			add: resetButton;
			add: cancelButton;
			yourself)
		expand: false;
		yourself
]

{ #category : 'initialization' }
HyToolsConfidencePresenter >> initialize [

	super initialize.
	toolsData := InferenceSettings inferenceTools.
	originalData := InferenceSettings inferenceTools.
	table items: toolsData. 
]

{ #category : 'initialization' }
HyToolsConfidencePresenter >> initializePresenters [
	
	table := self newTable.
	table
		addColumn: (SpStringTableColumn 
			title: 'Tool Name'
			evaluated: [ :item | item first ]);
		addColumn: (SpStringTableColumn 
			title: 'Confidence Score'
			evaluated: [ :item | (item last) asString ])
			beSortable;
		beResizable.
	
	table columns second onAcceptEdition: [ :item :newValue |
		self updateConfidenceScore: item with: newValue ].
	table columns second beEditable.
	
	saveButton := self newButton
		label: 'Save';
		action: [ self save ];
		yourself.
	
	resetButton := self newButton
		label: 'Reset';
		action: [ self reset ];
		yourself.
	
	cancelButton := self newButton
		label: 'Cancel';
		action: [ self cancel ];
		yourself
]

{ #category : 'initialization' }
HyToolsConfidencePresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Tools Confidence Editor';
		initialExtent: 300 @ 200
]

{ #category : 'initialization' }
HyToolsConfidencePresenter >> parentTable: aTable [

	parentTable := aTable 
]

{ #category : 'initialization' }
HyToolsConfidencePresenter >> reset [

	table items: (originalData collect: [ :item | item copy ] as: OrderedCollection).
	self inform: 'Data reset to original values.'

]

{ #category : 'initialization' }
HyToolsConfidencePresenter >> save [

	InferenceSettings inferenceTools: (toolsData collect: [ :item | item copy ] as: OrderedCollection). 
	InferenceSettings recalculate.
	parentTable items: InferenceSettings joinData. 
	self inform: 'Data saved successfully!'
]

{ #category : 'accessing' }
HyToolsConfidencePresenter >> toolsData: aCollection [ 
	toolsData := aCollection
]

{ #category : 'initialization' }
HyToolsConfidencePresenter >> updateConfidenceScore: item with: newValue [

[ 
	item at: 2 put: (newValue asNumber).
	table refresh
] on: Error do: [ 
	self inform: 'Invalid confidence score. Please enter a numeric value.'
]
]
