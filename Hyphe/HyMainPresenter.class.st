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
		label: 'Subscribe packages';
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
	"Action for Run inference button"
]

{ #category : 'layout' }
HyMainPresenter >> subscribePackages [
	"Action for Subscribe packages button"
]

{ #category : 'layout' }
HyMainPresenter >> viewResults [
	"Action for View results button"
]
