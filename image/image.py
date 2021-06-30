import mongo_db

def Get(title = '', url = '', user_id_creator = '', limit = 25, skip = 0):
    ret = { 'valid': 1, 'msg': '', 'images': [] }
    query = {}
    if len(url) > 0:
        query['url'] = url
    if len(title) > 0:
        # query['title'] = title
        query['title'] = { '$regex': title, '$options': 'i' };
    if len(user_id_creator) > 0:
        query['user_id_creator'] = user_id_creator
    ret['images'] = mongo_db.find('image', query, limit = limit, skip = skip)['items']
    return ret

def Save(image):
    ret = { 'valid': 1, 'msg': '', 'image': {} }
    query = {
        'url': image['url'],
    }
    mutation = {
        '$set': {
            'title': image['title'],
            'user_id_creator': image['user_id_creator'],
        }
    }
    result = mongo_db.update_one('image', query, mutation, upsert=True)
    ret['image'] = image
    if result and result['upserted_id']:
        ret['image']['_id'] = result['upserted_id']
    return ret
