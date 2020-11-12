puts 'Creating admin user...'
Admin.create_with(password: 'admin')
     .find_or_create_by!(username: 'admin@admin.com')
