Predicting the Authorship of Poetry Snippets
========================================================
author: Nick Dieffenbacher-Krall
date: April 29, 2019
autosize: true




Project Goals
========================================================

- Determine the author of a poem using only data from that poem
- A classification problem
- Test data includes only the text of the poem

Applications
========================================================

- Determining authorship
- Classifying unknown works
- Comparing an author's canon

****

![a](images/beowulf.png)

Obtaining Data
========================================================
- Poems were sourced from Project Gutenberg
- 1774 peoms from 7 19th century poets
- Parsed from books via Python script

<small>

```
                           Book          Author
1 Poems: Three Series, Complete Emily Dickinson
                                                                                                                                                                                              Poem
1 That never wrote to me, --\nThe simple news that Nature told,\nWith tender majesty.\nHer message is committed\nTo hands I cannot see;\nFor love of her, sweet countrymen,\nJudge tenderly of me!
```
</small>

***

<img src="presentation-figure/unnamed-chunk-2-1.png" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" style="display: block; margin: auto;" />

Creating Variables
========================================================
- In order to do any classification, we need to create 
variables from the poem text
- Some easy initial variables are
    * Words per line
    * Lines per stanza
- Not yet very useful


***

<img src="presentation-figure/unnamed-chunk-3-1.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" width="150%" height="150%" style="display: block; margin: auto;" />


Natural Language Processing
========================================================
<small>
"Much madness is divinest sense  
To a discerning eye;   
Much sense the starkest madness.   
'T is the majority    
In this, as all, prevails.   
Assent, and you are sane;   
Demur, -- you're straightway dangerous,   
And handled with a chain."   
\- Emily Dickinson
</small>
<br />
<br />
- Analysis performed by word
- Data is cleaned to make analysis easier

***
<small>
"much madness divinest sense discerning eye much sense starkest madness t majority prevails assent sane demur youre straightway dangerous handled chain"
</small>
<br />
<br /><br /><br />

- Whitespace removed
- Stop words removed
- Punctuation removed
- Experimenting with stemming words

Wordclouds
========================================================

We can visualize the differences in word use between poet
with a word cloud.

<small> Emily Dickinson  </small>


![plot of chunk unnamed-chunk-4](presentation-figure/unnamed-chunk-4-1.png)

***

<small> William Blake </small>


![plot of chunk unnamed-chunk-5](presentation-figure/unnamed-chunk-5-1.png)


Sentiment Analysis
========================================================
- A common way of creating data from natural langauge
- Using the AFINN sentiment lexicon

![plot of chunk unnamed-chunk-6](presentation-figure/unnamed-chunk-6-1.png)

Comparision of Sentiments
========================================================

<img src="presentation-figure/unnamed-chunk-7-1.png" title="plot of chunk unnamed-chunk-7" alt="plot of chunk unnamed-chunk-7" style="display: block; margin: auto;" />

Can we make predictions?
========================================================
- We may have enough variables to make successful predictions
- Use test and train sets to evaluate models

***

<img src="presentation-figure/unnamed-chunk-8-1.png" title="plot of chunk unnamed-chunk-8" alt="plot of chunk unnamed-chunk-8" style="display: block; margin: auto;" />

Using SVM to classify author
========================================================
- Using a linear kernel, two dimensions
    * Words per line
    * Sentiment
- Cost parameter evaluated by 5 fold CV
- The model gives a successful classification rate of 0.6734234 on the test data.

***

<img src="presentation-figure/unnamed-chunk-9-1.png" title="plot of chunk unnamed-chunk-9" alt="plot of chunk unnamed-chunk-9" style="display: block; margin: auto;" />


Further work
========================================================
- More complex sentiment analysis
- Discrete variables based on word usage
- Create model using `xgboost`, and others
- Latent Dirichlet Allocation (the other LDA)
