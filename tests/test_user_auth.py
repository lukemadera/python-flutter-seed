import mongo_mock as _mongo_mock
import user_auth as _user_auth

def test_signup():
    _mongo_mock.InitAllCollections()
    # _mongo_mock.GetCollection('user')
    user = { 'email': 'joe@email.com', 'password': 'pass1', 'first_name': 'Joe', 'last_name': 'Johnson' }
    retUser = _user_auth.signup(user['email'], user['password'], user['first_name'], user['last_name'])
    retGet = _user_auth.getByEmail(user['email'])
    assert retGet['_id'] == retUser['user']['_id']
    assert retGet['email'] == user['email']
