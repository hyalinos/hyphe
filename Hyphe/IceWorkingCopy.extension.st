Extension { #name : 'IceWorkingCopy' }

{ #category : '*Hyphe' }
IceWorkingCopy >> packagesDictionary [
"Overriden by Hyphe to listen to package changes"
^(packages class == Dictionary) ifTrue:[packages:=HyphePackageDictionary newFromDictionary: packages] ifFalse: [packages ]
	 
]
