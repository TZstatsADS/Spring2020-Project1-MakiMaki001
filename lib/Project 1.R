# Project 1

getwd()
setwd('C:\\Users\\marko\\OneDrive\\Documents\\Columbia\\Applied Data Science\\data')

library(knitr)

start <- Sys.time()
start

##### From the Text_Processing.Rmd 

##1. load the data

lyrics <- read.csv("lyrics.csv", stringsAsFactors = T)

summary(lyrics)
str(lyrics)

#Showing majority of songs made in 2006
t <- dt_lyrics %>% group_by(year) %>% 
  summarise(Count=n()) %>% arrange(desc(Count))
print(tbl_df(t), n=10)

library(tm)
library(data.table)
library(tidytext)
library(tidyverse)
library(DT)
library(textreadr)
#install.packages('textreadr')
library(dplyr)
library(rvest)
library(stringr)
library(lubridate)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)

load('../data/lyrics.RData')

?load()

#Splitting Data into parts
set.seed(1031)
split = sample(nrow(dt_lyrics),size = 0.5*nrow(dt_lyrics))
dt_lyrics = dt_lyrics[split,]
test = dt_lyrics[-split,]

dt_lyrics %>% group_by(year) %>% 
  summarise(Count=n()) %>% arrange(desc(Count))

##2. Preliminary cleaning of text 

#We clean the text by converting all the letters to the lower case, and removing punctuation, numbers, empty words and extra white space.

# function for removimg leading and trailing whitespace from character strings 
leadingWhitespace <- content_transformer(function(x) str_trim(x, side = "both"))

?content_transformer

#remove stop words
data("stop_words")
stop_words

word <- c("lot", "today", "months", "month", "wanna", "wouldnt", "wasnt", "ha", "na", "ooh", "da",
          "gonna", "im", "dont", "aint", "wont", "yeah", "la", "oi", "nigga", "fuck",
          "hey", "year", "years", "last", "past", "feel")

stop_words <- c(stop_words$word, word)

#Clean data and make a corpus

corpus <- VCorpus(VectorSource(dt_lyrics$lyrics)) %>%
  tm_map(content_transformer(tolower))%>%
  tm_map(removePunctuation)%>%
  tm_map(removeWords, character(0))%>%
  tm_map(removeWords, stop_words)%>%
  tm_map(removeNumbers)%>%
  tm_map(stripWhitespace)%>%
  tm_map(leadingWhitespace)


##3. Stemming words and converting tm object to tidy object
#Stemming reduces a word to its word *stem*. We stem the words here and then convert the "tm" object 
#to a "tidy" object for much faster processing.


stemmed <- tm_map(corpus, stemDocument) %>%
  tidy() %>%
  select(text)


### 4- Creating tidy format of the dictionary to be used for completing stems
# We also need a dictionalry to look up the words corresponding to the stems.


dict <- tidy(corpus) %>%
  select(text) %>%
  unnest_tokens(dictionary, text)

### 5 Combinin items and dictionalry into the same tibble
completed <- stemmed %>%
  mutate(id = row_number()) %>%
  unnest_tokens(stems, text) %>%
  bind_cols(dict) 


### 6 - stem completion
completed <- completed %>%
  group_by(stems) %>%
  count(dictionary) %>%
  mutate(word = dictionary[which.max(n)]) %>%
  ungroup() %>%
  select(stems, word) %>%
  distinct() %>%
  right_join(completed) %>%
  select(-stems)


### 7 Pasting stem completed individual words into their respective lyrics
#We are proceeding to resemble the structure of original lyrics. So we paste the words
#together to form processed lyrics. 
completed <- completed %>%
  group_by(id) %>%
  summarise(stemmedwords= str_c(word, collapse = " ")) %>%
  ungroup()


### 8 Keeping track of the processed lyric with their own ID

dt_lyrics <- dt_lyrics %>%
  mutate(id = row_number()) %>%
  inner_join(completed)

### Exporting the processed text data into a CSV file
save(dt_lyrics, file="../data/processed_lyrics.RData")


########## Analysis using the text_processing.rmd preparation file
load('../data/processed_lyrics.RData')

summary(dt_lyrics)
str(dt_lyrics)
summary(dt_lyrics$artist)
dt_lyrics$artist
head(dt_lyrics$artist)

str(lyrics)

str(dt_lyrics$stemmedwords)
summary(dt_lyrics$stemmedwords)

library(qdap)

str(dt_lyrics)

#Making genre factor

dt_lyrics$genre <- as.factor(dt_lyrics$genre)
levels(dt_lyrics$genre)

#Making artist factor
dt_lyrics$artist <- as.character(dt_lyrics$artist)
levels(dt_lyrics$artist)

### Second RMD file- Lyrics_ShinyApp.Rmd

#### From Kaggle - https://www.kaggle.com/rodrigonca/lyrics-text-mining

#Inputing decade variable
library(dplyr)

dt_lyrics$decade <- paste(str_sub(dt_lyrics$year, 1, 3), '0', sep = '')
dt_lyrics$decade <- as.factor(dt_lyrics$decade)
levels(dt_lyrics$decade)

dt_lyrics[dt_lyrics$decade == '1120',]
dt_lyrics[dt_lyrics$decade == '7020',]

dt_lyrics$decade == '7020'

str(dt_lyrics)

toBeRemoved<-which(dt_lyrics$decade=='1120')
dt_lyrics <- dt_lyrics[-toBeRemoved,]

toBeRemoved2<-which(dt_lyrics$decade=='7020')
dt_lyrics <- dt_lyrics[-toBeRemoved2,]

