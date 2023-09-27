# One per user (assume each websocket client connection is from one user).
# If the same user is connected multiple times (e.g. from multiple devices or
# browsers) then there will be multiple websockets per that user.
# _wsUsers = {
#     'userId1': {
#         'sockets': [
#             {
#                 'ws': ws1,
#                 'id': 2348523
#             },
#             {
#                 'ws': ws2,
#                 'id': 2938742
#             }
#         ]
#     },
#     'userId2': {
#         'sockets': []
#     }
# }
_wsUsers = {}

# One per group.
# _wsGroups = {
#     'groupName1': {
#         'userIds': []
#     },
#     'groupName2': {
#         'userIds': []
#     }
# }
_wsGroups = {}

def AddClient(userId, ws):
    # Allow multiple connections for the same user.
    socketObj = {
        'ws': ws,
        'id': id(ws)
    }
    if userId in _wsUsers:
        # Prevent duplicates.
        found = 0
        for socket in _wsUsers[userId]['sockets']:
            if socket['id'] == socketObj['id']:
                found = 1
                break
        if not found:
            _wsUsers[userId]['sockets'].append(socketObj)
    else:
        _wsUsers[userId] = {
            'sockets': [ socketObj ]
        }
    return {}

# Removes ALL sockets for the user (e.g. on logout).
def RemoveClientsByUser(userId):
    if userId in _wsUsers:
        del _wsUsers[userId]
    return {}

def RemoveClient(wsId):
    # Loop through all clients until find the matching websocket and remove it.
    # Only should be ONE match, so break once found it.
    found = 0
    indexToRemove = -1
    for userId in _wsUsers:
        for index, socket in list(enumerate(_wsUsers[userId]['sockets'])):
            if socket['id'] == wsId:
                indexToRemove = index
                found = 1
                break
        if indexToRemove > -1:
            del _wsUsers[userId]['sockets'][indexToRemove]
            # If no more clients left for this user, remove whole user.
            if len(_wsUsers[userId]['sockets']) < 1:
                RemoveClientsByUser(userId)
        if found:
            break
    return {}

def AddUsersToGroup(groupName, userIds):
    if groupName not in _wsGroups:
        _wsGroups[groupName] = { 'userIds': userIds }
    else:
        for userId in userIds:
            if userId not in _wsGroups[groupName]['userIds']:
                _wsGroups[groupName]['userIds'].append(userId)
    return {}

def RemoveGroup(groupName):
    if groupName in _wsGroups:
        del _wsGroups[groupName]

def RemoveUsersFromGroup(groupName, userIds):
    if groupName in _wsGroups:
        removeIndices = []
        # Go through in reverse so can remove multiple at the end without changing
        # indices (of next, lower indexed item) between each remove.
        for index, userId in reversed(list(enumerate(_wsGroups[groupName]['userIds']))):
            if userId in userIds:
                removeIndices.append(index)
        for index in removeIndices:
            del _wsGroups[groupName]['userIds'][index]
        # If no more users, delete whole group.
        if len(_wsGroups[groupName]['userIds']) < 1:
            RemoveGroup(groupName)
    return {}

def GetUserIdsInGroup(groupName, skipUserIds=[]):
    userIds = []
    if groupName in _wsGroups:
        for userId in _wsGroups[groupName]['userIds']:
            if userId not in skipUserIds:
                userIds.append(userId)
    return userIds

async def SendToUsers(sendBytes, userIds, skipUserIds=[]):
    for userId in userIds:
        if userId not in skipUserIds and userId in _wsUsers:
            for socket in _wsUsers[userId]['sockets']:
                socketId = socket['id']
                try:
                    await socket['ws'].send_bytes(sendBytes)
                except Exception as e:
                    print ("websocket_client.SendToUsers exception, removing socket", e, socketId)
                    RemoveClient(socketId)
    return {}

async def SendToGroups(sendBytes, groupNames, skipUserIds=[]):
    for groupName in groupNames:
        if groupName in _wsGroups:
            await SendToUsers(sendBytes, _wsGroups[groupName]['userIds'], skipUserIds)
    return {}
