#!/bin/bash
# feat: number guessing game with username tracking

# File to store user stats
DB_FILE="user_data.txt"

# Ensure database file exists
touch $DB_FILE


echo -n "Enter your username: "
read username
username=$(echo "$username" | cut -c1-22) # truncate to 22 characters

# Check if username exists in database
user_line=$(grep "^$username|" $DB_FILE)

if [ -n "$user_line" ]; then
  IFS='|' read -r _ games_played best_game <<< "$user_line"
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
else
  echo "Welcome, $username! It looks like this is your first time here."
  games_played=0
  best_game=0
fi

# Generate secret number between 1 and 1000
secret_number=$(( RANDOM % 1000 + 1 ))
num_guesses=0

echo "Guess the secret number between 1 and 1000:"

while true; do
  read guess

  # Check if input is integer
  if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((num_guesses++))

  if [ "$guess" -lt "$secret_number" ]; then
    echo "It's higher than that, guess again:"
elif [ "$guess" -gt "$secret_number" ]; then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $num_guesses tries. The secret number was $secret_number. Nice job!"
    
    # Update database
    ((games_played++))
    if [ "$best_game" -eq 0 ] || [ "$num_guesses" -lt "$best_game" ]; then
      best_game=$num_guesses
    fi

    # Remove old record if exists
    grep -v "^$username|" $DB_FILE > temp.txt
    mv temp.txt $DB_FILE

    # Add updated record
    echo "$username|$games_played|$best_game" >> $DB_FILE
    break
  fi
done
