Extension { #name : 'CoInstVarEntry' }

{ #category : '*Hyphe' }
CoInstVarEntry class >> new [
    | object |
    (self == NECInstVarEntry)
        ifTrue: [
            object := HypheNECInstVarEntry basicNew.
            object initialize.
            ^ object ].
    object := self basicNew.
    object initialize.
    ^ object
]
