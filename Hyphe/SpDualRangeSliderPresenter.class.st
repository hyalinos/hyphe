Class {
	#name : 'SpDualRangeSliderPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'lowThreshold',
		'highThreshold',
		'canvas',
		'saveButton',
		'resetButton',
		'cancelButton',
		'lowLabel',
		'mediumLabel',
		'highLabel',
		'saveAction',
		'initialLowThreshold',
		'initialHighThreshold'
	],
	#category : 'Hyphe-UI',
	#package : 'Hyphe',
	#tag : 'UI'
}

{ #category : 'styling' }
SpDualRangeSliderPresenter class >> styleSheet [
    ^ SpStyle defaultStyleSheet, (SpStyleVariableSTONReader fromString: '
.application [
    .redText [ Draw { #color: #red } ],
    .orangeText [ Draw { #color: #orange } ],
    .greenText [ Draw { #color: #green } ]
]')
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> buildSliderOn: view [

	| lowHandle highHandle lowSegment mediumSegment highSegment lowValueLabel highValueLabel padding sliderY leftBorderLabel rightBorderLabel canvasWidth |
	padding := 0.
	sliderY := 0.
	canvasWidth := view canvas extent x. "You can adjust this"

	"Create border labels (0 and 1)"
	leftBorderLabel := RSLabel new
		                   text: '0';
		                   color: Color black;
		                   fontSize: 12;
		                   position: padding @ (sliderY - 20);
		                   yourself.

	rightBorderLabel := RSLabel new
		                    text: '1';
		                    color: Color black;
		                    fontSize: 12;
		                    position: canvasWidth - padding @ (sliderY - 20);
		                    yourself.

	"Create the line segments"
	lowSegment := RSLine new
		              startPoint: padding @ sliderY;
		              endPoint: (self
				               xPositionFor: lowThreshold
				               withPadding: padding
				               canvasWidth: canvasWidth) @ sliderY;
		              color: Color red;
		              width: 4;
		              yourself.

	mediumSegment := RSLine new
		                 startPoint: (self
				                  xPositionFor: lowThreshold
				                  withPadding: padding
				                  canvasWidth: canvasWidth) @ sliderY;
		                 endPoint: (self
				                  xPositionFor: highThreshold
				                  withPadding: padding
				                  canvasWidth: canvasWidth) @ sliderY;
		                 color: Color orange;
		                 width: 4;
		                 yourself.

	highSegment := RSLine new
		               startPoint: (self
				                xPositionFor: highThreshold
				                withPadding: padding
				                canvasWidth: canvasWidth) @ sliderY;
		               endPoint: canvasWidth - padding @ sliderY;
		               color: Color green;
		               width: 4;
		               yourself.

	"Create handles (dots)"
	lowHandle := RSEllipse new
		             size: 16;
		             color: Color red darker;
		             border: (RSBorder new
				              color: Color white;
				              width: 2);
		             position: (self
				              xPositionFor: lowThreshold
				              withPadding: padding
				              canvasWidth: canvasWidth) @ sliderY;
		             yourself.

	highHandle := RSEllipse new
		              size: 16;
		              color: Color green darker;
		              border: (RSBorder new
				               color: Color white;
				               width: 2);
		              position: (self
				               xPositionFor: highThreshold
				               withPadding: padding
				               canvasWidth: canvasWidth) @ sliderY;
		              yourself.

	"Create value labels with 2 decimal places"
	lowValueLabel := RSLabel new
		                 text: (lowThreshold printShowingDecimalPlaces: 2);
		                 color: Color black;
		                 fontSize: 11;
		                 position: (self
				                  xPositionFor: lowThreshold
				                  withPadding: padding
				                  canvasWidth: canvasWidth) @ (sliderY + 20);
		                 yourself.

	highValueLabel := RSLabel new
		                  text: (highThreshold printShowingDecimalPlaces: 2);
		                  color: Color black;
		                  fontSize: 11;
		                  position: (self
				                   xPositionFor: highThreshold
				                   withPadding: padding
				                   canvasWidth: canvasWidth) @ (sliderY + 20);
		                  yourself.

	"Add dragging interaction to low handle"
	lowHandle @ RSDraggable.
	lowHandle
		when: RSPositionChangedEvent
		do: [ :evt |
				| newX newValue maxX |
				maxX := self
					        xPositionFor: highThreshold
					        withPadding: padding
					        canvasWidth: canvasWidth.
				newX := (evt shape position x max: padding) min: maxX.
				newValue := self
					            valueForX: newX
					            withPadding: padding
					            canvasWidth: canvasWidth.

				lowThreshold := newValue.
				evt shape position: newX @ sliderY.
				lowValueLabel position: newX @ (sliderY + 20).
				lowValueLabel text: (lowThreshold printShowingDecimalPlaces: 2).

				"Update line segments"
				lowSegment endPoint: newX @ sliderY.
				mediumSegment startPoint: newX @ sliderY.

				view signalUpdate ]
		for: self.

	"Add dragging interaction to high handle"
	highHandle @ RSDraggable.
	highHandle
		when: RSPositionChangedEvent
		do: [ :evt |
				| newX newValue minX maxX |
				minX := self
					        xPositionFor: lowThreshold
					        withPadding: padding
					        canvasWidth: canvasWidth.
				maxX := canvasWidth - padding.
				newX := (evt shape position x max: minX) min: maxX.
				newValue := self
					            valueForX: newX
					            withPadding: padding
					            canvasWidth: canvasWidth.

				highThreshold := newValue.
				evt shape position: newX @ sliderY.
				highValueLabel position: newX @ (sliderY + 20).
				highValueLabel text: (highThreshold printShowingDecimalPlaces: 2).

				"Update line segments"
				mediumSegment endPoint: newX @ sliderY.
				highSegment startPoint: newX @ sliderY.

				view signalUpdate ]
		for: self.

	"Add all elements to canvas"
	view addAll: {
			leftBorderLabel.
			rightBorderLabel.
			lowSegment.
			mediumSegment.
			highSegment.
			lowHandle.
			highHandle.
			lowValueLabel.
			highValueLabel }

	"view @ RSCanvasController"
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> cancel [
    self window ifNotNil: [ :w | w close ]
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> canvasWidth [
    ^ 400
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> defaultLayout [
    ^ SpBoxLayout newTopToBottom
        spacing: 10;
        add: (SpBoxLayout newLeftToRight
            add: lowLabel;
            add: mediumLabel;
            add: highLabel;
            yourself) expand: false;
        add: canvas height: 60;
        add: (SpBoxLayout newLeftToRight
            add: saveButton;
            add: resetButton;
            add: cancelButton;
            yourself) expand: false;
        yourself
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> highThreshold [
    ^ highThreshold

]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> highThreshold: aNumber [
    highThreshold := aNumber.
    initialHighThreshold := aNumber

]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> initialize [
    super initialize.
    lowThreshold := 0.3.
    highThreshold := 0.7.
    initialLowThreshold := lowThreshold.
    initialHighThreshold := highThreshold
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> initializeButtons [
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
SpDualRangeSliderPresenter >> initializeCanvas [
    canvas := self instantiate: SpRoassalPresenter.
    canvas script: [ :view | self buildSliderOn: view ]
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> initializeLabels [
    lowLabel := self newLabel
        label: 'Low';
        color: Color red;
        yourself.
    
    mediumLabel := self newLabel
        label: 'Medium';
        color: Color orange;
        yourself.
    
    highLabel := self newLabel
        label: 'High';
        color: Color green;
        yourself
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> initializePresenters [
    self initializeLabels.
    self initializeCanvas.
    self initializeButtons
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Confidence Levels Editor';
		initialExtent: 400 @ 200
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> lowThreshold [
    ^ lowThreshold
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> lowThreshold: aNumber [
    lowThreshold := aNumber.
    initialLowThreshold := aNumber
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> onSave: aBlock [
    "Set the action to perform when Save is clicked.
    The block should accept two arguments: lowThreshold and highThreshold"
    saveAction := aBlock
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> reset [
    lowThreshold := initialLowThreshold.
    highThreshold := initialHighThreshold.
    canvas script: [ :view | self buildSliderOn: view ].
    canvas refresh
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> save [
    initialLowThreshold := lowThreshold.
    initialHighThreshold := highThreshold.
    saveAction ifNotNil: [ saveAction cull: lowThreshold cull: highThreshold ].
    self window ifNotNil: [ :w | w close ]
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> valueForX: xPosition withPadding: padding [
    | width value |
    width := self canvasWidth - (2 * padding).
    value := (xPosition - padding) / width.
    ^ (value max: 0.0) min: 1.0
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> valueForX: xPosition withPadding: padding canvasWidth: canvasWidth [
    | width value |
    width := canvasWidth - (2 * padding).
    value := (xPosition - padding) / width.
    ^ (value max: 0.0) min: 1.0
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> xPositionFor: value withPadding: padding [
    | width |
    width := self canvasWidth - (2 * padding).
    ^ padding + (value * width)
]

{ #category : 'initialization' }
SpDualRangeSliderPresenter >> xPositionFor: value withPadding: padding canvasWidth: canvasWidth [
    | width |
    width := canvasWidth - (2 * padding).
    ^ padding + (value * width)
]
