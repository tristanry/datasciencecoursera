library("tm")
library(ggplot2)
library(reshape)
library(dplyr)
library(RWeka)
library(stringr)

#source("https://bioconductor.org/biocLite.R")
#biocLite("Rgraphviz")
library(Rgraphviz)

set.seed(123450)

#download.file(url="https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip", destfile = "Coursera-SwiftKey.zip")
#unzip("Coursera-SwiftKey.zip")

ovid <- Corpus(DirSource("../final/en_US_200/"), readerControl = list(language = "en", load = TRUE))

#cleaning the corpus 
ovid <- tm_map(ovid, PlainTextDocument)
ovid <- tm_map(ovid, tolower)
ovid <- tm_map(ovid, stripWhitespace)
ovid <- tm_map(ovid,removePunctuation)
ovid <- tm_map(ovid, removeNumbers)
ovid <- tm_map(ovid, removeWords,stopwords("english"))
#Vcropus is mandatory for the tokenization
ovid <- VCorpus(VectorSource(ovid))


#bigram 
bigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
tdm_bigram <- TermDocumentMatrix(ovid, control = list(tokenize = bigramTokenizer))

frequency_bigram <- data.frame(row.names = rownames(tdm_bigram))
frequency_bigram$words <- rownames(tdm_bigram)
frequency_bigram$frequency <- rowSums(as.matrix(tdm_bigram))
frequency_bigram$type <- "bigram"
frequency_bigram <- arrange(frequency_bigram, desc(frequency)) 

#trigram 
trigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 3, max = 3))
tdm_trigram <- TermDocumentMatrix(ovid, control = list(tokenize = trigramTokenizer))

frequency_trigram <- data.frame(row.names = rownames(tdm_trigram))
frequency_trigram$words <- rownames(tdm_trigram)
frequency_trigram$frequency <- rowSums(as.matrix(tdm_trigram))
frequency_trigram$type <- "trigram"
frequency_trigram <- arrange(frequency_trigram, desc(frequency)) 

#ngram
ngramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 4, max = 5))
tdm_ngram <- TermDocumentMatrix(ovid, control = list(tokenize = ngramTokenizer))

frequency_ngram <- data.frame(row.names = rownames(tdm_ngram))
frequency_ngram$words <- rownames(tdm_ngram)
frequency_ngram$frequency <- rowSums(as.matrix(tdm_ngram))
frequency_ngram$type <- "ngram"
frequency_ngram <- arrange(frequency_ngram, desc(frequency)) 

predict_model <- rbind(frequency_bigram, frequency_trigram, frequency_ngram)
predict_model <- cbind(predict_model, as.data.frame(str_split_fixed(predict_model[,1], pattern = " ", n = 5)))
predict_model <- select(predict_model, -words)