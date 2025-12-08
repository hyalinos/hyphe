"
Presenter for showing and editing numerical confidence range of inference tool
"
Class {
	#name : 'HyConfidenceLevelPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'confidenceData',
		'tableConf',
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
HyConfidenceLevelPresenter class >> openWithData: table [
	
	^ self new
		parentTable: table;
		open
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> cancel [

	self window close
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> confidenceData: data [

	confidenceData := data 
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		add: tableConf;
		add: (SpBoxLayout newLeftToRight
			add: saveButton;
			add: resetButton;
			add: cancelButton;
			yourself)
		expand: false;
		yourself
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> initialize [

	super initialize.
	confidenceData := InferenceSettings inferenceConfidence.
	originalData := InferenceSettings inferenceConfidence.
	tableConf items: confidenceData. 
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> initializePresenters [

	tableConf := self newTable.
	tableConf
		addColumn: (SpStringTableColumn 
			title: 'Min'
			evaluated: [ :item | (item at: 1) asString ])
			beSortable;
		addColumn: (SpStringTableColumn 
			title: 'Max'
			evaluated: [ :item | (item at: 2) asString ])
			beSortable;
		addColumn: (SpStringTableColumn 
			title: 'Level'
			evaluated: [ :item | item at: 3 ]);
		beResizable.
	
	tableConf columns first onAcceptEdition: [ :item :newValue |
		self updateMinValue: item with: newValue ].
	tableConf columns first beEditable.
	
	tableConf columns second onAcceptEdition: [ :item :newValue |
		self updateMaxValue: item with: newValue ].
	tableConf columns second beEditable.
	
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
HyConfidenceLevelPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Confidence level configuration';
		initialExtent: 500 @ 150
]

{ #category : 'accessing' }
HyConfidenceLevelPresenter >> parentTable: anObject [

	parentTable := anObject
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> reset [

	tableConf items: (originalData collect: [ :item | item copy ] as: OrderedCollection).
	self inform: 'Data reset to original values.'
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> save [

	self validateNoOverlaps ifFalse: [
		self inform: 'Cannot save: There are overlapping ranges or invalid values. Please fix the errors first.'.
		^ self
	].

	InferenceSettings inferenceConfidence: (confidenceData collect: [ :item | item copy ] as: OrderedCollection). 
	InferenceSettings recalculate.
	parentTable items: InferenceSettings joinData. 
	self inform: 'Confidence levels saved successfully!'
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> updateMaxValue: item with: newValue [

	[ 
		| numericValue oldValue |
		numericValue := newValue asNumber.
		
		(numericValue < 0.0 or: [ numericValue > 1.0 ]) ifTrue: [
			self inform: 'Max value must be between 0.0 and 1.0'.
			^ self
		].
		
		"Store old value for potential rollback"
		oldValue := item at: 2.
		item at: 2 put: numericValue.
		
		"Validate no overlaps"
		(self validateNoOverlaps) ifFalse: [
			item at: 2 put: oldValue.
			tableConf refresh.
			^ self
		].
		
		tableConf refresh
	] on: Error do: [ 
		self inform: 'Invalid max value. Please enter a numeric value between 0.0 and 1.0.'
	]
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> updateMinValue: item with: newValue [

	[ 
		| numericValue oldValue |
		numericValue := newValue asNumber.

		(numericValue < 0.0 or: [ numericValue > 1.0 ]) ifTrue: [
			self inform: 'Min value must be between 0.0 and 1.0'.
			^ self
		].
		
		"Store old value for potential rollback"
		oldValue := item at: 1.
		item at: 1 put: numericValue.
		
		"Validate no overlaps"
		(self validateNoOverlaps) ifFalse: [
			item at: 1 put: oldValue.
			tableConf refresh.
			^ self
		].
		
		tableConf refresh
	] on: Error do: [ 
		self inform: 'Invalid min value. Please enter a numeric value between 0.0 and 1.0.'
	]
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> validateNoOverlaps [

	| sortedData |"
	Validate that ranges don't overlap and min < max for each item"
	
	"First, check that min < max for each item"
	confidenceData do: [ :item |
		| min max |
		min := (item at: 1) asNumber.
		max := (item at: 2) asNumber.
		(min >= max) ifTrue: [
			self inform: 'Min value must be less than Max value for each level.'.
			^ false
		]
	].
	
	"""Sort by min value to check for overlaps""
	
	sortedData := confidenceData sorted: [ :a :b | (a at: 1) < (b at: 1) ].
	
	""Check that max of one range is less than or equal to min of next range""
	1 to: sortedData size - 1 do: [ :i |
		| currentMax nextMin |
		currentMax := (sortedData at: i) at: 2.
		nextMin := (sortedData at: i + 1) at: 1.
		(currentMax > nextMin) ifTrue: [
			self inform: 'Confidence ranges cannot overlap. Max value in one category must be less than or equal to Min value in the next category.'.
			^ false
		]
	]."
	
	^ true
]
