"
Shows the tools and their corresponding confidence level. Confidence level can be changed.
"
Class {
	#name : 'HyToolsConfidencePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'table',
		'parentTable',
		'saveButton',
		'resetButton',
		'cancelButton'
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

	HyInferenceToolsManager reset. 
	table items: HyInferenceToolsManager user inferenceTools.
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
	table items: HyInferenceToolsManager user inferenceTools. 
]

{ #category : 'initialization' }
HyToolsConfidencePresenter >> initializePresenters [
	
	table := self newTable.
	table
		addColumn: (SpStringTableColumn 
			title: 'Tool Name'
			evaluated: [ :item | item name ]);
		addColumn: (SpStringTableColumn 
			title: 'Confidence Score'
			evaluated: [ :item | (item confidence) asString ])
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

	HyInferenceToolsManager reset. 
	table items: HyInferenceToolsManager user inferenceTools.
	table refresh.
	self inform: 'Data reset to original values.'

]

{ #category : 'initialization' }
HyToolsConfidencePresenter >> save [

	HyInferenceToolsManager user recalculateConfidenceLevels. 
	parentTable items: HyInferenceToolsManager user inferenceTools.
	parentTable refresh. 
	self inform: 'Data saved successfully!'.
	self window close
]

{ #category : 'initialization' }
HyToolsConfidencePresenter >> updateConfidenceScore: item with: newValue [

	item confidence: (newValue asNumber).
	table refresh.
]
