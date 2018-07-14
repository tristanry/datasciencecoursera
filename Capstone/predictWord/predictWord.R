set.seed(12345)
library(dplyr)
library(stringr)

#load("freq_bigram.RData") ; frequency_bigram <- frequency_bigram[frequency_bigram$frequency>100,] ; save(frequency_bigram,file="freq_bigram_light.RData")
load("freq_bigram_light.RData")

predict_model <- as.data.frame(frequency_bigram)
predict_model <- cbind(predict_model, as.data.frame(str_split_fixed(predict_model[,1], pattern = " ", n = 5)))
predict_model <- select(predict_model, -words)

predict_next_word <- function(phrase){
    words <- strsplit(phrase, " ")[[1]]
    length_phrase <- length(words)
    predicted_words <- c(NA,NA,NA)
    if(length_phrase > 0 ){
        predicted_words<- predict_model %>%filter(V1==words[length_phrase], V2!= "") %>% top_n(3, frequency) %>% pull(V2) 
        predicted_words <- as.vector(predicted_words)[1:3]
    }
    predicted_words
}


