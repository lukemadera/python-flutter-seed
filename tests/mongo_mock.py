import mongomock

import mongo_db

_db = {}
_inited = 0

def InitAllCollections():
    global _inited
    global _db
    if not _inited:
        collectionNames = ['user', 'image', 'landProject', 'landProjectStats', 'landProjectUser', 'parcel', 'parcelStats']
        for collectionName in collectionNames:
            _db[collectionName] = mongomock.MongoClient().db.collection
        mongo_db.SetDB(_db)
        _inited = 1

def GetCollection(collectionName):
    global _db
    if collectionName in _db:
        return _db[collectionName]
    _db[collectionName] = mongomock.MongoClient().db.collection
    mongo_db.SetDB(_db)
    return _db[collectionName]
