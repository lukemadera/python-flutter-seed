import aiohttp
import asyncio
import json

import log
import ml_config

config = ml_config.get_config()

# One per user (assume each websocket client connection is from one user).
# If the same user is connected multiple times (e.g. from multiple devices or
# browsers) then there will be multiple websockets per that user.
# _wsUsers = {
#     'user_id1': {
#         'sockets': [
#             {
#                 'ws': ws1,
#                 'id': 2348523,
#                 'kind': 'aiohttp',
#             },
#             {
#                 'ws': ws2,
#                 'id': 2938742,
#             }
#         ]
#     },
#     'user_id2': {
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

_userIdSelf = '_landapp'
_clientSession = None
_sendQueue = []
_sendingQueue = False
_connectingUserIds = []

async def CheckConnectSocket(urlKey = '_simearth'):
    global _clientSession
    # Skip if already have connection (or are connecting)
    if CheckHaveConnection(urlKey):
        return None
    if _clientSession is None or _clientSession.closed:
        async with aiohttp.ClientSession() as session:
            _clientSession = session
            await ConnectClient(_clientSession, urlKey, GetUrl(urlKey))
    else:
        await ConnectClient(_clientSession, urlKey, GetUrl(urlKey))

def GetUrls():
    return {
        '_simearth': config['server_simearth']['url_websocket'] + '/ws',
    }

def GetUrl(key):
    urlObjs = GetUrls()
    for urlKey in urlObjs:
        if urlKey == key:
            return urlObjs[urlKey]
    return None

def CheckAddClient(url, ws, kind = 'aiohttp'):
    urlObjs = GetUrls()
    for urlKey in urlObjs:
        if urlObjs[urlKey] == url:
            AddClient(urlKey, ws, kind = kind)

def CheckHaveConnection(userId, checkConnecting = 1):
    global _wsUsers
    if userId in _wsUsers and len(_wsUsers[userId]['sockets']) > 0:
        return 1
    if checkConnecting and CheckConnecting(userId):
        return 1
    return 0

def CheckConnecting(userId):
    global _connectingUserIds
    if userId in _connectingUserIds:
        return 1
    return 0

async def ConnectClient(clientSession, userId, url):
    global _userIdSelf, _wsUsers, _connectingUserIds
    # If already have a web socket connection, just use it.
    if userId in _wsUsers and len(_wsUsers[userId]['sockets']) > 0:
        return _wsUsers[userId]['sockets'][0]['ws']
    try:
        if userId not in _connectingUserIds:
            _connectingUserIds.append(userId)
            log.log('info', 'websocket_clients.ConnectClient adding _connectingUserIds', userId)
        ssl = False
        if config['web_server']['ssl'] and config['web_server']['ssl']['enabled']:
            ssl = True
        async with clientSession.ws_connect(url, ssl = ssl, method = 'GET') as ws:
            AddClient(userId, ws, kind = 'aiohttp')
            if userId in _connectingUserIds:
                _connectingUserIds.remove(userId)
                log.log('info', 'websocket_clients.ConnectClient removing _connectingUserIds', userId)
            SendQueue()
            # sendJson = {'route': 'socketAdd', 'data': { 'socketAddUserId': _userIdSelf } }
            # sendJson = { 'route': 'ping', 'data': {} }
            # SendToUsersJson(sendJson, [userId])
            # utf8Bytes = json.dumps(sendJson).encode(encoding='utf-8')
            # await SendToUsers(utf8Bytes, [userId])
            # return ws
            # async for prevents the socket from immediately closing (something about asyncio)
            async for msg in ws:
                # print ('ws_connect msg', msg)
                pass

    except Exception as err:
        if userId in _connectingUserIds:
            _connectingUserIds.remove(userId)
        print ('exception', err)
        return None
    return None

def SendQueue():
    global _sendQueue, _sendingQueue
    if not _sendingQueue:
        _sendingQueue = True
        for sendItem in _sendQueue:
            asyncio.create_task(SendToUsers(sendItem['sendBytes'], sendItem['userIds'], sendItem['skipUserIds']))
        _sendQueue = []
        _sendingQueue = False

