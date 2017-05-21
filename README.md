# neo4j-nlp-nytimes

### Exploration of GraphAware NLP extension for neo4j-nlp-nytimes

Usage - install .jars in Neo4j plugin folder

Built for Neo4j enterprise version 3.1.3, also install apoc 3.1.3.7

Add the following to the neo4j.conf file.

```
#Apoc Plugin Configurations
apoc.import.file.enabled=true

#Graphaware Plugin Configurations
dbms.unmanaged_extension_classes=com.graphaware.server=/graphaware

com.graphaware.runtime.enabled=true

# A Runtime module for NLP processing
com.graphaware.module.NLP.2=com.graphaware.nlp.module.NLPBootstrapper

```

Add the article.json files to neo4j /import folder

Restart neo4j and run:

```
CREATE CONSTRAINT ON (a:Tag) ASSERT a.id IS UNIQUE;
```

And then:

```
//Load News from import folder
WITH "file:///nlp-nytimes/article-1.json" AS url
CALL apoc.load.json(url) YIELD value AS map
CREATE (n:News) SET n += map, n.uuid = apoc.create.uuid()
WITH "file:///nlp-nytimes/article-2.json" AS url
CALL apoc.load.json(url) YIELD value AS map
CREATE (n:News) SET n += map, n.uuid = apoc.create.uuid()
WITH "file:///nlp-nytimes/article-3.json" AS url
CALL apoc.load.json(url) YIELD value AS map
CREATE (n:News) SET n += map, n.uuid = apoc.create.uuid()
WITH "file:///nlp-nytimes/article-4.json" AS url
CALL apoc.load.json(url) YIELD value AS map
CREATE (n:News) SET n += map, n.uuid = apoc.create.uuid()
WITH "file:///nlp-nytimes/article-5.json" AS url
CALL apoc.load.json(url) YIELD value AS map
CREATE (n:News) SET n += map, n.uuid = apoc.create.uuid()

```

And then:

```
//Annotate News nodes
MATCH (n:News)
CALL ga.nlp.annotate({text:n.text, id: n.uuid}) YIELD result
MERGE (n)-[:HAS_ANNOTATED_TEXT]->(result)
RETURN n, result;
```

More info here

https://graphaware.com/neo4j/2016/07/07/mining-and-searching-text-with-graph-databases.html
