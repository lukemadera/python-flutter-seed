# import random

import mongo_db
import user_auth as _user_auth

_users = [
    {
        'email': 'bob@earthshot.eco',
        'password': 'pass12',
        'first_name': 'Bob',
        'last_name': 'Johnson',
        'roles': ['']
    },
    {
        'email': 'alice@earthshot.eco',
        'password': 'pass23',
        'first_name': 'Alice',
        'last_name': 'Souza',
        'roles': ['']
    }
]


def GetInvestorUser():
  return {
    'email': 'sarah@vc.eco',
    'password': 'pass23',
    'first_name': 'Sarah',
    'last_name': 'Investor',
    'roles': ['investor']
  }


# TODO treating a proponent as a user without role is not great. We should improve this
def GetProponentUser():
  return {
    'email': 'andrew@proponent.ngo',
    'password': 'pass23',
    'first_name': 'Andrew',
    'last_name': 'Proponent',
    'roles': ['']
  }

def GetAll():
    global _users
    return _users

def CreateUser(user):
    return _user_auth.signup(user['email'], user['password'], user['first_name'], user['last_name'], user['roles'])

def DeleteAll():
    mongo_db.delete_many('user', {})
