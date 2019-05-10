# Setup

# for all the basics
library(tidyverse)
# for fast string parsing functions
library(stringi)
# text mining library
library(tm)
# for pirateplot
library(yarrr)
# for sentiment analysis
library(tidytext)
# for clouds
library(wordcloud)
# for LDA
library(topicmodels)
# for renaming factors
library(plyr)

# set random seed for reproducibility
set.seed(12345)

# read the data
poems <- read.csv("poems.csv")


# create basic data bits
poems$Poem <- as.character(poems$Poem)
poems$PoemLines <- stri_count_fixed(poems$Poem, "\n") + 1

# make the author names reasonable.
poems$Author <- revalue(poems$Author, c(
  "Emily Dickinson" = "Dickinson",
  "John Keats" = "Keats",
  "Lord Byron" = "Byron",
  "Rudyard Kipling" = "Kipling",
  "Walt Whitman" = "Whitman",
  "William Blake" = "Blake",
  "William Wordsworth" = "Wordsworth"
  ))

# filter out mistakes
poems <- subset(poems, PoemLines < 200)

poem_line_len <- c()
poem_line_words <- c()
lines <- stri_split_lines(poems$Poem)
for (i in 1:nrow(poems)){
  poem_line_len[i] <- mean(stri_length(unlist(lines[i])))
  poem_line_words[i] <- mean(stri_count_boundaries(unlist(lines[i])))
}
poems$LineLength <- poem_line_len
poems$LineWords <- poem_line_words

# clean the data
raw_poems <- poems$Poem

raw_poems <- tolower(raw_poems)
raw_poems <- tm::removeNumbers(raw_poems)
raw_poems <- tm::removePunctuation(raw_poems)
raw_poems <- tm::removeWords(raw_poems, tm::stopwords("en"))
raw_poems <- tm::removeWords(raw_poems, c("t", "yet", "one"))
#raw_poems <- tm::stemDocument(raw_poems)
raw_poems <- tm::stripWhitespace(raw_poems)

poems$CleanText <- raw_poems

# sentiment analysis
sents <- get_sentiments("afinn")

get_word_value <- function(w) {
  sents[which(sents == w), ]$score
}


sent_scores <- c()
for (i in 1:nrow(poems)) {
  m <- unlist(stri_split_fixed(poems[i, "CleanText"], " ")) %>% 
    lapply(get_word_value) %>% 
    unlist() %>%
    mean()
  sent_scores[i] <- ifelse(is.nan(m), 0, m)
}
poems$sentiment <- sent_scores

# word clouds
plot_cloud <- function(doc) {
  dtm <- TermDocumentMatrix(doc)
  m <- as.matrix(dtm)
  v <- sort(rowSums(m),decreasing=TRUE)
  d <- data.frame(word = names(v),freq=v)
  wordcloud(words = d$word, freq = d$freq, min.freq = 1,
            max.words=200, random.order=FALSE, rot.per=0.35, 
            colors=brewer.pal(8, "Dark2"))
}

text.dickinson <- subset(poems, Author == "Dickinson")$CleanText
doc.dickinson <- Corpus(VectorSource(text.dickinson))
text.blake <- subset(poems, Author == "Blake")$CleanText
doc.blake <- Corpus(VectorSource(text.blake))
text.keats <- subset(poems, Author == "Keats")$CleanText
doc.keats <- Corpus(VectorSource(text.keats))
text.byron <- subset(poems, Author == "Byron")$CleanText
doc.byron <- Corpus(VectorSource(text.byron))
text.whitman <- subset(poems, Author == "Whitman")$CleanText
doc.whitman <- Corpus(VectorSource(text.whitman))
text.kipling <- subset(poems, Author == "Kipling")$CleanText
doc.kipling <- Corpus(VectorSource(text.kipling))
text.wordsworth <- subset(poems, Author == "Wordsworth")$CleanText
doc.wordsworth <- Corpus(VectorSource(text.wordsworth))


#### TOPIC ANALYSIS
doc.all <- Corpus(VectorSource(poems$CleanText))
dtm <- DocumentTermMatrix(doc.all)
# 5 topics
ldaOut <- LDA(dtm, 7, method='Gibbs')
topicProbabilities <- as.data.frame(ldaOut@gamma)
poems$topic1 <- topicProbabilities$V1
poems$topic2 <- topicProbabilities$V2
poems$topic3 <- topicProbabilities$V3
poems$topic3 <- topicProbabilities$V3
poems$topic4 <- topicProbabilities$V4
poems$topic5 <- topicProbabilities$V5
poems$topic6 <- topicProbabilities$V6
poems$topic7 <- topicProbabilities$V7
ldaOut.terms <- as.matrix(terms(ldaOut,5))

