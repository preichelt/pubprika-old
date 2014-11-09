namespace :db do
  desc "One time initialization for the postgres data directory and user/role"
  task :init do
    `
    mkdir db/postgres
    initdb db/postgres
    echo 'db/postgres directory initialized'
    sudo mkdir /var/pgsql_socket
    sudo chown $USER /var/pgsql_socket
    postgres -D db/postgres -k /var/pgsql_socket & # run postgres in the background
    sleep 5 # let postgres spin up
    echo 'spinning up postgres'
    createuser pubprika --superuser -h /var/pgsql_socket
    echo 'pubprika postgres user created'
    createdb -O pubprika -Eutf8 pubprika_development -h /var/pgsql_socket
    echo 'pubprika_development database created'
    createdb -O pubprika -Eutf8 pubprika_test -h /var/pgsql_socket
    echo 'pubprika_test database created'
    rake db:migrate
    rake db:seed
    # this shouldn't be needed, but leaving here just in case: sudo chown $USER /var/pgsql_socket/
    kill $(jobs -p) # kill the background postgres process
    echo 'postgres stopped'
    `
  end

  task :init_pg_app do
    `
    psql -h localhost -c "CREATE USER pubprika;"
    psql -h localhost -c "ALTER USER pubprika WITH SUPERUSER;"
    psql -h localhost -c "CREATE DATABASE pubprika_development OWNER pubprika;"
    psql -h localhost -c "GRANT ALL PRIVILEGES ON DATABASE pubprika_development to pubprika;"
    psql -h localhost -c "CREATE DATABASE pubprika_test OWNER pubprika;"
    psql -h localhost -c "GRANT ALL PRIVILEGES ON DATABASE pubprika_test to pubprika;"
    rake db:migrate
    rake db:seed
    `
  end
end
