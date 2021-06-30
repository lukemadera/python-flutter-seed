import os
from aiohttp import web
import aiohttp
import aiohttp_cors
import asyncio
import json
import ssl
import socketio
import sys
import time
import threading

import log
import ml_config
import mongo_db
import notifications
import websocket_clients as _websocket_clients

import routes_websocket

import user_auth
from image import file_upload as _file_upload

sio = socketio.AsyncServer(ping_timeout=3000, cors_allowed_origins='*')

config = ml_config.get_config()
log.init_logger(config)
db = ml_config.get_db(config)
config_notifications = config['notifications'] or {}
notifications.set_config(config_notifications)

paths_index = config['web_server']['index']
paths_static = config['web_server']['static']

log.log('warn', 'web_server starting')

# Regular websocket
async def websocket_handler(request):

    # print ('websocket_handler', request)
    ws = web.WebSocketResponse(max_msg_size = 25 * 1024 * 1024)
    await ws.prepare(request)

    async for msg in ws:
        # print ('msg', msg, ws)
        if msg.type == aiohttp.WSMsgType.ERROR:
            print('ws connection closed with exception %s' % ws.exception())
        else:
            if msg.type == aiohttp.WSMsgType.TEXT:
                dataString = msg.data
            elif msg.type == aiohttp.WSMsgType.BINARY:
                dataString = msg.data.decode(encoding='utf-8')
            # print ('dataString', dataString)
            try:
                data = json.loads(dataString)

                auth = data['auth'] if 'auth' in data else {}

                # if msg.data == 'close':
                #     await ws.close()
                # else:
                #     await ws.send_str(msg.data + '/answer')

                # if data['route'] == 'route1':
                #     ret = { "route": data['route'], "data": data['data'], "auth": auth }
                #     await ws.send_json(ret)
                # elif data['route'] == 'route2':
                #     ret = { "route": data['route'], "data": data['data'], "auth": auth }
                #     await ws.send_json(ret)

                retData = routes_websocket.routeIt(data['route'], data['data'], auth)

                # Handle socket connections.
                if '_socketAdd' in retData:
                    _websocket_clients.AddClient(retData['_socketAdd']['user_id'], ws)
                    del retData['_socketAdd']
                if '_socketGroupAdd' in retData:
                    _websocket_clients.AddUsersToGroup(retData['_socketGroupAdd']['group_name'],
                        retData['_socketGroupAdd']['user_ids'])
                    del retData['_socketGroupAdd']

                if '_socketSendSeparate' in retData:
                    for sendInfo in retData['_socketSendSeparate']:
                        sendTemp = { "route": sendInfo['route'],
                            "data": sendInfo['data'],
                            "auth": auth }
                        utf8Bytes = json.dumps(sendTemp).encode(encoding='utf-8')
                        if 'userIds' in sendInfo:
                            await _websocket_clients.SendToUsers(utf8Bytes, sendInfo['userIds'])
                        elif 'groups' in sendInfo:
                            await _websocket_clients.SendToGroups(utf8Bytes, sendInfo['groups'])
                    del retData['_socketSendSeparate']

                # Must be after send, in case want to send a message before remove.
                if '_socketRemove' in retData:
                    _websocket_clients.RemoveClientsByUser(retData['_socketRemove']['user_id'])
                    del retData['_socketRemove']

                # See if should send to multiple connections.
                if '_socketSend' in retData:
                    skipUserIds = retData['_socketSend']['skipUserIds'] if 'skipUserIds' in \
                        retData['_socketSend'] else []
                    if 'groups' in retData['_socketSend']:
                        groups = retData['_socketSend']['groups']
                        del retData['_socketSend']
                        ret = { "route": data['route'], "data": retData, "auth": auth }
                        utf8Bytes = json.dumps(ret).encode(encoding='utf-8')
                        await _websocket_clients.SendToGroups(utf8Bytes, groups, skipUserIds)
                    elif 'users' in retData['_socketSend']:
                        del retData['_socketSend']
                        users = retData['_socketSend']['users']
                        ret = { "route": data['route'], "data": retData, "auth": auth }
                        utf8Bytes = json.dumps(ret).encode(encoding='utf-8')
                        await _websocket_clients.SendToUsers(utf8Bytes, users, skipUserIds)
                elif '_socketSkip' in retData:
                    pass
                else:
                    ret = { "route": data['route'], "data": retData, "auth": auth }
                    # await ws.send_json(ret)
                    # utf8Bytes = bytes(json.dumps(ret), 'utf-8')
                    utf8Bytes = json.dumps(ret).encode(encoding='utf-8')
                    await ws.send_bytes(utf8Bytes)
            except Exception as e:
                print ('json parse exception', dataString, e)
                log.log('warn', 'web_server json parse exception', dataString, str(e))

    _websocket_clients.RemoveClient(id(ws))
    print('websocket connection closed')

    return ws



