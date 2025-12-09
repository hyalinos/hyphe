"
Show Hyalinos inference tools and settings

	- Choose inference scope
	- Choose tools
"
Class {
	#name : 'HyInferencePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'packageList',
		'selectedPackageList',
		'addButton',
		'removeButton',
		'clearButton',
		'toolsTable',
		'selectedTools',
		'selectAllCheckbox',
		'changeScoreButton',
		'changeLevelButton',
		'restoreDefaultButton',
		'runButton',
		'cancelButton',
		'toolsData',
		'strategyLabel',
		'strategy',
		'strategyDropList',
		'restoreButton'
	],
	#category : 'Hyphe-UI',
	#package : 'Hyphe',
	#tag : 'UI'
}

{ #category : 'initialization' }
HyInferencePresenter >> addSelectedPackages [ 
	
	| selected current |
	selected := packageList selection selectedItems.
	current := selectedPackageList items asOrderedCollection.
	
	selected do: [ :pkg |
		(current includes: pkg) ifFalse: [ current add: pkg ] ].
	
	selectedPackageList items: current

]

{ #category : 'initialization' }
HyInferencePresenter >> applyCurrentStrategy [

	| current |
	current := InferenceSettings mergeStrategy ifNil: [
		           InferenceSettings defaultMergeStrategy ].

	strategy := current.
	strategyLabel label: 'Merge strategy: ' , current prettyName.

	(strategyDropList items includes: current) ifTrue: [
		strategyDropList selectItem: current ]
]

{ #category : 'initialization' }
HyInferencePresenter >> changeLevel [
	
	HyConfidenceLevelPresenter openWithData: toolsTable
]

{ #category : 'initialization' }
HyInferencePresenter >> changeScore [

	HyToolsConfidencePresenter openWithData: toolsTable.
]

{ #category : 'initialization' }
HyInferencePresenter >> clearSelectedPackages [ 
	
	selectedPackageList items: OrderedCollection new

]

{ #category : 'initialization' }
HyInferencePresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: 'Scope:' expand: false;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 10;
				   add: packageList;
				   add: (SpBoxLayout newTopToBottom
						    vAlignCenter;
						    spacing: 5;
						    add: #addButton expand: false;
						    add: #removeButton expand: false;
						    add: #clearButton expand: false;
						    yourself);
				   add: selectedPackageList;
				   yourself);
		  add: '     ' expand: false;
		  add: '     ' expand: false;
		  add: 'Select tools:' expand: false;
		  add: toolsTable height: 150;
		  add: selectAllCheckbox expand: false;
		  add: (SpBoxLayout newHorizontal
				   add: changeScoreButton;
				   add: changeLevelButton;
				   add: restoreDefaultButton;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newTopToBottom 
				  add: '     ' expand: false;
		        add: '     ' expand: false;
		        add: #strategyLabel;
		        add: '     ' expand: false;
		        add: 'Choose other strategy     :' expand: false;
		        add: (SpBoxLayout newLeftToRight
				   add: #strategyDropList;
				   add: #restoreButton;
				   yourself)
		  expand: false;
				   yourself);
		   add: (SpBoxLayout newTopToBottom
		        add: '     ' expand: false;
		        add: '     ' expand: false;
		   		  add: (SpBoxLayout newHorizontal
				   hAlignCenter;
				   spacing: 10;
				   add: runButton;
				   add: cancelButton;
				   yourself)
		  expand: false;
		  yourself)
]

{ #category : 'initialization' }
HyInferencePresenter >> disableAllToolsSelected [

	toolsTable unselectAll
]

{ #category : 'initialization' }
HyInferencePresenter >> enableAllToolsSelected [

	toolsTable selectAll.

]

{ #category : 'initialization' }
HyInferencePresenter >> getAllPackages [

	^ PackageOrganizer default packages
]

{ #category : 'initialization' }
HyInferencePresenter >> initialize [

	super initialize.
	self initializeToolsData. 
	self updateToolsTable.
]

{ #category : 'initialization' }
HyInferencePresenter >> initializePresenters [

	packageList := self newList.
	packageList
		items: (self getAllPackages sorted: [ :a :b | a name <= b name ]);
		beMultipleSelection;
		display: [ :pkg | pkg name ].

	selectedPackageList := self newList.
	selectedPackageList
		beMultipleSelection;
		display: [ :pkg | pkg name ].

	addButton := self newButton.
	addButton
		label: 'Add >>';
		action: [ self addSelectedPackages ].

	removeButton := self newButton.
	removeButton
		label: '<< Remove';
		action: [ self removeSelectedPackages ].

	clearButton := self newButton.
	clearButton
		label: 'Clear';
		action: [ self clearSelectedPackages ].

	toolsTable := self newTable.
	toolsTable
		addColumn: (SpStringTableColumn new
				 title: 'Name';
				 evaluated: [ :item | item at: 1 ];
				 yourself);
		addColumn: (SpStringTableColumn new
				 title: 'Confidence score';
				 evaluated: [ :item | (item at: 2) asString ];
				 yourself);
		addColumn: (SpStringTableColumn new
				 title: 'Level';
				 evaluated: [ :item | item at: 3 ];
				 yourself);
		beMultipleSelection.
	toolsTable items: toolsData.

	selectAllCheckbox := self newCheckBox.
	selectAllCheckbox
		label: 'Select all tools';
		state: false;
		whenActivatedDo: [ self enableAllToolsSelected ];
		whenDeactivatedDo: [ self disableAllToolsSelected ].


	changeScoreButton := self newButton.
	changeScoreButton
		label: 'Change score';
		action: [ self changeScore ].

	changeLevelButton := self newButton.
	changeLevelButton
		label: 'Change level';
		action: [ self changeLevel ].

	restoreDefaultButton := self newButton.
	restoreDefaultButton
		label: 'Restore to default';
		action: [ self restoreToDefault ].

	runButton := self newButton.
	runButton
		label: 'Run';
		action: [ self runInference ].

	cancelButton := self newButton.
	cancelButton
		label: 'Cancel';
		action: [ self delete ].

	strategyLabel := self newLabel.
	strategyDropList := self newDropList.
	restoreButton := self newButton.

	"Configure the drop list with the strategies from the model"
	strategyDropList
		items: ((InferenceSettings mergeStrategies) collect: [:s | s prettyName ]);
		whenSelectionChangedDo: [ :selection | 
				| newStrategy |
				newStrategy := selection selectedItem model.
				newStrategy ifNotNil: [ self strategyChangedTo: newStrategy ] ].

	"Configure the restore button"
	restoreButton
		label: 'Restore to default';
		action: [ self restoreDefaultStrategy ].

	"Initialize UI from model"
	self applyCurrentStrategy
]

{ #category : 'initialization' }
HyInferencePresenter >> initializeToolsData [ 

	toolsData := InferenceSettings joinData.
]

{ #category : 'initialization' }
HyInferencePresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Scope and Tools Configuration';
		initialExtent: 550 @ 600
]

{ #category : 'initialization' }
HyInferencePresenter >> onSelectAllChanged: state [

	state
		ifTrue: [
				toolsTable selectAll.]
		ifFalse: [ toolsTable unselectAll ]
]

{ #category : 'initialization' }
HyInferencePresenter >> removeSelectedPackages [ 
	
	| selected current |
	selected := selectedPackageList selection selectedItems.
	current := selectedPackageList items asOrderedCollection.
	
	selected do: [ :pkg | current remove: pkg ifAbsent: [ ] ].
	
	selectedPackageList items: current

]

{ #category : 'initialization' }
HyInferencePresenter >> restoreDefaultStrategy [
 
    self strategyChangedTo: InferenceSettings defaultMergeStrategy.
]

{ #category : 'initialization' }
HyInferencePresenter >> restoreToDefault [ 

	InferenceSettings restoreDefault.
	self initializeToolsData.
	self updateToolsTable

]

{ #category : 'initialization' }
HyInferencePresenter >> runInference [

	| selectedPkgs results |
	selectedPkgs := selectedPackageList items.
	selectedTools := (toolsTable selectedItems collect: [ :t | t at: 1 ])
		                 collect: [ :t |
		                 InferenceSettings toolNameToClass at: t ].

	selectedPkgs ifEmpty: [
		^ self inform: 'Please select at least one package' ].
	selectedTools ifEmpty: [
		^ self inform: 'Please select at least one tool' ].

	self inform: 'Running analysis on ' , selectedPkgs size asString
		, ' package(s) with ' , selectedTools size asString , ' tool(s)'.
	 
	results := (InferenceExecutor
		            executeWithPackages: selectedPkgs
		            tools: selectedTools
		            mergeStrategy: strategy) flattened flatCollect: [ :d |
		           d results ].
	Mycelium addResults: results.

	HyBrowseResults openWithData: results.
	self delete
]

{ #category : 'initialization' }
HyInferencePresenter >> strategyChangedTo: aStrategy [

	aStrategy isClass
		ifTrue: [
				strategyLabel label: 'Merge strategy: ' , aStrategy prettyName.
				strategy = aStrategy]
		ifFalse: [
				strategy := InferenceSettings getStrategyByName: aStrategy.  
				strategyLabel label: 'Merge strategy: ' , aStrategy ]
]

{ #category : 'initialization' }
HyInferencePresenter >> updateToolsTable [ 
	
	toolsTable items: toolsData
]
