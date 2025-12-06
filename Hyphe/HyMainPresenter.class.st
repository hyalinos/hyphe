"
Shows menu to choose Hyalinos tools:

	- Run analysis on selected packages
	- Subscribe repositories/packages to infer types when they are changed
	- Show results
"
Class {
	#name : 'HyMainPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'runButton',
		'subscribeButton',
		'viewButton',
		'closeButton'
	],
	#category : 'Hyphe-UI',
	#package : 'Hyphe',
	#tag : 'UI'
}

{ #category : 'layout' }
HyMainPresenter >> close [
	
	self window close
]

{ #category : 'layout' }
HyMainPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  spacing: 10;
		  add: runButton;
		  add: subscribeButton;
		  add: viewButton;
		  add: closeButton;
		  yourself
]

{ #category : 'layout' }
HyMainPresenter >> initializePresenters [

	runButton := self newButton
		             label: 'Run inference';
		             action: [ self runInference ];
		             yourself.

	subscribeButton := self newButton
		                   label: 'Subscribe repositories';
		                   action: [ self subscribePackages ];
		                   yourself.

	viewButton := self newButton
		              label: 'View results';
		              action: [ self viewResults ];
		              yourself.

	closeButton := self newButton
		               label: 'Close';
		               action: [ self close ];
		               yourself
]

{ #category : 'layout' }
HyMainPresenter >> initializeWindow: aWindowPresenter [
	
	aWindowPresenter
		title: 'Hyalinos';
		initialExtent: 300@200
]

{ #category : 'layout' }
HyMainPresenter >> runInference [

	HyInferencePresenter new open.
]

{ #category : 'layout' }
HyMainPresenter >> subscribePackages [

	HyRepositorySubscriptionPresenter new open

	
]

{ #category : 'layout' }
HyMainPresenter >> viewResults [
	
	HyBrowseResults new open.

	
]
