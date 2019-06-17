#  Ready Player

A ready check application that allows anonymous sign in.

## To do list
Group check
Group "chat room"
Tie name to anonymous user
Create chat room -> invite users via link
remove users
block users
add users

profile page
chat rooms list page

# Firebase Data Structure

RoomCheck
    RoomId
        readyCheck
        readyCheckInProgress

Room
    roomcreator
    roomId
    name
    inviteLink
    
UserRooms
    userId
        roomId
    
RoomReadyChecks 
    roomId
        roomReadyChecks
    
ReadyCheck
    readyCheckId

User
    name
    userid

