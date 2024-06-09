#!/bin/bash

# Ask the user for the path to the parent folder
read -p "Enter the path to the parent folder: " parent_folder_path

# Check if the parent folder exists
if [ ! -d "$parent_folder_path" ]; then
    echo "Parent folder does not exist. Please provide a valid folder path."
    exit 1
fi

# Ask the user for the folder name (within the parent folder)
read -p "Enter the name of the folder containing the files: " folder_name

# Construct the full folder path
folder_path="$parent_folder_path/$folder_name"

# Check if the folder exists; if not, create it
if [ ! -d "$folder_path" ]; then
    mkdir -p "$folder_path"
    echo "Folder '$folder_name' created in '$parent_folder_path'."
fi

# Get a list of all files in the folder (including those with spaces)
IFS=$'\n' files=($(find "$folder_path" -type f))

# Initialize the current index
current_index=0

while [ $current_index -lt ${#files[@]} ]; do
    # Get the current file name
    current_file="${files[$current_index]}"

    # Display the file name (without the path)
    base_name=$(basename "$current_file")
    echo "Original file name: $base_name"

    # Ask the user for the new name
    read -p "Enter the new name (or 'back' to go back, 'complete' to finish): " new_name

    if [ "$new_name" = "back" ]; then
        # Go back one file
        current_index=$((current_index - 1))
    elif [ "$new_name" = "complete" ]; then
        # Finish the task
        break
    else
        # Get the file extension
        extension="${base_name##*.}"

        # Rename the file (keeping the extension)
        mv "$current_file" "$folder_path/$new_name.$extension"

        # Ask the user for the folder name within the parent folder
        read -p "Enter the name of the folder (within the parent folder) to move the file to: " target_folder_name
        target_folder_path="$parent_folder_path/$target_folder_name"

        # Check if the target folder exists; if not, create it
        if [ ! -d "$target_folder_path" ]; then
            mkdir -p "$target_folder_path"
            echo "Folder '$target_folder_name' created in '$parent_folder_path'."
        fi

        # Move the file to the target folder
        mv "$folder_path/$new_name.$extension" "$target_folder_path/$new_name.$extension"
        echo "File '$base_name' renamed and moved to '$target_folder_name/$new_name.$extension'."
        current_index=$((current_index + 1))
    fi
done

# Capitalize each word in the name of every file in the parent folder
for file in "$parent_folder_path"/*; do
    base_name=$(basename "$file")
    new_name=$(echo "$base_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')
    mv "$file" "$parent_folder_path/$new_name"
done


echo "Files renamed, moved, and capitalized successfully!"
