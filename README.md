# Places

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
1. [Schema](#Schema)
2. [Demos](#Demos)

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
* User can "heart" or favorite locations to save them. 
    * There is a tab which shows a table view that displays the user's favorited places where the user can access all their favorited locations in one list.
* User can create a new itinerary that always includes name, date, transportation (e.g. any flights), lodging (e.g. hotel information and dates), and places to go. The information in these fields are manually added by the user.
    * There is a tab which shows a table view that displays the user's itineraries. Users can create new itineraries from this tab. 
    * Within the itinerary compose view, there is an add button that prompts the "Add places to go" view, where the user can select and add places to go.
    * User can edit or delete a previously made itinerary within the itinerary details view.
* User can utilize a discover tab to search for places and favorite them. 
    * User can search for any granularity of location (from cities to continents).
    * User can sort the results on the discover tab by how many other app users have favorited or added the place to itinerary - *planned technical challenge*.
        * If sort setting is set:
            * current results will sort
            * future results will sort
        * Unclicking the sort preference will undo the sort setting such that 
            * current results will unsort
            * future results will not be sorted by previous preference
        * User should not be able to select both increasing and decreasing at the same time. Selecting one will undo the other, kind of like a toggle. User can also deselect both and revert to default sorting. 
* User can share and collaborate on itineraries with access level control and activity tracking - *planned technical challenge*.
    * In an itinerary’s detail view, upon hitting share, an action sheet pops up and a custom link will be generated (e.g. places://itinerary/YBzt5P1gRI).
    * The itinerary will be stored in the Parse database.
    * The user can send a text of the URL with the itinerary, and only those with the URL can access the itinerary.
    * Clicking on the link prompts the app to open with the correct itinerary’s detail view, alongside the tab bar and navigation button to go back to the itinerary table view.
    * Activity tracking
        * User can see activity history on an itinerary, including when it was created, viewed, and edited, and by whom
    * Itinerary collaboration
        * Users with edit access can edit an itinerary
            * Changes made will be updated to all who have view access to the itinerary
        * User can toggle between "My itineraries" and "Shared itineraries" in the itineraries table view
        * User can unshare an itinerary by removing any viewers or editors
* User can map the shortest route to travel through an itinerary's places to go - *planned technical challenge*
    * Through an itinerary's detail view the user can touch a "map shortest route" button, which will prompt a new screen. 
        * The user is prompted by pop up buttons to select a travel mode (driving, walking, biking) and criteria (duration or distance) to determine the shortest route by 
    * The app uses the Google Map Distance Matrix API to get the travel time duration or distance (depending on user selection) between all paired combinations of places to go
    * The app leverages the traveling salesman algorithm to get the ordering of places to go 
    * Knowing the ordering of places to go and the selected travel mode, the app uses the Google Map Routing API with the appropriate starting, waypoint, and ending locations to display to the user the route between all of their places to go
    * There is a "Open in Google Maps" button that opens the Google Maps app with the route inputted
* The app leverages the Google Maps and Place API to get more information about a place. 
* User has a unique profile that includes a profile picture, name, username, and bio.
* There is a tab navigation controller that switches between the user's discover tab, saved itineraries, favorited places, and profile.


**Optional Nice-to-have Stories**

* Discover View
    * Add to favorites button is layered on top of the image
        * There is an animation when the user adds to place to favorites
    * * “Add to Favorites” button visually looks different depending on whether or not the place has already been favorited and this change is animated
    * User can unfavorite locations from the Discover view.
* Favorites View
    * User can delete and reorder items on the favorite list.
    * Display the number of favorites the user has on the favorites view, and update this number as the user adds or removes favorites from the list.
    * User can add a "liked" place to a chosen itinerary.
    * For each place, the user can click to see a detail view of the place including the name, location on the map, a description, reviews, etc.
        * The detail view of location includes notes added by the user, including photos they've taken.
* Profile View
    * User can edit profile image.
* The app generates suggested itineraries
    * The user can input, preferred locations, duration, etc. to get a suggested itinerary  
* Feed sharing -- *technical challenge*
    * There is a home feed of lists and itineraries that were posted by accounts the user followers.
    * The user can share itineraries with their followers.
    * The user can filter for friends to share a certain list or itinerary with (e.g. sharing to a "close friends" list). They can keep a list/itinerary they've created private, only viewable for a certain group of followers, or public.
    * The user can see on their profile feed which lists/itineraries are private, shared to close friends, or public.
    * The app leverages the Facebook API to get friends information.
* Itinerary list view
    * The user can edit an itinerary
    * The user can delete an itinerary
        * If the user is the author, then the itinerary will also be deleted for all users with whom the itinerary is shared 
        * Otherwise, the itienrary will only be deleted for the current user, and still be accessible by other users with whom the itinerary is shared
    * When a photo is loading, the user sees a spinner on top of the placeholder image to indicate that the image is still loading
    * Loaded/cached photos show up immediately without a spinner
* Maps view of an itinerary
    * The user can see all the locations within an itinerary in a maps view.
    * The user can filter in this maps view for specific types of locations, dates planned for locations, etc.
    * The user can generate shortest routes between locations.
* Sharing itinerary - *planned technical challenge continued*
    * Access permissions
        * Author can restrict access to specified accounts
        * Author can set access permissions to viewer or editor
    * Sharer of itinerary will get notified when the receiver has viewed their itinerary.
    * If receiver currently doesn't have the app and they click on a link, they will be prompted to download and sign up for the app.
    * If receiver does have the app, clicking the link will open up the app and prompt the user to login if they aren't signed in. 
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
    => None
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
### Models
Itinerary
| Property | Type | Description |
| --- | --- | --- |
| name | String | name for the itinerary |
| author | pointer to User | who created the itinerary |
| thumbnail | File | thumbnail image for itinerary |
| startDate | DateTime | when itinerary begins |
| endDate | DateTime | when itinerary ends |
| lodgingDetails | String | any details about lodging |
| travelDetails | String | any details about transportation |
| lodgingPrice | Number | price of lodging |
| travelPrice | Number | price of transportation |
| totalCost | Number | estimated total cost of itinerary |
| placesToGo | Array of Pointers to Place | the places that are planned in this itinerary |

Place
Note: we pull the Place object information from the Google Place API -- the purpose of this model is such that the app can interface easily with other APIs in the future, in case we want to switch from using the Google Place API.
| Property | Type | Description |
| --- | --- | --- |
| name | String | name of the place |
| placeID | String | unique ID of the place |
| photos | Array of Files  | photos the place |
| rating | Number  | rating of the place by others |
| categories | Array of Strings | type of place |
| priceLevel | Number | general price range represented by 1-4 dollar signs |
| location | Array of Numbers | longtitude and latitude in map or viewport for the map |


User
| Property | Type | Description |
| --- | --- | --- |
| name | String | name of account holder |
| username | String | username for accoount |
| profile picture | File | proifle picture |
| bio | String | user bio |
| favroitedPlaces | Array of Place | the places that the user has favorited |

### Networking
#### Parse network requests
* Login Screen
    * (Read/GET) Get user information based on login information
* Register Screen
    * (Create/POST) Create a new User object
* Itineraries Screen
    * (Read/GET) List out logged in user's itineraries
        ```
        PFQuery *query = [PFQuery queryWithClassName:@"Itinerary"];
        [query orderByDescending:@"createdAt"];
        [query includeKey:@"author"];
        [query whereKey:@"author" equalTo:self.user];

        // fetch data asynchronously
        [query findObjectsInBackgroundWithBlock:^(NSArray *itineraries, NSError *error) {
            if (itineraries != nil) {
                NSLog(@"This is what we got from the query: %@", itineraries);
                for (PFObject *itinerary in itierarires) {
                    NSLog(@"Got itinerary %@", itinerary);
                    // TODO: do something with itinerary
                }
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        ```
    * (Create/POST) Create a new itinerary
      ```
        Itinerary *newItinerary = [Itinerary new];
        // TODO: set thumbnailImage with a default behavior like the first place-to-go's image
        newItinerary.thumbnail = [self getPFFileFromImage:thumbnailImage]; 
        newPost.author = [PFUser currentUser];
        ...
    
        [newPost saveInBackgroundWithBlock: completion];
      ```
* Favorites Screen
    * (Read/GET) List out logged in user's favorites
* Location Detail View
    * (Create/POST) Create a new itinerary (?? no, I wouldn't store all the locations in my Parse database)


#### [OPTIONAL:] Exisiting API Endpoints
##### Google Places API
| Property | Type | Description |
| --- | --- | --- |
| name | GMSPlaceFieldName | name of the place |
| placeID | GMSPlaceFieldPlaceID | unique ID of the place |
| photos | GMSPlaceFieldPhotos  | photos the place |
| rating | GMSPlaceFieldRating  | rating of the place by others |
| categories | GMSPlaceFieldTypes | type of place |
| priceLevel | GMSPlaceFieldPriceLevel | general price range represented by 1-4 dollar signs |
| location | GMSPlaceFieldCoordinate or GMSPlaceFieldViewport | longtitude and latitude in map or viewport for the map |

##### Google Maps API
* for displaying a map with a pinned location (provide latitude and longitude)

## Weekly Milestones
https://docs.google.com/document/d/1zah_j6tPScta1o0TNdDxV8jFPsqdVW8BAHkeB3kaB6Q/edit?usp=sharing

## Progress Demos
**Discover Page V1**

<img src="https://github.com/iristfu/Places/blob/main/discover_v1.gif" width=400>

**Favoriting V1**

<img src="https://github.com/iristfu/Places/blob/main/favorites_v1.gif" width=400>

**Discover Page V2 - with sorting by favorite count**

<img src="https://github.com/iristfu/Places/blob/main/discover_v2_with_sorting.gif" width=400>

**Itineraries V1 - table, compose, add places to go views**

<img src="https://github.com/iristfu/Places/blob/main/itineraries_v1.gif" width=400>

**Itinerary Detail V1**

<img src="https://github.com/iristfu/Places/blob/main/itinerary_detail_v1.gif" width=400>

**Itinerary Sharing V1**

<img src="https://github.com/iristfu/Places/blob/main/itinerary_sharing_v1.gif" width=400>

**Itinerary Activity Tracking - creation and views**

*From the creator's account:*

<img src="https://github.com/iristfu/Places/blob/main/itinerary_activity_tracking_creator.gif" width=300>

*From the viewer's account:*

<img src="https://github.com/iristfu/Places/blob/main/itinerary_activity_tracking_viewer.gif" width=300>

**Map Shortest Route**

<img src="https://github.com/iristfu/Places/blob/main/Map Shortest Route.gif" width=400>


**Itinerary Sharing/Collaboration V2**
*Can set access permission to viewer/editor. Author and many editors can collaborate on the same itinerary. Changes update across all accounts with view access.*

<img src="https://github.com/iristfu/Places/blob/main/Can set access permission.gif" width=300>

*Users with view-only access or link can only view an itinerary, but not edit it.*

<img src="https://github.com/iristfu/Places/blob/main/Users with view-only.gif" width=300>

*Non authors can only delete a shared itinerary for themselves. Other users with view/edit permission will still have access. Author of itinerary can delete the itinerary for everyone with access.*

<img src="https://github.com/iristfu/Places/blob/main/Non authors can.gif" width=300>

**Favoriting V2**
*User can reorder and delete favorites, and also unfavorite from the discover view.*

<img src="https://github.com/iristfu/Places/blob/main/Favoriting V2.gif" width=400>

**Discover Page V3**
*Sort button is embedded within the search bar. More polished UI.*

<img src="https://github.com/iristfu/Places/blob/main/Discover Page V3.gif" width=400>

**Itinerary Detail V2**
*Edit itinerary. More polished UI*

<img src="https://github.com/iristfu/Places/blob/main/Itinerary Detail V2.gif" width=400>

**Autogenerate Itinerary**

<img src="https://github.com/iristfu/Places/blob/main/autogenerate.gif" width=400>

## Full Demo
https://drive.google.com/file/d/1nIC4y2shoAzNTk-6BNKKXcsFLeQKA5OV/view?usp=sharing
