Class {
	#name : 'StaticInferencePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'scopeLabel',
		'allPackagesRadio',
		'selectedPackagesRadio',
		'toolsLabel',
		'chooseButton',
		'toolsList',
		'saveResultsCheckbox',
		'resultsPathInput',
		'runButton',
		'cancelButton',
		'allPackagesList',
		'selectedPackagesList',
		'addButton',
		'removeButton',
		'clearButton'
	],
	#category : 'Hyphe-UI',
	#package : 'Hyphe',
	#tag : 'UI'
}

{ #category : 'initialization' }
StaticInferencePresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		spacing: 5;
		add: (SpBoxLayout newTopToBottom
			add: scopeLabel expand: false;
			add: allPackagesRadio expand: false;
			add: selectedPackagesRadio expand: false;
			add: (SpBoxLayout newLeftToRight
				spacing: 5;
				add: allPackagesList;
				add: (SpBoxLayout newTopToBottom
					spacing: 5;
					add: addButton expand: false;
					add: removeButton expand: false;
					add: clearButton expand: false;
					addLast: (SpNullPresenter new) expand: true;
					yourself) expand: false;
				add: selectedPackagesList;
				yourself);
			yourself);
		add: (SpBoxLayout newTopToBottom
			add: toolsLabel expand: false;
			add: chooseButton expand: false;
			add: toolsList;
			yourself);
		add: (SpBoxLayout newTopToBottom
			add: saveResultsCheckbox expand: false;
			add: resultsPathInput expand: false;
			yourself) expand: false;
		add: (SpBoxLayout newLeftToRight
			add: runButton;
			add: cancelButton;
			yourself) expand: false;
		yourself
]

