#!/bin/bash

declare -a board

rows=3
columns=3

empty=0
x_player=1
o_player=2

function initialize_game {
  local max=$((rows*columns))

    for ((i=0; i<max; i++)); do
        board[$i]=$empty
    done
}

function print_guide {
    echo "------------------------------------GUIDE------------------------------------"
    echo "The board is numbered as follows:"
    echo " 1 | 2 | 3 "
    echo "-----------"
    echo " 4 | 5 | 6 "
    echo "-----------"
    echo " 7 | 8 | 9 "

    echo "MOVE: To make a move, enter the number of the place you want to put your symbol in"
    echo "SAVE: To save the game, type 'save'"
    echo "-----------------------------------------------------------------------------"
}

function print_matrix {
    echo "------------------------------------BOARD------------------------------------"

    for ((i=0; i<rows; i++)); do
      print_row "$i"
      if [ "$i" -ne $((rows-1)) ]; then
        echo "-----------"
      fi
    done

    echo "-----------------------------------------------------------------------------"
}

function print_row {
    local row=$i

    for ((j=0; j<columns; j++)); do
        local current_place=$((row*columns+j))

        print_symbol ${board[$current_place]}

        if [ "$j" -ne $((columns-1)) ]; then
            echo -n "|"
        fi
    done

    echo ""
}

function print_symbol {
    local symbol=$1

    if [ "$symbol" -eq $empty ]; then
        echo -n "   "
    elif [ "$symbol" -eq $x_player ]; then
        echo -n " X "
    elif [ "$symbol" -eq $o_player ]; then
        echo -n " O "
    fi
}

function check_winner {

  # Check rows
  for ((i=0; i<rows; i++)); do
    local row=$((i*columns))
    if [ ${board[$row]} -eq $x_player ] && [ ${board[$row+1]} -eq $x_player ] && [ ${board[$row+2]} -eq $x_player ]; then
      echo "First player wins [X]!"
      exit 0
    elif [ ${board[$row]} -eq $o_player ] && [ ${board[$row+1]} -eq $o_player ] && [ ${board[$row+2]} -eq $o_player ]; then
      echo "Second player wins [O]!"
      exit 0
    fi
  done

  # Check columns
  for ((i=0; i<columns; i++)); do
    if [ ${board[$i]} -eq $x_player ] && [ ${board[$i+3]} -eq $x_player ] && [ ${board[$i+6]} -eq $x_player ]; then
      echo "First player wins [X]!"
      exit 0
    elif [ ${board[$i]} -eq $o_player ] && [ ${board[$i+3]} -eq $o_player ] && [ ${board[$i+6]} -eq $o_player ]; then
      echo "Second player wins [O]!"
      exit 0
    fi
  done

  # Check first diagonal
  if [ ${board[0]} -eq $x_player ] && [ ${board[4]} -eq $x_player ] && [ ${board[8]} -eq $x_player ]; then
    echo "First player wins [X]!"
    exit 0
  elif [ ${board[0]} -eq $o_player ] && [ ${board[4]} -eq $o_player ] && [ ${board[8]} -eq $o_player ]; then
    echo "Second player wins [O]!"
    exit 0
  fi

  # Check second diagonal
  if [ ${board[2]} -eq $x_player ] && [ ${board[4]} -eq $x_player ] && [ ${board[6]} -eq $x_player ]; then
    echo "First player wins [X]!"
    exit 0
  elif [ ${board[2]} -eq $o_player ] && [ ${board[4]} -eq $o_player ] && [ ${board[6]} -eq $o_player ]; then
    echo "Second player wins [O]!"
    exit 0
  fi
}

function check_draw {
  local max=$((rows*columns))
  local is_full=true

  for ((i=0; i<max; i++)); do
    if [ ${board[$i]} -eq $empty ]; then
      is_full=false
      break
    fi
  done

  echo "is_full: $is_full"

  if [ "$is_full" = true ]; then
    echo "It's a draw!"
    exit 0
  fi
}

function player_move {
  local player=$1
  local command=""

  echo "Player $player's turn - enter a place to put your symbol in (or type 'help' to get help): "
  read -r command

  if [ "$command" = "help" ]; then
    print_guide
    player_move "$player"
    return
  fi

  if [ "$command" = "save" ]; then
    save_game "$player"
    player_move "$player"
    return
  fi

  re='^[1-9]$'

  if ! [[ $command =~ $re ]] ; then
    echo "Provided value is invalid, please provide a number from 1 to 9" >&2;
    player_move "$player"
    return
  fi

  local place=$((command-1))

  if [ ${board[$place]} -ne $empty ]; then
    echo "This place is already taken, please choose another one"
    player_move "$player"
    return
  fi

  board[$place]=$player

  print_matrix

  check_winner "$player"
  check_draw
}

function play_game {
  while true; do
    player_move $x_player
    player_move $o_player
  done
}

function load_game {
  echo "Enter the name of the file you want to load the game from: "
  read -r file

  local file_path="$file".txt

  if [ ! -f "$file_path" ]; then
    echo "File not found!"
    return
  fi

  echo "Loading the game from $file..."

  read -r saved_board_line < "$file_path"
  read -r saved_player_turn < <(sed -n '2p' "$file_path")

  IFS=' ' read -r -a saved_board <<< "$saved_board_line"

  validate_board "${saved_board[@]}"
  validate_player_turn "$saved_player_turn"

  echo "Game loaded successfully!"

  for ((i=0; i<${#saved_board[@]}; i++)); do
    echo "saved_board[$i]: ${saved_board[$i]}"
  done

  echo "saved_player_turn: $saved_player_turn"
  exit 0

}

function validate_board {
  local saved_board=("$@")

  local error_message="Your save file is corrupted, board is invalid!"

  echo "Length: ${#saved_board[@]}"
  echo "Expected length: $((rows*columns))"
  if [ ${#saved_board[@]} -ne $((rows*columns)) ]; then
    echo "$error_message"
    exit 1
  fi

  for ((i=0; i<${#saved_board[@]}; i++)); do
    if [ "${saved_board[$i]}" -ne $empty ] && [ "${saved_board[$i]}" -ne $x_player ] && [ "${saved_board[$i]}" -ne $o_player ]; then
      echo "$error_message"
      exit 1
    fi
  done
}

function validate_player_turn {
  local player_turn=$1

  local error_message="Your save file is corrupted, player's turn is invalid!"

  if [ "$player_turn" -ne $x_player ] && [ "$player_turn" -ne $o_player ]; then
    echo "$error_message"
    exit 1
  fi
}

function save_game  {
    local player_turn=$1

  echo "Enter the name of the file you want to save the game in: "
  read -r file

  echo "Saving the game in $file..."

  {
  echo "${board[@]}"
  echo "$player_turn"
} > "file".txt

  echo "Game saved successfully!, type 'continue' to continue playing or anything else to exit:"
  read -r command

  if [ "$command" = "continue" ]; then
    return
  fi

  exit 0
}

echo "Hello, welcome to Tic-Tac-Toe game!"

echo "Type 'new' to start a new game or 'load' to load a saved game: "
read -r command

if [ "$command" = "new" ]; then
  initialize_game
elif [ "$command" = "load" ]; then
  load_game
else
  echo "Invalid command, exiting..."
  exit 1
fi

play_game