#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a random number as the correct answer to be guessed
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
GUESS_COUNT=0

NUMBER_GUESS() {
  if [[ $1 ]]
    then
    echo -e "\n$1"
    else
    echo -e "\nGuess the secret number between 1 and 1000:"
  fi
  read GUESS
  GUESS_COUNT=$(( GUESS_COUNT + 1 ))
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
    then
    NUMBER_GUESS "That is not an integer, guess again:"
    else
    if [[ $GUESS == $SECRET_NUMBER ]]
      then
      echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
      GAME_RESULT=$($PSQL "INSERT INTO games(user_id, num_of_guesses) VALUES($USER_ID, $GUESS_COUNT)")
      else
        if (( $GUESS > $SECRET_NUMBER ))
        then
        NUMBER_GUESS "It's lower than that, guess again:"
        else
        NUMBER_GUESS "It's higher than that, guess again:"
      fi
    fi
  fi
}

echo -e "\nEnter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")
if [[ -z $USER_ID ]]
 then
 echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
 NEW_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES ('$USERNAME')")
 USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")
 else
 USER_HISTORY=$($PSQL "SELECT COUNT(game_id) AS game_count, MIN(num_of_guesses) AS best_game FROM games WHERE user_id = $USER_ID")
 echo "$USER_HISTORY" | while IFS="|" read GAMES_PLAYED BEST_GAME
  do
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
 fi
 
NUMBER_GUESS