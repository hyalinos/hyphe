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
	self initializeTableData
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> initializePresenters [

	tableConf := self newTable.
	tableConf
		addColumn: (SpStringTableColumn 
			title: 'Min'
			evaluated: [ :item | item min asString])
			beSortable;
		addColumn: (SpStringTableColumn 
			title: 'Max'
			evaluated: [ :item | item max asString ])
			beSortable;
		addColumn: (SpStringTableColumn 
			title: 'Level'
			evaluated: [ :item | item name ]);
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
HyConfidenceLevelPresenter >> initializeTableData [

	confidenceData := HyConfidenceManager user levels deepCopy.
	tableConf items: confidenceData.
	tableConf refresh
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

	HyConfidenceManager reset.
	confidenceData := HyConfidenceManager user levels deepCopy.
	tableConf items: confidenceData.
	tableConf refresh
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> save [

	(HyConfidenceManager validateNoOverlaps: confidenceData) ifTrue: [
		HyConfidenceManager user updateLevels: confidenceData.
		HyInferenceToolsManager user recalculateConfidenceLevels.
		parentTable refresh.
		self inform: 'Confidence levels saved successfully!'.
		self window close]
	ifFalse: [ 
		self inform: 'Can not save data. Confidence levels are overlapping.'.	
		 ]
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> updateMaxValue: item with: newValue [
 
		| numericValue |

		numericValue := newValue asNumber.
		(self valueInRanges: numericValue) 
		ifTrue: [ 
			item max: numericValue.
			tableConf refresh.
			 ] 
		ifFalse: [ 
			self inform: 'Min value must be between 0.0 and 1.0'.
			 ].
	
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> updateMinValue: item with: newValue [
 
		| numericValue |

		numericValue := newValue asNumber.
		(self valueInRanges: numericValue) 
		ifTrue: [ 
			item min: numericValue.
			tableConf refresh.
			 ] 
		ifFalse: [ 
			self inform: 'Min value must be between 0.0 and 1.0'.
			 ].
	
]

{ #category : 'initialization' }
HyConfidenceLevelPresenter >> valueInRanges: value [
 
	^ (value < 0.0 or: (value > 1.0 )) not
		
]
