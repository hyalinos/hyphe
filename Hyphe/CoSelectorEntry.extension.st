Extension { #name : 'CoSelectorEntry' }

{ #category : '*Hyphe' }
CoSelectorEntry class >> new [
    | object |
    (self == NECSelectorEntry)
        ifTrue: [
            object := HypheNECSelectorEntry basicNew.
            object initialize.
            ^ object ].
    object := self basicNew.
    object initialize.
    ^ object
]
