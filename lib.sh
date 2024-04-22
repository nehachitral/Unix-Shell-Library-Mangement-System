#!/bin/bash

LIBRARY_FILE="library.csv"
AUTHOR_LOGIN_FILE="author_login.txt"
USER_LOGIN_FILE="user_login.txt"
BORROWED_BOOKS_FILE="borrowed_books.txt"

# Function to register a new author
register_author() {
    new_author_username=$(zenity --entry --title "Register New Author" --text "Enter new author username:" --width=400 --height=500)
    new_author_password=$(zenity --password --title "Register New Author" --text "Enter new author password:" --width=400 --height=500)

    echo "$new_author_username:$new_author_password" >> "$AUTHOR_LOGIN_FILE"
    zenity --info --text "New author registered successfully! 🎉" --width=400 --height=500
}

# Function to register a new user
register_user() {
    new_user_username=$(zenity --entry --title "Register New User" --text "Enter new user username:" --width=400 --height=500)
    new_user_password=$(zenity --password --title "Register New User" --text "Enter new user password:" --width=400 --height=500)

    echo "$new_user_username:$new_user_password" >> "$USER_LOGIN_FILE"
    zenity --info --text "New user registered successfully! 🎉" --width=400 --height=500
}

# Function to authenticate author using zenity
authenticate_author() {
    author_username=$(zenity --entry --title "Author Login" --text "Enter author username:" --width=400 --height=500)
    author_password=$(zenity --password --title "Author Login" --text "Enter author password:" --width=400 --height=500)

    if grep -q "^$author_username:$author_password$" "$AUTHOR_LOGIN_FILE"; then
        zenity --info --text "Author authentication successful! 🎉" --width=400 --height=500
    else
        zenity --error --text "Author authentication failed. Exiting... ❌" --width=400 --height=500
        exit 1
    fi
}

# Function to authenticate user using zenity
authenticate_user() {
    user_username=$(zenity --entry --title "User Login" --text "Enter user username:" --width=400 --height=500)
    user_password=$(zenity --password --title "User Login" --text "Enter user password:" --width=400 --height=500)

    if grep -q "^$user_username:$user_password$" "$USER_LOGIN_FILE"; then
        zenity --info --text "User authentication successful! 🎉" --width=400 --height=500
    else
        zenity --error --text "User authentication failed. Exiting... ❌" --width=400 --height=500
        exit 1
    fi
}

# Function to determine login type
select_login_type() {
    login_type=$(zenity --list --title "Login Type" --column "Select login type:" "Author" "User" "Register New User/Author" --width=400 --height=500)

    case $login_type in
        "Author") authenticate_author ;;
        "User") authenticate_user ;;
        "Register New User/Author") register_new_user_author ;;
        *) zenity --error --text "Invalid selection. Exiting... ❌" --width=400 --height=500; exit 1 ;;
    esac
}

# Function to register a new user or author
register_new_user_author() {
    registration_type=$(zenity --list --title "Registration Type" --column "Select registration type:" "Register New Author" "Register New User" --width=400 --height=500)

    case $registration_type in
        "Register New Author") register_author ;;
        "Register New User") register_user ;;
        *) zenity --error --text "Invalid selection. Exiting... ❌" --width=400 --height=500; exit 1 ;;
    esac
}

