"
class for subscribing repositories to start automatic type inference if a specific action happens

	- Repository created, commited, pulled, pushed.
	- Packages loaded, removed from repository
"
Class {
	#name : 'HyRepositorySubscriptionPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'titleLabel',
		'repositoryList',
		'selectedRepositoryList',
		'addButton',
		'removeButton',
		'clearButton',
		'onActionsLabel',
		'selectAllCheckbox',
		'pullCheckbox',
		'commitCheckbox',
		'pushCheckbox',
		'packageAddedCheckbox',
		'packageRemovedCheckbox',
		'subscribeAllCheckbox',
		'saveButton',
		'cancelButton'
	],
	#category : 'Hyphe-UI',
	#package : 'Hyphe',
	#tag : 'UI'
}

{ #category : 'layout' }
HyRepositorySubscriptionPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: titleLabel expand: false;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 10;
				   add: repositoryList;
				   add: (SpBoxLayout newTopToBottom
						    vAlignCenter;
						    spacing: 5;
						    add: addButton expand: false;
						    add: removeButton expand: false;
						    add: clearButton expand: false;
						    yourself);
				   add: selectedRepositoryList;
				   yourself);
		  add: SpBoxLayout newVertical expand: false;
		  add: onActionsLabel expand: false;
		  add: selectAllCheckbox expand: false;
		  add: SpBoxLayout newVertical expand: false;
		  add: (SpBoxLayout newHorizontal
					add: commitCheckbox expand: false;
				   add: pullCheckbox expand: false;
				   add: pushCheckbox expand: false;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newHorizontal
				   add: packageAddedCheckbox expand: false;
				   add: packageRemovedCheckbox expand: false;
				   yourself)
		  expand: false;
		  add: SpBoxLayout newVertical expand: false;
		  add: subscribeAllCheckbox expand: false;
		  add: SpBoxLayout newVertical expand: false;
		  add: (SpBoxLayout newLeftToRight
				   hAlignCenter;
				   add: saveButton expand: false;
				   add: cancelButton expand: false;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'layout' }
HyRepositorySubscriptionPresenter >> disableActionCheckboxes [

	pullCheckbox enable.
	commitCheckbox enable.
	pushCheckbox enable.
	packageAddedCheckbox enable.
	packageRemovedCheckbox enable
]

{ #category : 'layout' }
HyRepositorySubscriptionPresenter >> enableActionCheckboxes [

	pullCheckbox
		state: true;
		disable.
	commitCheckbox state: true; disable.
	pushCheckbox state: true; disable.
	packageAddedCheckbox state: true; disable.
	packageRemovedCheckbox state: true; disable.
]

{ #category : 'layout' }
HyRepositorySubscriptionPresenter >> initializeDialogWindow: aDialogPresenter [ 
	
	aDialogPresenter
		title: 'Repository Subscription Settings';
		initialExtent: 700@600

]

{ #category : 'layout' }
HyRepositorySubscriptionPresenter >> initializePresenters [
	"Initialize title label"

	titleLabel := self newLabel
		              label: 'Subscribe repositories for automatic type inference';
		              yourself.
	repositoryList := self newList
		                  items: self loadIcebergRepositories;
		                  display: [ :repo | repo name ];
		                  yourself.

	selectedRepositoryList := self newList
		                          display: [ :repo | repo name ];
		                          yourself.
	addButton := self newButton
		             label: 'Add >>';
						action: [ self onAddRepository ];
		             yourself.

	removeButton := self newButton
		                label: '<< Remove';
							 action: [ self onRemoveRepository ];
		                yourself.

	clearButton := self newButton
		               label: 'Clear';
							action: [ self onClearRepositories ];
		               yourself.

	onActionsLabel := self newLabel
		                  label: 'On actions:';
		                  yourself.

	selectAllCheckbox := self newCheckBox
		                     label: 'Select all';
								   whenActivatedDo: [ self enableActionCheckboxes ];
									whenDeactivatedDo: [ self disableActionCheckboxes ];
		                     state: false;
		                     yourself.

	pullCheckbox := self newCheckBox
		                label: 'Git pull';
		                yourself.

	commitCheckbox := self newCheckBox
		                  label: 'Git commit';
		                  yourself.

	pushCheckbox := self newCheckBox
		                label: 'Git push';
		                yourself.

	packageAddedCheckbox := self newCheckBox
		                        label: 'Package added';
		                        yourself.

	packageRemovedCheckbox := self newCheckBox
		                          label: 'Package removed';
		                          yourself.
	subscribeAllCheckbox := self newCheckBox
		                        label: 'Subscribe all future repositories';
		                        yourself.
	saveButton := self newButton
		              label: 'Save';
							action: [ self onSave ];
		              yourself.

	cancelButton := self newButton
		                label: 'Cancel';
							action: [ self onCancel ];
		                yourself
]

{ #category : 'layout' }
HyRepositorySubscriptionPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Repository Subscription Settings';
		initialExtent: 600 @ 400
]

{ #category : 'layout' }
HyRepositorySubscriptionPresenter >> loadIcebergRepositories [ 
	
	^ IceRepository registry


]

{ #category : 'layout' }
HyRepositorySubscriptionPresenter >> onAddRepository [ 
	"Move selected repository from available list to selected list"
	repositoryList selectedItem ifNotNil: [ :repo |
		| currentItems |
		currentItems := selectedRepositoryList items asOrderedCollection.
		(currentItems includes: repo) ifFalse: [
			currentItems add: repo.
			selectedRepositoryList items: currentItems ]
	]

]

{ #category : 'layout' }
HyRepositorySubscriptionPresenter >> onCancel [ 
	"Close the window without saving"
	self window close
]

{ #category : 'layout' }
HyRepositorySubscriptionPresenter >> onClearRepositories [ 
	"Clear all repositories from selected list"
	selectedRepositoryList items: #()

]

{ #category : 'layout' }
HyRepositorySubscriptionPresenter >> onRemoveRepository [ 
	"Remove selected repository from selected list"
	selectedRepositoryList selectedItem ifNotNil: [ :repo |
		| currentItems |
		currentItems := selectedRepositoryList items asOrderedCollection.
		currentItems remove: repo.
		selectedRepositoryList items: currentItems ]
]

{ #category : 'layout' }
HyRepositorySubscriptionPresenter >> onSave [ 
	"Save the configuration and close the window"
	| config |
	config := Dictionary new.
	config at: #repositories put: selectedRepositoryList items.
	config at: #onPull put: pullCheckbox state.
	config at: #onCommit put: commitCheckbox state.
	config at: #onPush put: pushCheckbox state.
	config at: #onPackageAdded put: packageAddedCheckbox state.
	config at: #onPackageRemoved put: packageRemovedCheckbox state.
	config at: #subscribeAllFuture put: subscribeAllCheckbox state.
	
	"Here you would typically save the configuration"
	self inform: 'Configuration saved successfully'.
	self window close
]
