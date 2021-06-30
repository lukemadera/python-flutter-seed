class UserClass {
  String id, email, first_name, last_name, status, username, session_id, roles, created_at;
  //List<String> roles;
  UserClass(this.id, this.email, this.first_name, this.last_name, this.status, this.username, this.session_id, this.roles,
    this.created_at);
  UserClass.fromJson(Map<String, dynamic> json)
    :
      id = json['_id'],
      email = json['email'],
      first_name = json['first_name'],
      last_name = json['last_name'],
      status = json['status'],
      username = json['username'],
      session_id = json['session_id'],
      roles = json['roles'],
      created_at = json['created_at']
    ;

  Map<String, dynamic> toJson() =>
    {
      'id': id,
      'email': email,
      'first_name': first_name,
      'last_name': last_name,
      'status': status,
      'username': username,
      'session_id': session_id,
      'roles': roles,
      'created_at': created_at,
    };
}
