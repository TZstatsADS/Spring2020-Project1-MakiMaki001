# Applied Data Science @ Columbia
## Spring 2020
## Project 1: A "data story" on the songs of our times

<img src="figs/title1.jpeg" width="500">

### [Project Description](doc/)
This is the first and only *individual* (as opposed to *team*) this semester. 

Term: Spring 2020

+ Projec title: Lyrics Data EDA
+ This project is conducted by [Marko Konte]

+ Project summary: [In this EDA we looked at the dataset of over 30000 songs to find patterns and insights about them. We saw that the data was heavily skewed for songs that were in the 2000 decade. Specifically, we found that songs in 2006 and 2007 comprised of nearly half of the whole dataset.

We also found interesting patterns when it comes to the words that are used per song. We looked at the most common words that are used in songs and saw trends as they pertain to what type of language is used per genre. We found that among commonly used words was 'baby', which is makes sense in that this word can be used for both a more romantic song or a more upbeat, dancing song. Words like love tended to cluster around the more sentimental of the genres, such as country. Finally, 'Party' and 'Rock' were most popular words used in genres such as Pop or Hip Hop. 

With a little more time (and experience) I would like to have been able to create a sentiment based word cloud based on the stemmed words that we created. The issue I came accross when creating a termdocumentmatrix is that the variables could not compute when trying to put the data into a matrix. This prevented me from being able to run the wordcloud (even with the truncated dataset with .5 of the initial observations). It would be good to learn best ways to achieve computational efficiency while also getting more comfort with running more complext text analysis models. ] 

Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.
