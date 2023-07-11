rs.initiate({
    _id: "rs0",
    members: [
        { _id: 0, host: "{{ backend_ip }}:{{ mongo_db_port }}" },
        { _id: 1, host: "{{ backend_ip }}:{{ mongo_db_port2 }}" },
        { _id: 2, host: "{{ backend_ip }}:{{ mongo_db_port3 }}" }
    ]
});

db.createUser({
    user: "{{ mongo_api_username }}",
    pwd: "{{ mongo_api_password }}",
    roles: [
        { role: "dbOwner", db: "{{ mongo_db_name }}" }
    ]
});
