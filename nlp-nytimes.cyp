//Create Tag Constraint
CREATE CONSTRAINT ON (a:Tag) ASSERT a.id IS UNIQUE;

//Get NLP Processors
CALL ga.nlp.getProcessors() YIELD class return class;

//NLP Pipelines StanfordNLP
CALL ga.nlp.getPipelines({textProcessor: 'com.graphaware.nlp.processor.stanford.StanfordTextProcessor'}) YIELD result return result;

//NLP Pipelines OpenNLP
CALL ga.nlp.getPipelines({textProcessor: 'com.graphaware.nlp.processor.opennlp.OpenNLPTextProcessor'}) YIELD result return result;

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


//Annotate text nodes
MATCH (n:News)
CALL ga.nlp.annotate({text:n.text, id: n.uuid}) YIELD result
MERGE (n)-[:HAS_ANNOTATED_TEXT]->(result)
RETURN n, result;

//Sentiment Extraction
MATCH (at:AnnotatedText)
WITH COLLECT(at) AS txts
UNWIND txts AS a
CALL ga.nlp.sentiment({node:a, id: a.uuid, processor: "stanford"}) YIELD result
MATCH (result)-[:CONTAINS_SENTENCE]->(s:Sentence)
return labels(s) as labels

//Get Sentences
MATCH (n:Sentence) RETURN n

//Token and Sentiment Annotation StanfordNLP
MATCH (n:News)
CALL ga.nlp.annotate({text:n.text, id: n.uuid, textProcessor: "com.graphaware.nlp.processor.stanford.StanfordTextProcessor", pipeline: "tokenizerAndSentiment"}) YIELD result
MERGE (n)-[:HAS_ANNOTATED_TEXT]->(result)
RETURN n, result

//Language Detection
MATCH (n:News)
CALL ga.nlp.language({text: n.text}) YIELD result return result

//Tag Rank
MATCH (t:Tag) WHERE SIZE( (t)-[:HAS_TAG]-() ) > 5
AND (t.pos IN ["NN","NNS","NNP","NNPS","JJ"] OR t.ne IN ["LOCATION","PERSON","ORGANIZATION"])
RETURN t, SIZE( (t)-[:HAS_TAG]-() ) AS Mentions ORDER By Mentions DESC

//Named Entity Recognition
MATCH (t:Tag) WHERE SIZE( (t)-[:HAS_TAG]-() ) > 5 AND t.ne <> "O"
WITH t.ne AS entity, COLLECT([t.value, SIZE( (t)-[:HAS_TAG]-() ) ]) AS names
RETURN entity, names ORDER BY entity DESC

//Cosine Similarity
MATCH (at:AnnotatedText)
CALL ga.nlp.ml.cosine.compute({node: at}) YIELD result
WITH COLLECT(at) AS txts
UNWIND txts AS a
MATCH (n0:News)-[:HAS_ANNOTATED_TEXT]->(a)-[s:SIMILARITY_COSINE]->(b)<-[:HAS_ANNOTATED_TEXT]-(n1:News)
RETURN s.value, n0.title, n1.title ORDER by s.value DESC

//Get Similarity Graph
MATCH (a:AnnotatedText)-[:HAS_ANNOTATED_TEXT|SIMILARITY_COSINE]-(n:News) RETURN a,n

//Phrase Annotation OpenNLP
MATCH (n:News)
CALL ga.nlp.annotate({text:n.text, id: n.uuid, textProcessor: "com.graphaware.nlp.processor.opennlp.OpenNLPTextProcessor", pipeline: "phrase"}) YIELD result
MERGE (n)-[:HAS_ANNOTATED_TEXT]->(result)
RETURN n, result

//Get Phrases
MATCH (n:Phrase) RETURN n.value, ORDER BY SIZE(n.value) DESC

//TODO: Concept5
MATCH (at:AnnotatedText) CALL ga.nlp.concept({node:at, depth: 2, admittedRelationships: ["IsA"]})
YIELD result
RETURN result;

//TODO: NLP Text Filtering
MATCH (n:News)
CALL ga.nlp.filter({text: n.text, filter: "Trump/PERSON, Congress/ORGANIZATION"}) YIELD result
return result
