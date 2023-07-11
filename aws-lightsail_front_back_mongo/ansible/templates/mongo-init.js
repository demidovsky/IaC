db.createUser(
 {
   user: "{{ mongo_api_username }}",
   pwd: "{{ mongo_api_password }}",
   roles: [
      { role: "dbOwner", db: "{{ mongo_db_name }}" }
   ]
 }
);