{ #category : 'as yet unclassified' }
StaticInferencePresenter >> disablePackageSelection [

	"Disable the package selection group"
	allPackagesList enabled: false.
	selectedPackagesList enabled: false.
	addButton enabled: false.
	removeButton enabled: false.
	clearButton enabled: false
]

{ #category : 'initialization' }
StaticInferencePresenter >> enablePackageSelection [

	"Enable the package selection group"
	allPackagesList enabled: true.
	selectedPackagesList enabled: true.
	addButton enabled: true.
	removeButton enabled: true.
	clearButton enabled: true
]

{ #category : 'initialization' }
StaticInferencePresenter >> getAllPackageNames [

	"Get all package names sorted alphabetically"
	^ (PackageOrganizer default packages 
		collect: [ :pkg | pkg name ]) sorted
]

{ #category : 'initialization' }
StaticInferencePresenter >> initializePresenters [

	"Initialize the scope section"
	scopeLabel := self newLabel.
	scopeLabel label: 'Scope:'.
	
	allPackagesRadio := self newRadioButton.
	allPackagesRadio label: 'All packages'.
	allPackagesRadio state: true.
	
	selectedPackagesRadio := self newRadioButton.
	selectedPackagesRadio label: 'Selected packages'.
	selectedPackagesRadio state: false.
	selectedPackagesRadio associatedRadioButtons: { allPackagesRadio }.
	
	"Initialize package selection group"
	allPackagesList := self newList.
	allPackagesList items: self getAllPackageNames.
	allPackagesList beMultipleSelection.
	
	selectedPackagesList := self newList.
	selectedPackagesList items: #().
	selectedPackagesList beMultipleSelection.
	
	addButton := self newButton.
	addButton label: 'Add >>'.
	addButton action: [ self onAddPackages ].
	
	removeButton := self newButton.
	removeButton label: '<< Remove'.
	removeButton action: [ self onRemovePackages ].
	
	clearButton := self newButton.
	clearButton label: 'Clear'.
	clearButton action: [ self onClearPackages ].
	
	"Disable package selection group by default"
	self disablePackageSelection.
	
	"Set up radio button actions to enable/disable package selection"
	allPackagesRadio whenActivatedDo: [ self disablePackageSelection ].
	selectedPackagesRadio whenActivatedDo: [ self enablePackageSelection ].
	
	"Initialize the tools section"
	toolsLabel := self newLabel.
	toolsLabel label: 'Tools:'.
	
	chooseButton := self newButton.
	chooseButton label: 'Choose'.
	chooseButton action: [ self onChooseTools ].
	
	toolsList := self newList.
	toolsList items: #().
	
	"Initialize save results section"
	saveResultsCheckbox := self newCheckBox.
	saveResultsCheckbox label: 'Save results'.
	
	resultsPathInput := self newTextInput.
	resultsPathInput placeholder: 'Enter file path...'.
	resultsPathInput enabled: false.
	saveResultsCheckbox whenActivatedDo: [ resultsPathInput enabled: true ].
	saveResultsCheckbox whenDeactivatedDo: [ resultsPathInput enabled: false ].
	
	"Initialize action buttons"
	runButton := self newButton.
	runButton label: 'Run'.
	runButton action: [ self onRun ].
	
	cancelButton := self newButton.
	cancelButton label: 'Cancel'.
	cancelButton action: [ self onCancel ]
]

{ #category : 'initialization' }
StaticInferencePresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Analysis';
		initialExtent: 600@650
]

{ #category : 'initialization' }
StaticInferencePresenter >> onAddPackages [

	"Add selected packages from all packages list to selected packages list"
	| selected current |
	selected := allPackagesList selectedItems.
	selected ifEmpty: [ ^ self ].
	
	current := selectedPackagesList items asOrderedCollection.
	selected do: [ :pkg |
		(current includes: pkg) ifFalse: [ current add: pkg ] ].
	
	selectedPackagesList items: current sorted
]

{ #category : 'initialization' }
StaticInferencePresenter >> onCancel [

	"Handle Cancel button click"
	self window close
]

{ #category : 'initialization' }
StaticInferencePresenter >> onChooseTools [

"Handle choose button click - open a dialog to select tools"
	| selectedTools |
	selectedTools := self selectTools.
	selectedTools ifNotNil: [ 
		toolsList items: selectedTools ]
]

{ #category : 'initialization' }
StaticInferencePresenter >> onClearPackages [

	"Clear all selected packages"
	selectedPackagesList items: #()
]

{ #category : 'initialization' }
StaticInferencePresenter >> onRemovePackages [

	"Remove selected packages from the selected packages list"
	| toRemove current |
	toRemove := selectedPackagesList selectedItems.
	toRemove ifEmpty: [ ^ self ].
	
	current := selectedPackagesList items asOrderedCollection.
	toRemove do: [ :pkg | current remove: pkg ifAbsent: [ ] ].
	
	selectedPackagesList items: current
]

{ #category : 'initialization' }
StaticInferencePresenter >> onRun [

	| scope selectedTools savePath packages |
	
	scope := allPackagesRadio state 
		ifTrue: [ #allPackages ]
		ifFalse: [ #selectedPackages ].
	
	packages := allPackagesRadio state
		ifTrue: [ 'All packages' ]
		ifFalse: [ selectedPackagesList items ].
	
	selectedTools := toolsList items.
	
	savePath := saveResultsCheckbox state
		ifTrue: [ resultsPathInput text ]
		ifFalse: [ nil ].
	
	self inform: 'Running analysis...' , String cr ,
		'Scope: ' , scope asString , String cr ,
		'Packages: ' , packages asString , String cr ,
		'Tools: ' , selectedTools asString , String cr ,
		'Save path: ' , savePath asString.
]

{ #category : 'initialization' }
StaticInferencePresenter >> selectTools [

	"Open a dialog to select tools - customize this based on your needs"
	^ UIManager default 
		chooseFrom: #('Tool 1' 'Tool 2' 'Tool 3' 'Tool 4') 
		values: #('Tool 1' 'Tool 2' 'Tool 3' 'Tool 4')
		title: 'Select Tools'
]
