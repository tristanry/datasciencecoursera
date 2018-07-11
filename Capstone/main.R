set.seed(12345)
library(dplyr)

options(java.parameters = "-Xmx8g") 

useSubDataSet = FALSE
cleanData = FALSE
load = TRUE

if(!load){
    
    library(tm)
    library(ggplot2)
    library(reshape)

    library(RWeka)
    library(stringr)
    
    #source("https://bioconductor.org/biocLite.R")
    #biocLite("Rgraphviz")
    library(Rgraphviz)
    
    library(tm.plugin.dc)
    
    
    #download.file(url="https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip", destfile = "Coursera-SwiftKey.zip")
    #unzip("Coursera-SwiftKey.zip")
    
    
    if(useSubDataSet){
        #create a sub dataset with the 200th first lines of each files
        system("mkdir ./final/en_US_200/")
        system("head -200 ./final/en_US/en_US.blogs.txt > ./final/en_US_200/en_US.blogs.txt_200")
        system("head -200 ./final/en_US/en_US.news.txt > ./final/en_US_200/en_US.news.txt_200")
        system("head -200 ./final/en_US/en_US.twitter.txt > ./final/en_US_200/en_US.twitter.txt_200")
        
        ovid <- Corpus(DirSource("./final/en_US_200/"), readerControl = list(language = "en", load = TRUE))
    }else{
        ovid <- Corpus(DirSource("./final/en_US/"), readerControl = list(language = "en", load = TRUE))
    }
    
    #tdm <- TermDocumentMatrix(ovid, control = list(removePunctuation = TRUE, stopwords = TRUE, removeNumbers = TRUE,  stemming = TRUE))
    #inspect(tdm[findFreqTerms(tdm, 25, Inf), 1:3])
    #findAssocs(tdm, "girlfriend", 0.85)
    
    #cleaning the corpus 
    
    # ovid <- tm_map(ovid, PlainTextDocument)
    # ovid <- tm_map(ovid, tolower)
    # ovid <- tm_map(ovid, stripWhitespace)
    # ovid <- tm_map(ovid,removePunctuation)
    # ovid <- tm_map(ovid, removeNumbers)
    # ovid <- tm_map(ovid, removeWords,stopwords("english"))
    
    #ovid<-tm_map(ovid, function(x){gsub("'s","",x)})
    #ovid<-tm_map(ovid,function(x){gsub("\"","",x)})
    #Vcropus is mandatory for the tokenization
    ovid <- VCorpus(VectorSource(ovid))
    
    
    #bigram 
    #bigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
    bigramTokenizer <- function(x){ unlist(lapply(ngrams(words(x), 2), paste, collapse = " "), use.names = FALSE)}
    
    tdm_bigram <- TermDocumentMatrix(ovid, control = list(tokenize = bigramTokenizer, removePunctuation = TRUE, stopwords = TRUE, removeNumbers = TRUE,  stemming = TRUE))
    
    frequency_bigram <- data.frame(row.names = rownames(tdm_bigram))
    frequency_bigram$words <- rownames(tdm_bigram)
    frequency_bigram$frequency <- rowSums(as.matrix(tdm_bigram))
    frequency_bigram$type <- "bigram"
    frequency_bigram <- arrange(frequency_bigram, desc(frequency)) 
    
    #trigram 
    # trigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 3, max = 3))
    trigramTokenizer <- function(x){ unlist(lapply(ngrams(words(x), 3), paste, collapse = " "), use.names = FALSE)}
    tdm_trigram <- TermDocumentMatrix(ovid, control = list(tokenize = trigramTokenizer, removePunctuation = TRUE, stopwords = TRUE, removeNumbers = TRUE,  stemming = TRUE))

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
    
    save(tdm_bigram,tdm_trigram,tdm_ngram, file = "tdm.RData")
    save(frequency_bigram,frequency_trigram,frequency_ngram, file = "freqRData")
    
    
    ggplot(rbind(frequency_bigram[1:20,]) , aes(x=reorder(words, frequency), y=frequency)) + 
        geom_bar(stat = "identity")+ 
        coord_flip() +
        facet_wrap(~type, scales = "free") +
        labs(y = "count", x = "ngrqm", title = "Frequency of the 20th more frequent bigram and trigram") 
    
    
}else{
    load("tdm_bigram.RData")
    load("freq_bigram.RData")
}

predict_model <- as.data.frame(frequency_bigram)
predict_model <- cbind(predict_model, as.data.frame(str_split_fixed(predict_model[,1], pattern = " ", n = 5)))
predict_model <- select(predict_model, -words)
# predict_model[sample(1:nrow(predict_model),10),]




predict_next_word <- function(phrase){
    words <- strsplit(phrase, " ")[[1]]
    length_phrase <- length(words)
    predicted_words <- c(NA,NA,NA)
    # if(length_phrase == 1){
    #     predicted_words<- predict_model %>%filter(V1==words[1], type =="bigram") %>% top_n(3, frequency) %>% pull(V2) 
    # }else{
    #     predicted_words<- predict_model %>%filter(V1==words[1], V2==words[2],type =="trigram") %>% top_n(3, frequency) %>% pull(V3) 
    # }else{
    #     predicted_words<- predict_model %>%filter(V1==words[1], V2==words[2], V3==words[3], type =="ngram") %>% top_n(3, frequency) %>% pull(V4)
    # }
    if(length_phrase > 0 ){
        predicted_words<- predict_model %>%filter(V1==words[length_phrase]) %>% top_n(3, frequency) %>% pull(V2) 
        predicted_words <- as.vector(predicted_words)[1:3]
    }
    predicted_words
}


