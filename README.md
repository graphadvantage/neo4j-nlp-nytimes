# neo4j-nlp-nytimes

### Exploration of GraphAware NLP extension for neo4j-nlp-nytimes

Dependencies - Neo4j Enterprise 3.1.3, apoc 3.1.3.7

Install:

Download the GraphAware Server plugin for Neo4j Enterprise 3.1.3, and copy it to the Neo4j /plugins folder

graphaware-server-enterprise-all.3.1.3.47.jar

https://products.graphaware.com/download/framework-server-enterprise/graphaware-server-enterprise-all-3.1.3.47.jar

Copy the .jars to the Neo4j /plugins folder:

graphaware-nlp-1.0-SNAPSHOT.jar

nlp-opennlp-1.0-SNAPSHOT.jar


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
WITH "file:///PATH_TO_NEO4J/import/article-1.json" AS url
CALL apoc.load.json(url) YIELD value AS map
CREATE (n:News) SET n += map, n.uuid = apoc.create.uuid()
WITH "file:///PATH_TO_NEO4J/import/article-2.json" AS url
CALL apoc.load.json(url) YIELD value AS map
CREATE (n:News) SET n += map, n.uuid = apoc.create.uuid()
WITH "file:///PATH_TO_NEO4J/import/article-3.json" AS url
CALL apoc.load.json(url) YIELD value AS map
CREATE (n:News) SET n += map, n.uuid = apoc.create.uuid()
WITH "file:///PATH_TO_NEO4J/import/article-4.json" AS url
CALL apoc.load.json(url) YIELD value AS map
CREATE (n:News) SET n += map, n.uuid = apoc.create.uuid()
WITH "file:///PATH_TO_NEO4J//import/article-5.json" AS url
CALL apoc.load.json(url) YIELD value AS map
CREATE (n:News) SET n += map, n.uuid = apoc.create.uuid()

```

And then:

```
//Annotation and Sentiment Annotation with StanfordNLP
MATCH (n:News)
CALL ga.nlp.annotate({text:n.text, id: n.uuid, textProcessor: "com.graphaware.nlp.processor.stanford.StanfordTextProcessor", pipeline: "tokenizerAndSentiment"}) YIELD result
MERGE (n)-[:HAS_ANNOTATED_TEXT]->(result)
RETURN n, result
```

More info here

https://graphaware.com/neo4j/2016/07/07/mining-and-searching-text-with-graph-databases.html
