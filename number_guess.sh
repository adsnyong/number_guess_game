#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#start with read USERNAME

LOWER_LIMIT=1
UPPER_LIMIT=1000

# Generate random number within range
RANDOM_NUMBER=$(( (RANDOM % (UPPER_LIMIT - LOWER_LIMIT + 1)) + LOWER_LIMIT ))
GAMEANS=$RANDOM_NUMBER
echo $GAMEANS
GUESS_COUNT=0


echo "Enter your username:"
read USERNAME
USERDATA=$($PSQL "SELECT * FROM guessuser WHERE username = '$USERNAME'")
if [[ -z $USERDATA ]]
then
REGISTER_USER=$($PSQL "INSERT INTO guessuser(username, game_played) VALUES('$USERNAME', 0)")
echo "Welcome, $USERNAME! It looks like this is your first time here."

else
GAMEPLAYED=$($PSQL "SELECT game_played FROM guessuser WHERE username = '$USERNAME'")
BESTGAME=$($PSQL "SELECT best_game FROM guessuser WHERE username = '$USERNAME'")

  echo "Welcome back, $USERNAME! You have played $GAMEPLAYED games, and your best game took $BESTGAME guesses."
  

fi

echo "Guess the secret number between 1 and 1000:"
read GUESS_NUMBER
until [[ $GUESS_NUMBER == $GAMEANS ]]
do
  
  # check guess is valid/an integer
  if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
    then
      # request valid guess
      echo -e "\nThat is not an integer, guess again:"
      read GUESS_NUMBER
      # update guess count
      ((GUESS_COUNT++))
    
    # if its a valid guess
    else
      # check inequalities and give hint
      if [[ $GUESS_NUMBER -lt $GAMEANS ]]
        then
          echo "It's higher than that, guess again:"
          read GUESS_NUMBER
          # update guess count
          ((GUESS_COUNT++))
        else 
          echo "It's lower than that, guess again:"
          read GUESS_NUMBER
          #update guess count
          ((GUESS_COUNT++))
      fi  
  fi

done

((GUESS_COUNT++))
OLDBESTGAME=$($PSQL "SELECT best_game FROM guessuser WHERE username = '$USERNAME'")

if [[ $GUESS_COUNT < $OLDBESTGAME ]] || [[ -z $OLDBESTGAME ]]
then
UPDATEBG=$($PSQL "UPDATE guessuser SET best_game = $GUESS_COUNT WHERE username = '$USERNAME'")
fi

echo "You guessed it in $GUESS_COUNT tries. The secret number was $GAMEANS. Nice job!"
GAMEPLAYED=$($PSQL "SELECT game_played FROM guessuser WHERE username = '$USERNAME'")
((GAMEPLAYED++))
ICGAMEPLAYED=$($PSQL "UPDATE guessuser SET game_played = $GAMEPLAYED")