# Function to display the main menu
display_menu() {
    choice=$(zenity --list --title "Library Management System" --text "Choose an option:" \
        --column="Option" --column="Description" \
        "Add Book" "Add a new book to the library" \
        "View All Books" "View all books in the library" \
        "Search Books by Author" "Search books by author" \
        "Display All Authors" "Display all unique authors" \
        "Borrow Book" "Borrow a book from the library" \
        "Return Book" "Return a borrowed book" \
        "Count Books by Author" "Count the number of books by a specific author" \
        "Display Total Books" "Display the total number of books in the library" \
        "Edit Book" "Edit book information" \
        "Delete Book" "Delete a book from the library" \
        "Display Borrowed Books" "View books borrowed by the user" \
        "Exit" "Exit the program" --width=600 --height=500)

    case $choice in
        "Add Book") add_book ;;
        "View All Books") view_books ;;
        "Search Books by Author") search_books_by_author ;;
        "Display All Authors") display_authors ;;
        "Borrow Book") borrow_book ;;
        "Return Book") return_book ;;
        "Count Books by Author") count_books_by_author ;;
        "Display Total Books") display_total_books ;;
        "Edit Book") edit_book ;;
        "Delete Book") delete_book ;;
        "Display Borrowed Books") display_borrowed_books ;;
        "Exit") zenity --info --text "Exiting... 🚪" --width=400 --height=500; exit 0 ;;
        *) zenity --error --text "Invalid choice. Please try again. ❌" --width=400 --height=500 ;;
    esac
}
# Function to display borrowed books
display_borrowed_books() {
    user_borrowed_books=$(grep ",$user_username," "$BORROWED_BOOKS_FILE")
    if [ -n "$user_borrowed_books" ]; then
        zenity --info --title "Borrowed Books" --text "$user_borrowed_books" --width=600 --height=500
    else
        zenity --info --text "You haven't borrowed any books yet. 📚" --width=400 --height=500
    fi
}

# Function to delete a b
delete_book() {
    book_title=$(zenity --entry --title "Delete Book" --text "Enter the title of the book to delete:" --width=400 --height=500)

    # Check if the book exists in the library
    if grep -q "^$book_title" "$LIBRARY_FILE"; then
        # Get the author of the book
        author=$(grep "^$book_title" "$LIBRARY_FILE" | head -n 1| cut -d ',' -f 2)

        # Check if the user is the author who added the book
        if [ "$author" != "$user_username" ]; then
            zenity --error --text "You are not authorized to delete this book. Only the author ($author) can delete it. ❌" --width=400 --height=500
            return
        fi

        # Remove the book from the library
        sed -i "/^$book_title,/d" "$LIBRARY_FILE"
        zenity --info --text "Book deleted successfully! 📚" --width=400 --height=500
    else
        zenity --error --text "Book not found in the library. Please check the title and try again. ❌" --width=400 --height=500
    fi
}

edit_book() {
    book_title=$(zenity --entry --title "Edit Book" --text "Enter the title of the book to edit:" --width=400 --height=500)

    # Check if the book exists in the library
    if grep -q "^$book_title" "$LIBRARY_FILE"; then
        # Get the author of the book
        author=$(grep "^$book_title" "$LIBRARY_FILE" | head -n 1| cut -d ',' -f 2)

        # Check if the user is the author who added the book
        if [ "$author" != "$user_username" ]; then
            zenity --error --text "You are not authorized to edit this book. Only the author ($author) can edit it. ❌" --width=400 --height=500
            return
        fi

        # Prompt for new information
        new_title=$(zenity --entry --title "Edit Book" --text "Enter new title:" --width=400 --height=500)
        new_author=$(zenity --entry --title "Edit Book" --text "Enter new author:" --width=400 --height=500)

        # Update the book information
        sed -i "/^$book_title,/ s/^.*$/$new_title,$new_author/" "$LIBRARY_FILE"
        zenity --info --text "Book information updated successfully! 📚" --width=400 --height=500
    else
        zenity --error --text "Book not found in the library. Please check the title and try again. ❌" --width=400 --height=500
    fi
}
add_book() {
    # Check if the user is an author
    if  grep -q "^$author_username" "$AUTHOR_LOGIN_FILE"; then
        zenity --error --text "Only authors can add books. Please log in as an author. ❌" --width=400 --height=500
        return
    fi

    title=$(zenity --entry --title "Add Book" --text "Enter book title:" --width=400 --height=500)
    author=$(zenity --entry --title "Add Book" --text "Enter author:" --width=400 --height=500)
    num_books=$(zenity --entry --title "Add Book" --text "Enter the number of copies to add:" --width=400 --height=500)

    # Check if num_books is a valid positive integer
    if ! [[ "$num_books" =~ ^[0-9]+$ ]] || [ "$num_books" -le 0 ]; then
        zenity --error --text "Please enter a valid positive integer for the number of copies. ❌" --width=400 --height=500
        return
    fi

    # Add the specified number of copies of the book to the library
    for (( i=1; i<=$num_books; i++ )); do
        echo "$title,$author" >> "$LIBRARY_FILE"
    done

    zenity --info --text "Books added successfully! 📚" --width=400 --height=500
}



