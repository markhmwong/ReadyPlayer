#  Ready Player

A ready check application that allows anonymous sign in.

## To do list
anonymous authentication <done>
Group "chat room" <done>
Tie name to anonymous user <done>
Chat Room
    Group check
    create room <done>
    invite users via link
    remove users
    block users
    add users
        add user through an invite link
            any user can send another user a "link" of the chat room.
            invite has an expiry
        user requests access to chat room
            will need a search
        
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