async def index(request):
    print ('index', request)
    """Serve the client-side application."""
    with open(paths_index['files'] + '/index.html') as f:
        return web.Response(text=f.read(), content_type='text/html')

async def static_files(request):
    print ('static_files', request)
    # Does not actually work, but prevents error at least..
    encoding = 'latin-1' if 'favicon' in request.path else None
    contentType = request.content_type
    with open((paths_index['files'] + request.path), encoding=encoding) as f:
        return web.Response(text=f.read(), content_type=contentType)

# @sio.on('connect', namespace='/user-auth')
# async def connect(sid, environ):
#     log.log('debug', 'web_server', 'socket connected to /user-auth')
#     await sio.emit('connected', { 'msg': 'Socket connected to /user-auth' }, room=sid, namespace='/user-auth')

# @sio.on('login', namespace='/user-auth')
# async def message(sid, data):
#     ret = user_auth.login(data['email'], data['password'])
#     await sio.emit('login', ret, room=sid, namespace='/user-auth')

# @sio.on('forgotPassword', namespace='/user-auth')
# async def message(sid, data):
#     ret = user_auth.forgotPassword(data['email'])
#     await sio.emit('forgotPassword', ret, room=sid, namespace='/user-auth')

# @sio.on('signup', namespace='/user-auth')
# async def message(sid, data):
#     ret = user_auth.signup(data['email'], data['password'], data['first_name'], data['last_name'],
#         data['roles'])

#     if ret['valid'] and 'user' in ret and ret['user']:

#         therapistUsername = data['therapistUsername'] if 'therapistUsername' in data else ''
#         if len(therapistUsername) > 0:
#             if ret['valid'] and 'user' in ret and '_id' in ret['user']:
#                 _student.addTherapistByUsername(ret['user']['_id'], therapistUsername, 'therapy')

#             if therapistUsername == 'luketh2':
#                 # Hardcoded - for now set to specific mini game.
#                 userPrefs = {
#                     'user_id': ret['user']['_id'],
#                     'game_mode': 'mini_game',
#                     # 'mini_game': 'runnerPersonExercisesLoop',
#                     'mini_game': 'questionsOnly',
#                 };
#                 _user_preferences.save(userPrefs)

#     await sio.emit('signup', ret, room=sid, namespace='/user-auth')

# @sio.on('emailVerify', namespace='/user-auth')
# async def message(sid, data):
#     ret = user_auth.emailVerify(data['email'], data['email_verification_key'])
#     await sio.emit('emailVerify', ret, room=sid, namespace='/user-auth')

# @sio.on('passwordReset', namespace='/user-auth')
# async def message(sid, data):
#     ret = user_auth.passwordReset(data['email'], data['password_reset_key'], data['password'])
#     await sio.emit('passwordReset', ret, room=sid, namespace='/user-auth')

# @sio.on('logout', namespace='/user-auth')
# async def message(sid, data):
#     ret = user_auth.logout(data['userId'], data['sessionId'])
#     await sio.emit('logout', ret, room=sid, namespace='/user-auth')

# @sio.on('disconnect', namespace='/user-auth')
# async def disconnect(sid):
#     log.log('debug', 'web_server', 'socket disconnected to /user-auth')
#     await sio.emit('disconnected', { 'msg': 'Socket disconnected to /user-auth' }, room=sid, namespace='/user-auth')

# @sio.on('connect', namespace='/app')
# async def connect(sid, environ):
#     log.log('debug', 'web_server', 'socket connected to /app')
#     await sio.emit('connected', { 'msg': 'Socket connected to /app' }, room=sid, namespace='/app')

# @sio.on('disconnect', namespace='/app')
# async def disconnect(sid):
#     log.log('debug', 'web_server', 'socket disconnected to /app')
#     await sio.emit('disconnected', { 'msg': 'Socket disconnected to /app' }, room=sid, namespace='/app')

# AJAX
async def userGetBySession(request):
    data = request.query
    ret = user_auth.getSession(data['user_id'], data['session_id'])
    return web.json_response(ret)