def AddClient(userId, ws, kind = 'aiohttp'):
    id1 = id(ws) if kind == 'aiohttp' else str(ws.id)
    global _wsUsers
    # Allow multiple connections for the same user.
    socketObj = {
        'ws': ws,
        'id': id1,
        'kind': kind,
    }
    if userId in _wsUsers:
        # Prevent duplicates.
        found = 0
        for socket in _wsUsers[userId]['sockets']:
            if socket['id'] == socketObj['id'] and socket['kind'] == socketObj['kind']:
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
    global _wsUsers
    if userId in _wsUsers:
        del _wsUsers[userId]
    return {}

def RemoveClient(wsId):
    global _wsUsers
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
    global _wsGroups
    if groupName not in _wsGroups:
        _wsGroups[groupName] = { 'userIds': userIds }
    else:
        for userId in userIds:
            if userId not in _wsGroups[groupName]['userIds']:
                _wsGroups[groupName]['userIds'].append(userId)
    return {}

def RemoveGroup(groupName):
    global _wsGroups
    if groupName in _wsGroups:
        del _wsGroups[groupName]

def RemoveUsersFromGroup(groupName, userIds):
    global _wsGroups
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
    global _wsGroups
    userIds = []
    if groupName in _wsGroups:
        for userId in _wsGroups[groupName]['userIds']:
            if userId not in skipUserIds:
                userIds.append(userId)
    return userIds

async def SendToUsers(sendBytes, userIds, skipUserIds=[], tryToConnectFirst = 1):
    global _wsUsers, _sendQueue
    skipSend = 0
    if tryToConnectFirst:
        urls = GetUrls()
        for url in urls:
            if url in userIds:
                if not CheckHaveConnection(url):
                    log.log('info', 'websocket_clients.SendToUsers no connection, connecting first', url)
                    # await CheckConnectSocket(url)
                    asyncio.create_task(CheckConnectSocket(url))
                    _sendQueue.append({ 'sendBytes': sendBytes, 'userIds': userIds, 'skipUserIds': skipUserIds })
                    skipSend = 1
                # If connecting, still want to skip for now.
                elif CheckConnecting(url):
                    log.log('info', 'websocket_clients.SendToUsers connecting', url)
                    skipSend = 1
                    _sendQueue.append({ 'sendBytes': sendBytes, 'userIds': userIds, 'skipUserIds': skipUserIds })
    if skipSend:
        log.log('info', 'websocket_clients.SendToUsers skipSend, added to queue', ', '.join(userIds))
    if not skipSend:
        for userId in userIds:
            if userId not in skipUserIds and userId in _wsUsers:
                for socket in _wsUsers[userId]['sockets']:
                    socketId = socket['id']
                    try:
                        if socket['kind'] == 'aiohttp':
                            await socket['ws'].send_bytes(sendBytes)
                        elif socket['kind'] == 'websockets':
                            await socket['ws'].send(sendBytes)
                    except Exception as e:
                        print ("websocket_client.SendToUsers exception, removing socket", e, socketId)
                        RemoveClient(socketId)
    return {}

async def SendToGroups(sendBytes, groupNames, skipUserIds=[]):
    global _wsGroups
    for groupName in groupNames:
        if groupName in _wsGroups:
            await SendToUsers(sendBytes, _wsGroups[groupName]['userIds'], skipUserIds)
    return {}

def SendToUsersJson(sendJson, userIds, skipUserIds = []):
    utf8Bytes = json.dumps(sendJson).encode(encoding='utf-8')
    asyncio.create_task(SendToUsers(utf8Bytes, userIds, skipUserIds = skipUserIds))
    return {}

def SendToGroupsJson(sendJson, groupNames, skipUserIds = []):
    utf8Bytes = json.dumps(sendJson).encode(encoding='utf-8')
    asyncio.create_task(SendToGroups(utf8Bytes, groupNames, skipUserIds = skipUserIds))
    return {}
