# Hyphe

Hyphe is a hybrid type-inference framework for Pharo Smalltalk that integrates multiple complementary sources of type information into a unified inference pipeline. It combines structural AST analysis, lightweight heuristics, offline runtime profiling of test executions, and existing inference tools (such as RoelTyper and J2Inferer).
The system orchestrates these tools, merges their results using several configurable strategies, and stores the inferred return types in Mycelium, a shared JSON-based type repository


## Installation
To install Hyphe in the Pharo image run in the Playground:

```Smalltalk
Metacello new
		baseline: 'Hyphe';
		repository: 'github://hyalinos/hyphe:main';     
	load.
```

## ICPC
To run the image with predinstalled libraries go to [ICPC artefacts](https://github.com/hyalinos/icpc)
