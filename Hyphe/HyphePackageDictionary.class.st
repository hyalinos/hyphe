Class {
	#name : 'HyphePackageDictionary',
	#superclass : 'Dictionary',
	#category : 'Hyphe-Injection',
	#package : 'Hyphe',
	#tag : 'Injection'
}

{ #category : 'as yet unclassified' }
HyphePackageDictionary class >> cleanUpInjection [
"TODO: find all instances of IceWorkingCopy, and replace the packagesDictionary with actual dictionaries using reflection on its instance variable: #packages"
]

{ #category : 'instance creation' }
HyphePackageDictionary class >> newFromDictionary: aDictionary [
"note that this convertion will register all packages as added in the listener"
    | newDic |
    newDic := self new.
    newDic addAll: aDictionary.
    ^ newDic
]

{ #category : 'converting' }
HyphePackageDictionary >> asDictionary [
"used to restore the original dictionary when un-injecting code"
|newDic|

    newDic := Dictionary new.
    newDic addAll: self.
    ^ newDic
]

{ #category : 'accessing' }
HyphePackageDictionary >> at: key put: anObject [
	|res|
	res := super at: key put: anObject.
		Transcript showCr: 'Package added to dictionary:', res package.
	^ res
]

{ #category : 'removing' }
HyphePackageDictionary >> removeKey: aPackageSymbol ifAbsent: aBlock [
|res|
res:= super removeKey: aPackageSymbol ifAbsent: aBlock.
Transcript showCr: 'Removed package: ',aPackageSymbol.
^res
]
