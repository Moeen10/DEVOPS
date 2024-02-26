#!/bin/bash

# User and Backup Management Script

# Function to display usage instructions for user management
display_user_usage() {
    echo "User Management:"
    echo "  -a, --add USER_NAME      Add a new user"
    echo "  -m, --modify USER_NAME   Modify an existing user"
    echo "  -d, --delete USER_NAME   Delete a user"
    echo "  -g, --group GROUP_NAME   Create a new group"
}

# Function to add a user
add_user() {
    sudo useradd -m $1
    echo "User $1 added successfully"
}

# Function to modify a user (change username and password)
modify_user() {
    sudo usermod -l $2 $1
    echo "$2" | sudo passwd --stdin $2
    echo "User $1 modified successfully"
}

# Function to delete a user
delete_user() {
    sudo userdel -r $1
    echo "User $1 deleted successfully"
}

# Function to create a group and use
create_group_and_add_user() {
    GROUP_NAME=$1
    USERNAME=$2
    GROUP_DIR="Dev_Groups"

    # Check if the Groups directory exists, if not, create it
    if [ ! -d "$GROUP_DIR" ]; then
        mkdir "$GROUP_DIR"
        echo "Directory $GROUP_DIR created."
    fi

    # Check if the group already exists
    if grep -q "^$GROUP_NAME:" /etc/group; then
        echo "Group $GROUP_NAME already exists."

        # Check if the user is already in the group
        if groups $USERNAME | grep -q "\b$GROUP_NAME\b"; then
            echo "User $USERNAME is already a member of group $GROUP_NAME."
        else
            # Add the user to the group
            sudo usermod -aG $GROUP_NAME $USERNAME
            echo "User $USERNAME added to group $GROUP_NAME."
        fi
    else
        # Create the group inside the Groups directory
        sudo groupadd $GROUP_NAME

        # Add the user to the newly created group
        sudo usermod -aG $GROUP_NAME $USERNAME
        echo "Group $GROUP_NAME created successfully and user $USERNAME added."
    fi
}



# Function to backup all user directories
backup_users() {
    BACKUP_DIR="/backup_User"
    sudo mkdir -p $BACKUP_DIR

    for user_dir in /home/*; do
        user=$(basename $user_dir)
        sudo tar -vczf $BACKUP_DIR/${user}_backup_$(date +'%Y%m%d_%H%M%S').tar.gz -C /home $user
        echo "Backup created for user $user"
    done

    echo "All user backups completed successfully"
}

# Main script logic
case $1 in
    -a | --add)
        add_user $2
        ;;
    -m | --modify)
        modify_user $2 $3
        ;;
    -d | --delete)
        delete_user $2
        ;;
    -g | --group)
             create_group_and_add_user $2 $3
        ;;
    -b | --backup)
        backup_users
        ;;
    *)
        echo "Usage: $0 [option] [arguments]"
        display_user_usage
        echo "  -b, --backup              Backup all user directories"
        ;;
esac

