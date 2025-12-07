"
Presenter for showing and editing numerical confidence range of inference tool
"
Class {
	#name : 'HyConfidenceLevelPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'confidenceData',
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
HyConfidenceLevelPresenter class >> openWithData: aCollection [

	"Open the presenter with the provided data"
	<script: 'self openWithData: { 
		Dictionary newFrom: { #min -> 0.0. #max -> 0.3. #level -> ''Low'' }.
		Dictionary newFrom: { #min -> 0.3. #max -> 0.7. #level -> ''Medium'' }.
		Dictionary newFrom: { #min -> 0.7. #max -> 1.0. #level -> ''High'' }
	}'>
	
	^ self new
		confidenceData: aCollection;
		open
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> cancel [

	"Cancel and close the window"
	self window close
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> confidenceData: aCollection [

	"Set the confidence data from outside"
	confidenceData := aCollection asOrderedCollection.
	originalData := aCollection collect: [ :item | item copy ] as: OrderedCollection.
	table items: confidenceData
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> defaultLayout [

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
HyConfidenceLevelPresenter >> initializePresenters [

	confidenceData := OrderedCollection new.
	originalData := OrderedCollection new.
	
	table := self newTable.
	table
		addColumn: (SpStringTableColumn 
			title: 'Min'
			evaluated: [ :item | (item at: #min) asString ])
			beSortable;
		addColumn: (SpStringTableColumn 
			title: 'Max'
			evaluated: [ :item | (item at: #max) asString ])
			beSortable;
		addColumn: (SpStringTableColumn 
			title: 'Level'
			evaluated: [ :item | item at: #level ]);
		beResizable.
	
	"Make min and max columns editable with validation"
	table columns first onAcceptEdition: [ :item :newValue |
		self updateMinValue: item with: newValue ].
	table columns first beEditable.
	
	table columns second onAcceptEdition: [ :item :newValue |
		self updateMaxValue: item with: newValue ].
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
HyConfidenceLevelPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Confidence level configuration';
		initialExtent: 500 @ 150
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> reset [

	"Reset to the original data"
	confidenceData := originalData collect: [ :item | item copy ] as: OrderedCollection.
	table items: confidenceData.
	self inform: 'Data reset to original values.'
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> save [

	"Save the current data if valid"
	self validateNoOverlaps ifFalse: [
		self inform: 'Cannot save: There are overlapping ranges or invalid values. Please fix the errors first.'.
		^ self
	].

	originalData := confidenceData collect: [ :item | item copy ] as: OrderedCollection.
	self inform: 'Confidence levels saved successfully!'
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> updateMaxValue: item with: newValue [

	"Update the max value with validation"
	[ 
		| numericValue oldValue |
		numericValue := newValue asNumber.
		
		"Validate range 0.0-1.0"
		(numericValue < 0.0 or: [ numericValue > 1.0 ]) ifTrue: [
			self inform: 'Max value must be between 0.0 and 1.0'.
			^ self
		].
		
		"Store old value for potential rollback"
		oldValue := item at: #max.
		item at: #max put: numericValue.
		
		"Validate no overlaps"
		(self validateNoOverlaps) ifFalse: [
			item at: #max put: oldValue.
			table refresh.
			^ self
		].
		
		table refresh
	] on: Error do: [ 
		self inform: 'Invalid max value. Please enter a numeric value between 0.0 and 1.0.'
	]
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> updateMinValue: item with: newValue [

	"Update the min value with validation"
	[ 
		| numericValue oldValue |
		numericValue := newValue asNumber.
		
		"Validate range 0.0-1.0"
		(numericValue < 0.0 or: [ numericValue > 1.0 ]) ifTrue: [
			self inform: 'Min value must be between 0.0 and 1.0'.
			^ self
		].
		
		"Store old value for potential rollback"
		oldValue := item at: #min.
		item at: #min put: numericValue.
		
		"Validate no overlaps"
		(self validateNoOverlaps) ifFalse: [
			item at: #min put: oldValue.
			table refresh.
			^ self
		].
		
		table refresh
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
		min := item at: #min.
		max := item at: #max.
		(min >= max) ifTrue: [
			self inform: 'Min value must be less than Max value for each level.'.
			^ false
		]
	].
	
	"Sort by min value to check for overlaps"
	
	sortedData := confidenceData sorted: [ :a :b | (a at: #min) < (b at: #min) ].
	
	"Check that max of one range is less than or equal to min of next range"
	1 to: sortedData size - 1 do: [ :i |
		| currentMax nextMin |
		currentMax := (sortedData at: i) at: #max.
		nextMin := (sortedData at: i + 1) at: #min.
		(currentMax > nextMin) ifTrue: [
			self inform: 'Confidence ranges cannot overlap. Max value in one category must be less than or equal to Min value in the next category.'.
			^ false
		]
	].
	
	^ true
]