#Displaying songs and artists by decade
temp  <- dt_lyrics %>% group_by(lyrics, decade) %>% 
  summarise(songs = n(),
            artists = length(unique(artist))) %>% 
  arrange(desc(decade))

temp <- na.omit(temp)

ggplot(data = temp, aes(x= decade, y = songs)) +
  geom_bar(stat = 'identity', aes(fill = decade)) +
  coord_flip() +
  xlab('Decade') +
  ylab('') +
  labs(title = 'Songs and Artists by Decade') +
  theme(text = element_text(size = 20))

levels(dt_lyrics$decade)

reorder(Source, -Projections)

end = Sys.time()
mem = pryr::mem_used()

dt_lyrics %>% group_by(decade) %>%
  summarise(Songs=n())


#Displaying songs by genre
genre  <- dt_lyrics %>% group_by(artist, genre) %>% 
  summarise(songs = n(),
            artists = length(unique(artist))) %>% 
  arrange(desc(artist))

ggplot(data = genre) +
  geom_bar(stat = 'identity', aes(x= reorder(genre, -songs), y = songs, fill = genre)) +
  coord_flip() +
  xlab('Genre') +
  ylab('Songs') +
  labs(title = 'Genre and Artists') +
  theme(text = element_text(size = 20))


#Songs by decade by genre

dcgenre  <- dt_lyrics %>% group_by(decade, genre, artist) %>% 
  summarise(songs = n()) %>% 
  arrange(desc(genre))


ggplot(data = dcgenre) +
  geom_bar(stat = 'identity', aes(x= decade, y = songs, fill = genre)) +
  coord_flip() +
  xlab('Decade') +
  ylab('Songs') +
  labs(title = 'per decade genre') +
  theme(text = element_text(size = 20))

summary(dt_lyrics$genre)
str(dt_lyrics)

dt_lyrics %>% group_by(genre, decade) %>%
  summarise(songs = n(),
            GenrePerc = n()/nrow(dt_lyrics)) %>%
  arrange(desc(songs))


print(tbl_df(d), n=40)

dt_lyrics %>% group_by(decade, genre) %>%
  summarise(songs = n(),
            GenrePerc = n()/nrow(dt_lyrics)) %>%
  arrange(desc(songs))

#Top 3 artists by quantity of music by genre

start = Sys.time()

count(lyrics, genre, artist, sort = TRUE) %>% 
  group_by(genre) %>% 
  arrange(desc(n)) %>% 
  filter(row_number() <= 3) %>% 
  arrange(desc(genre), desc(n))

end = Sys.time()
mem = pryr::mem_used()

WriteLog('plot top artists', start, end, mem)




#### From Kaggle- https://www.kaggle.com/karineh/40-year-lyrics-evolution

#Visualizing Genre Per word 


dt_lyrics2 <- dt_lyrics
dt_lyrics2$lyrics <- as.factor(dt_lyrics2$lyrics)

#Baby
dt_lyrics2$baby = str_count(dt_lyrics2$lyrics, 'baby')

ggplot(dt_lyrics2) + aes(baby, year, col = genre, alpha = 1) + 
  geom_point() + 
  ylim(1968,2020)


# Love
dt_lyrics2$love = str_count(dt_lyrics2$lyrics, 'love')

ggplot(dt_lyrics2) + aes(love, year, col = genre, alpha = 1) + 
  geom_point() + 
  ylim(1968,2020)

# Rock 
dt_lyrics2$rock = str_count(dt_lyrics2$lyrics, 'rock')

ggplot(dt_lyrics2) + aes(rock, year, col = genre, alpha = 1) + 
  geom_point() + 
  ylim(1968,2020)

# Party
dt_lyrics2$party = str_count(dt_lyrics2$lyrics, 'party')

ggplot(dt_lyrics2) + aes(party, year, col = genre, alpha = 1) + 
  geom_point() + 
  ylim(1968,2020)

str(dt_lyrics2)

# Word cloud



### Wordcloud- InteractiveWordCloud.Rmd

# Create a term document matrix

tdm_lyrics <- TermDocumentMatrix(corpus)

                                 
# Step 3 - Inspect an overall wordcloud
```{r, fig.height=6, fig.width=6}
wordcloud(tdm.overall$term, tdm.overall$`sum(count)`,
          scale=c(5,0.5),
          max.words=100,
          min.freq=1,
          random.order=FALSE,
          rot.per=0.3,
          use.r.layout=T,
          random.color=FALSE,
          colors=brewer.pal(9,"Blues"))


#Isolating rock songs

lyricsROCK <- dt_lyrics[dt_lyrics$genre == 'Rock',]

str(lyricsROCK)

corprock <- VCorpus(VectorSource(lyricsROCK$lyrics))

tdm_rock <- TermDocumentMatrix(corprock)

# Word cloud

library(wordcloud)

dt_lyrics %>% group_by(dt_lyrics$genre)
  count(song) %>%
  with(wordcloud(lyrics, n, max.words = 100))

m <- as.matrix(tdm_rock)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d, 10)  
  
wordcloud(words = d$word, freq = d$freq, min.freq = 1,
           max.words=200, random.order=FALSE, rot.per=0.35, 
           colors=brewer.pal(8, "Dark2"))

#Isolating non rock

lyricsNR <- dt_lyrics[dt_lyrics$genre != 'Rock',]

corpNR <- VCorpus(VectorSource(lyricsNR$lyrics))

tdm_NR <- TermDocumentMatrix(corpNR)

m <- as.matrix(tdm_NR)

?tidy
