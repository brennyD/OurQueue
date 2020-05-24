# OurQueue

A common problem many have while on long road trips or during parties is the constant passing around a phone through crowds of people and tangles of aux chords to queue up new songs on Spotify. This app aims to solve that issue by allowing multiple phones to connect to one host Spotify player and queue up songs remotely to that user's account. 

Phones connect to eachother using Multipeer Connectivity, which is a peer-to-peer network library that uses wifi and bluetooth. Session information is then stored in a Firebase database, and queueing and authorization functions are stored as firebase cloud functions, which communicate with the Spotify web API. All user data present in the database is deleted permanently once the listening session is over, complying with the Spotify Terms of Service.

Eventually, I was planning on ironing this app out completely and publishing it to the app store, however recently (like, last week recently) Spotify introduced their Group DJ feature, which makes this app completely obsolete (bummer!). So I decided to make its source code public, but the firebase backend and Spotify app data has since been deleted making the app non-functional. 

[Here is a demo video of how the app worked in its current form](https://www.youtube.com/watch?v=_xGXkWIehlo)

This was still a fun side project to implement regardless, and if you have any questions please reach out!
