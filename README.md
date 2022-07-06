Original App Design Project - README
===

# Places

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
An app that helps you plan, track, and share the places you go. 

### App Evaluation
- **Category**: Travel
- **Mobile**: Mobile is essential for planning and documenting places on the go. As users travel to new locations, they can easily follow their planned itineraries, add newly discoverd spots to a list, view them on a map, or share these locations and their memories there via their mobile device. This app requires the user's current location, can integrate camera functionalities for the user to take pictures of the place they're at, and integrates with maps to help the user naviagate new places.
- **Story**: The instant planner, notetaker, memory storage, and sharing platform for travelers. Users can easily create itineraries, lists of places they've been, and share these lists with friends.
- **Market:** Millions of travelers around the world with iOS devices can use this app. Users don't need to be avid travelers—they can even be everyday citizens living in their hometown, but they wish to plan outings in advance or share their favorite places or itineraries with friends.
- **Habit:** Users can check the app daily to see the whereabouts of their friends. They can also use the app everytime they want to and/or are going to someplace new.
- **Scope:** V1 would allow users to create lists of places and itineraries. V2 would allow users to share these lists and itineraries and to view others' posts in a feed. V3 would create profiles containing all the lists/itineraries for each user, which other users can view. V4 would allow the user to add notes, including photos, of the places that they've been to their lists and itineraries. This would involve bringing up the live camera in the app and storing the photos in the app. V5 would implement features such as allowing the user to selectively share who can view a certain post, local biometric authentication (touch or face ID), notifications reminding them to use the app, and auto-suggesting itineraries for the user based on parameters such as budget, duration, location preferences, etc.  

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can register for a new account.
* User can login and logout. Information within an account is persistent.
* User can "heart" or favorite locations to save them. User can access all their favorited locations in one list.
    * There is a tab which shows a table view that displays the user's favorited places.
* For each place, the user can click to see a detail view of the place including the name, location on the map, a description, reviews, etc.
* User can create a new itinerary that always includes transportation (e.g. any flights), lodging (e.g. hotel information and dates), places to go, and estimated price. The information in these fields are manually added by the user.
    * There is a tab which shows a table view that displays the user's itineraries. 
    * Users can create new itineraries from this tab. 
* User can utilize a discover tab to search for places and favorite them. 
    * There is a filtering functionality for multiple attributes, such as category of location, star rating, price range, dates/availability, etc.
    * User can search for any granularity of location (from cities to continents).
    * TODO: Research Google Maps API to see what capabilities it provides us with. How is search and filtering done? What can we filter by? Seek to implement a more custom search/filtering algorithm than the API to make this a *planned technical challenge*.
* User can share an itinerary - *planned technical challenge*.
    * Upon hitting share, an action sheet pops up and a link will be generated.
    * The itinerary will be stored in the Parse database.
    * The user can send a text of the URL with the itinerary, and only those with the URL can access the itinerary.
* The app leverages the Google Maps API and/or the TripAdvisor API to get more information about a place. 
* User has a unique profile that includes a profile picture, name, username, and bio.
* There is a tab navigation controller that switches between the user's discover tab, saved itineraries, favorited places, and profile.


**Optional Nice-to-have Stories**

* User can add a "liked" place to a chosen itinerary.
* User can edit a previously made itinerary within the itinerary details view.
* User profile page includes a scrolling view of their favorited places and itineraries that they've created.
* The detail view of location includes notes added by the user, including photos they've taken.
* Feed sharing -- *technical challenge*
    * There is a home feed of lists and itineraries that were posted by accounts the user followers.
    * The user can share itineraries with their followers.
    * The user can filter for friends to share a certain list or itinerary with (e.g. sharing to a "close friends" list). They can keep a list/itinerary they've created private, only viewable for a certain group of followers, or public.
    * The user can see on their profile feed which lists/itineraries are private, shared to close friends, or public.
    * The app leverages the Facebook API to get friends information.
* The app generates suggested itineraries
    * The user can input price, preferred locations, duration, etc. to get a suggested itinerary  
* Maps view of an itinerary
    * The user can see all the locations within an itinerary in a maps view.
    * The user can filter in this maps view for specific types of locations, dates planned for locations, etc.
    * The user can generate shortest routes between locations.
* Sharing itinerary
    * Sharer of itinerary can see how many people have viewed their itinerary. 
    * Sharer of itinerary will get notified when the receiver has viewed their itinerary.
    * If receiver currently doesn't have the app, they will be prompted to download and sign up for the app.
    * If receiver does have the app, clicking the link will open up the app and prompt the user to login if they aren't signed in.
    * People can collaborate on an itinerary.
* The app can authenticate with biometrics.

### 2. Screen Archetypes

* Sign Up
    * User can login and logout
* Login
   * User can register for a new account
* Explore
   * User can utilize a discover tab to search for places and favorite them.
   * The app leverages the Google Maps API and/or the TripAdvisor API to get more information about a place.
* Favorites
    * User can "heart" or favorite locations to save them. User can access all their favorited locations in one list.
* Itinieraries list
    * User can create, edit, and view itineraries.
* Location detail view
    * For each place, the user can click to see a detail view of the place including the name, location on the map, a description, reviews, etc.
    * The app leverages the Google Maps API and/or the TripAdvisor API to get more information about a place.
* Itinerary detail view
    * User can share an itinerary - planned technical challenge.
* Itinerary creation 
    * User can create a new itinerary that always includes transportation (e.g. any flights), lodging (e.g. hotel information and dates), places to go, and estimated price. The information in these fields are manually added by the user.
* (popup) Share itinerary
    * User can share itinerary
* Profile
    * User has a unique profile that includes a profile picture, name, username, and bio.

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Explore
* Favorites
* Itineraries
* Profile

**Flow Navigation** (Screen to Screen)

* Sign Up
    => Login
* Login
    => Explore
* Explore
    => Location detail view
* Favorites
    => Location detail view
* Itinieraries list
    => Itinerary creation 
    => Itinerary detail view
* Location detail view
    => Explore (if naviagted here via Explore)
    => Favorites (if navigated here via Favorites)
* Itinerary detail view
    => Itinerary edit view
    => (popup) Share itinerary
* Itinerary edit view
    => Itinerary detail view
* Itinerary creation 
    => Itinieraries list
* Profile
    => None

## Wireframes
<img src="https://github.com/iristfu/Places/blob/main/Places%20Wireframe.JPG" width=600>


## Schema 
[This section will be completed in Unit 9]
### Models
[Add table of models]
### Networking
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