# Function to view all books
view_books() {
    zenity --text-info --title "View All Books" --filename "$LIBRARY_FILE" --width=600 --height=500
}

# Function to search for books by author
search_books_by_author() {
    author=$(zenity --entry --title "Search Books by Author" --text "Enter author:" --width=400 --height=500)
    result=$(grep -i "$author" "$LIBRARY_FILE" | cut -d ',' -f 1)
    if [ -n "$result" ]; then
        zenity --info --title "Books by $author" --text "$(echo "$result" | tr '\n' ' ')" --width=600 --height=500
    else
        zenity --info --text "No books found for author $author. ❌" --width=400 --height=500
    fi
}

# Function to display unique authors
display_authors() {
    authors=$(cut -d ',' -f 2 "$LIBRARY_FILE" | sort | uniq)
    zenity --info --title "Unique Authors" --text "$(echo "$authors" | tr '\n' ' ')" --width=600 --height=500
}

# Function to count the number of books by a specific author
count_books_by_author() {
    author_to_count=$(zenity --entry --title "Count Books by Author" --text "Enter author's name:" --width=400 --height=500)
    count=$(grep -ic "$author_to_count" "$LIBRARY_FILE")

    if [ "$count" -gt 0 ]; then
        zenity --info --title "Books by $author_to_count" --text "Number of books: $count" --width=400 --height=500
    else
        zenity --info --text "No books found for author $author_to_count. ❌" --width=400 --height=500
    fi
}

# Function to display the total number of books in the library with tables
display_total_books() {
    total_books=$(wc -l < "$LIBRARY_FILE")
    zenity --info --title "Total Number of Books in the Library" --text "Total Books: $total_books" --width=400 --height=500
}

borrow_book() {
    # Check if the user is not an author
    if grep -q "^$user_username" "$AUTHOR_LOGIN_FILE"; then
        zenity --error --text "Authors cannot borrow books. Please log in as a user. ❌" --width=400 --height=500
        return
    fi

    book_title=$(zenity --entry --title "Borrow Book" --text "Enter the title of the book you want to borrow:" --width=400 --height=500)

    # Check if the book exists in the library
    if grep -q "^$book_title," "$LIBRARY_FILE"; then
        # Get current date
        current_date=$(date +"%Y-%m-%d")

        # Check if the book is already borrowed
        if grep -q "^$book_title,$user_username" "$BORROWED_BOOKS_FILE"; then
            zenity --error --text "You have already borrowed this book. Please return it before borrowing again. ❌" --width=400 --height=500
            return
        fi

        # Add the book to the borrowed books file
        echo "$book_title,$user_username,$current_date" >> "$BORROWED_BOOKS_FILE"

        # Update the library file by deleting only one copy of the book
        sed -i "/^$book_title,/ {/,$user_username/d}" "$LIBRARY_FILE"

        zenity --info --text "Book borrowed successfully! 📚\nDate of borrowing: $current_date" --width=400 --height=500
    else
        zenity --error --text "Book not found in the library. Please check the title and try again. ❌" --width=400 --height=500
    fi
}




# Function to return a borrowed boo
return_book() {
  book_title=$(zenity --entry --title "Return Book" --text "Enter the title of the book to return:" --width=400 --height=500)
  author_name=$(zenity --entry --title "Author name" --text "Enter the author name:" --width=400 --height=500)

  # Check if the book is borrowed
  if grep -q "^$book_title" "$BORROWED_BOOKS_FILE"; then
    borrowed_info=$(grep "^$book_title" "$BORROWED_BOOKS_FILE")

    # Remove the book from borrowed list
    sed -i "/^$book_title/d" "$BORROWED_BOOKS_FILE"

    # Add the book back to the library with the author name
    echo "$book_title,$author_name" >> "$LIBRARY_FILE"

    zenity --info --text "Book returned successfully!" --width=400 --height=500
  else
    zenity --error --text "Book not found in borrowed books. Please check the title and try again. ❌" --width=400 --height=500
  fi
}



# Main program
select_login_type

while true; do
    display_menu
done
