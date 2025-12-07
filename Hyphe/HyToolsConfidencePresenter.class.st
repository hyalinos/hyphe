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
		'originalData'
	],
	#category : 'Hyphe-UI',
	#package : 'Hyphe',
	#tag : 'UI'
}

{ #category : 'as yet unclassified' }
HyToolsConfidencePresenter class >> openWithData: aCollection [

	^ self new
		toolsData: aCollection;
		open
]

{ #category : 'initialization' }
HyToolsConfidencePresenter >> cancel [

	"Cancel and close the window"
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
HyToolsConfidencePresenter >> initializePresenters [

	toolsData := OrderedCollection new.
	originalData := OrderedCollection new.
	
	table := self newTable.
	table
		addColumn: (SpStringTableColumn 
			title: 'Tool Name'
			evaluated: [ :item | item at: #name ]);
		addColumn: (SpStringTableColumn 
			title: 'Confidence Score'
			evaluated: [ :item | (item at: #confidence) asString ])
			beSortable;
		beResizable.
	
	"Make the confidence score column editable"
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
HyToolsConfidencePresenter >> reset [

	"Reset to the original data"
	toolsData := originalData collect: [ :item | item copy ] as: OrderedCollection.
	table items: toolsData.
	self inform: 'Data reset to original values.'

]

{ #category : 'initialization' }
HyToolsConfidencePresenter >> save [

	"Save the current data - update originalData to match current state"
	originalData := toolsData collect: [ :item | item copy ] as: OrderedCollection.
	self inform: 'Data saved successfully!'
]

{ #category : 'initialization' }
HyToolsConfidencePresenter >> toolsData: aCollection [

	toolsData := aCollection asOrderedCollection.
	originalData := aCollection collect: [ :item | item copy ] as: OrderedCollection.
	table items: toolsData

]

{ #category : 'initialization' }
HyToolsConfidencePresenter >> updateConfidenceScore: item with: newValue [

	[ 
		| numericValue |
		numericValue := newValue asNumber.
		item at: #confidence put: numericValue.
		table refresh
	] on: Error do: [ 
		self inform: 'Invalid confidence score. Please enter a numeric value.'
	]
]
