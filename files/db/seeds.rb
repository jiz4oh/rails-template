puts 'Creating admin user...'
Admin.create_with(password: 'admin')
     .find_or_create_by!(email: 'admin@admin.com')