async def fileUpload(request):
    # Read file in parts and save locally in temp folder.
    # https://docs.aiohttp.org/en/stable/web_quickstart.html#file-uploads
    reader = await request.multipart()
    # reader.next() will `yield` the fields of your form
    # Order matters - mime must be sent BEFORE file.
    field = await reader.next()
    assert field.name == 'mime'
    mime = await field.text()
    field = await reader.next()
    assert field.name == 'keyType'
    keyType = await field.text()
    field = await reader.next()
    assert field.name == 'file'
    file = await field.read(decode=False)
    # filename = field.filename
    filename = _file_upload.FormFilename(mime)
    # You cannot rely on Content-Length if transfer is chunked.
    size = 0
    _file_upload.CreateUploadsDirs()
    filePath = os.path.join('uploads/temp/', filename)
    with open(filePath, 'wb') as f:
        # while True:
        #     chunk = await file.read_chunk()  # 8192 bytes by default.
        #     if not chunk:
        #         break
        #     size += len(chunk)
        #     f.write(chunk)
        # We are already sending back a blob / bytearray so just write it directly.
        f.write(file)

    # data = request.post()
    # ret = _file_upload.Upload(data['file'])
    if keyType == 'imageUpload':
        ret = _file_upload.HandleImage(filePath, config['web_server']['urls']['base_server'], filename)
    # Remove temp file.
    os.remove(filePath)
    return web.json_response(ret)

async def start_async_app():
    try:
        # App 1 - main
        app = web.Application()
        sio.attach(app)
        app.add_routes([web.get('/ws', websocket_handler)])

        # Add CORS: https://docs.aiohttp.org/en/stable/web_advanced.html#cors-support
        corsUrls = config['web_server']['cors_urls']
        defaults = {};
        for url in corsUrls:
            defaults[url] = aiohttp_cors.ResourceOptions()
        cors = aiohttp_cors.setup(app, defaults = defaults)
        # To enable CORS processing for specific route you need to add
        # that route to the CORS configuration object and specify its
        # CORS options.
        resource = cors.add(app.router.add_resource('/web/userGetBySession'))
        cors.add(resource.add_route("GET", userGetBySession))
        # app.add_routes([web.get('/web/userGetBySession', userGetBySession)])

        resource = cors.add(app.router.add_resource('/web/fileUpload'))
        cors.add(resource.add_route("POST", fileUpload))

        # app.router.add_static(paths_static['route'], paths_static['files'])

        # Not able to match whole folder?
        static_files_list = []
        files = os.listdir(paths_static['files'])
        for file in files:
            if file != 'index.html':
                static_files_list.append(file)
        for file in static_files_list:
            app.router.add_get(paths_index['route'] + file, static_files)
        app.add_routes([web.static('/assets', paths_static['files'] + '/assets')])

        # Need to create uploads folder here so it exists.
        _file_upload.CreateUploadsDirs()
        for path1 in config['web_server']['static_folders']:
            defaults[url] = aiohttp_cors.ResourceOptions()
            app.add_routes([web.static('/' + path1, path1)])

        # https://stackoverflow.com/questions/34565705/asyncio-and-aiohttp-route-all-urls-paths-to-handler
        app.router.add_get('/{tail:.*}', index)

        if config['web_server']['ssl'] and config['web_server']['ssl']['enabled']:
            sslInfo = config['web_server']['ssl']
            sslContext = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
            sslContext.load_cert_chain(sslInfo['cert_path'], sslInfo['key_path'])
            portToUse = sslInfo['port']
        else:
            portToUse = config['web_server']['port']
            sslContext = None
        # web.run_app(app, port=portToUse, ssl_context=sslContext)

        runner = web.AppRunner(app)
        await runner.setup()
        site = web.TCPSite(runner, port=portToUse, ssl_context=sslContext)
        await site.start()
        print('App1 started on port', portToUse)
        # Site 2
        if config['web_server']['port_redirect']:
            site2 = web.TCPSite(runner, port=config['web_server']['port_redirect'])
            await site2.start()
            print('App2 started on port', config['web_server']['port_redirect'])
        # wait for finish signal
        # await runner.cleanup()
        return runner, site

    except Exception as e:
        sys.stderr.write('Error: ' + format(str(e)) + "\n")
        sys.exit(1)

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    runner, site = loop.run_until_complete(start_async_app())
    try:
        loop.run_forever()
    except KeyboardInterrupt as err:
        loop.run_until_complete(runner.cleanup())
